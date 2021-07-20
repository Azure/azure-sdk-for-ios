// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import AzureCore
import Foundation
import Trouter

class CommunicationSignalingClient {
    private var selfHostedTrouterClient: SelfHostedTrouterClient
    private var communicationSkypeTokenProvider: CommunicationSkypeTokenProvider
    private var trouterUrlRegistrar: TrouterUrlRegistrar
    private var logger: ClientLogger
    private var communicationHandlers: [ChatEventId: CommunicationHandler] = [:]

    init(
        skypeTokenProvider: CommunicationSkypeTokenProvider,
        logger: ClientLogger = ClientLoggers.default(tag: "AzureCommunicationSignalingClient")
    ) throws {
        self.communicationSkypeTokenProvider = skypeTokenProvider
        self.logger = logger

        let trouterSkypeTokenHeaderProvider = TrouterSkypetokenAuthHeaderProvider(
            skypetokenProvider: communicationSkypeTokenProvider
        )

        selfHostedTrouterClient = SelfHostedTrouterClient.create(
            withClientVersion: defaultClientVersion,
            authHeadersProvider: trouterSkypeTokenHeaderProvider,
            dataCache: nil,
            trouterHostname: defaultTrouterHostname
        )

        guard let regData = defaultRegistrationData else {
            throw AzureError.client("Failed to create TrouterUrlRegistrationData.")
        }

        guard let trouterUrlRegistrar = TrouterUrlRegistrar.create(
            with: communicationSkypeTokenProvider,
            registrationData: regData,
            registrarHostnameAndBasePath: defaultRegistrarHostnameAndBasePath,
            maxRegistrationTtlS: 3600
        ) as? TrouterUrlRegistrar else {
            throw AzureError.client("Failed to create TrouterUrlRegistrar.")
        }

        self.trouterUrlRegistrar = trouterUrlRegistrar
    }

    convenience init(
        token: String
    ) throws {
        let skypeTokenProvider = CommunicationSkypeTokenProvider(skypeToken: token)
        try self.init(skypeTokenProvider: skypeTokenProvider)
    }

    func start() {
        selfHostedTrouterClient.withRegistrar(trouterUrlRegistrar)
        selfHostedTrouterClient.start()
    }

    func stop() {
        selfHostedTrouterClient.stop()
        communicationHandlers.forEach { _, handler in
            selfHostedTrouterClient.unregisterListener(handler)
        }
        communicationHandlers.removeAll()
    }

    func on(event: ChatEventId, handler: @escaping TrouterEventHandler) {
        let logger = ClientLoggers.default(tag: "AzureCommunicationHandler-\(event)")
        let communicationHandler = CommunicationHandler(handler: handler, logger: logger)
        selfHostedTrouterClient.register(communicationHandler, forPath: "/\(event)")
        communicationHandlers[event] = communicationHandler
    }

    func off(event: ChatEventId) {
        if let communicationHandler = communicationHandlers[event] {
            selfHostedTrouterClient.unregisterListener(communicationHandler)
            communicationHandlers.removeValue(forKey: event)
        }
    }
}

class CommunicationSkypeTokenProvider: NSObject, TrouterSkypetokenProvider {
    var skypeToken: String?
    func getSkypetoken(_: Bool) -> String! {
        return skypeToken
    }

    init(skypeToken: String? = nil) {
        self.skypeToken = skypeToken
    }
}

class CommunicationHandler: NSObject, TrouterListener {
    var handler: TrouterEventHandler
    var logger: ClientLogger

    init(
        handler: @escaping TrouterEventHandler,
        logger: ClientLogger = ClientLoggers.default(tag: "AzureCommunicationHandler")
    ) {
        self.handler = handler
        self.logger = logger
    }

    // MARK: TrouterListenerProtocol

    func onTrouterConnected(_: String, _: TrouterConnectionInfo) {
        logger.info("Trouter Connected")
    }

    func onTrouterDisconnected() {
        logger.info("Trouter Disconnected")
    }

    func onTrouterRequest(_ request: TrouterRequest, _ response: TrouterResponse) {
        logger.info("Received a Trouter request \n")

        do {
            guard let requestJsonData = request.body.data(using: .utf8) else {
                throw AzureError.client("Unable to convert request body to Data.")
            }

            let generalPayload = try JSONDecoder().decode(BasePayload.self, from: requestJsonData)
            let chatEventId = try ChatEventId(forCode: generalPayload._eventId)

            // Convert trouter payload to chat event payload
            let chatEvent = try TrouterEventUtil.create(chatEvent: chatEventId, from: request)
            handler(chatEvent)
        } catch {
            logger.error("Error: \(error)")
        }

        // Notify Trouter the request was handled
        response.body = "Request has been handled"
        response.status = 200
        let result: TrouterSendResponseResult = response.send()
        logger.info("Sent a response to Trouter: \(result)")
    }
}
