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
import TrouterClientIos
import UIKit

public class CommunicationSignalingClient {
    private var selfHostedTrouterClient: SelfHostedTrouterClient
    private var communicationSkypeTokenProvider: CommunicationSkypeTokenProvider
    private var trouterUrlRegistrar: TrouterUrlRegistrar
    private var logger: ClientLogger
    private var communicationListeners: Set<CommunicationListener> = []

    public init(
        skypeTokenProvider: CommunicationSkypeTokenProvider,
        logger: ClientLogger = ClientLoggers.default(tag: "AzureCommunicationSignalingClient")
    ) throws {
        self.communicationSkypeTokenProvider = skypeTokenProvider
        self.logger = logger

        let trouterSkypeTokenHeaderProvider = TrouterSkypetokenAuthHeaderProvider(
            skypetokenProvider: communicationSkypeTokenProvider
        )

        let communicationCache = CommunicationCache()
        selfHostedTrouterClient = SelfHostedTrouterClient.create(
            withClientVersion: defaultClientVersion,
            authHeadersProvider: trouterSkypeTokenHeaderProvider,
            dataCache: communicationCache,
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

    public convenience init(
        token: String
    ) throws {
        let skypeTokenProvider = CommunicationSkypeTokenProvider(skypeToken: token)
        try self.init(skypeTokenProvider: skypeTokenProvider)
    }

    public func start() {
        selfHostedTrouterClient.withRegistrar(trouterUrlRegistrar)
        selfHostedTrouterClient.start()
    }

    public func stop() {
        selfHostedTrouterClient.stop()
        communicationListeners.forEach { listener in
            selfHostedTrouterClient.unregisterListener(listener)
        }
        communicationListeners.removeAll()
    }

    public func on(event: String, listener: @escaping EventListener) {
        let communicationListener = CommunicationListener(listener: listener)
        switch event {
        case ChatEventId.chatMessageReceived.rawValue:
            selfHostedTrouterClient.register(communicationListener, forPath: "/chatMessageReceived")
        case ChatEventId.typingIndicatorReceived.rawValue:
            selfHostedTrouterClient.register(communicationListener, forPath: "/typingIndicatorReceived")
        case ChatEventId.readReceiptReceived.rawValue:
            selfHostedTrouterClient.register(communicationListener, forPath: "/readReceiptReceived")
        case ChatEventId.chatMessageEdited.rawValue:
            selfHostedTrouterClient.register(communicationListener, forPath: "/chatMessageEdited")
        case ChatEventId.chatMessageDeleted.rawValue:
            selfHostedTrouterClient.register(communicationListener, forPath: "/chatMessageDeleted")
        case ChatEventId.chatThreadCreated.rawValue:
            selfHostedTrouterClient.register(communicationListener, forPath: "/chatThreadCreated")
        case ChatEventId.chatThreadPropertiesUpdated.rawValue:
            selfHostedTrouterClient.register(communicationListener, forPath: "/chatThreadPropertiesUpdated")
        case ChatEventId.chatThreadDeleted.rawValue:
            selfHostedTrouterClient.register(communicationListener, forPath: "/chatThreadDeleted")
        case ChatEventId.participantsAdded.rawValue:
            selfHostedTrouterClient.register(communicationListener, forPath: "/participantsAdded")
        case ChatEventId.participantsRemoved.rawValue:
            selfHostedTrouterClient.register(communicationListener, forPath: "/participantsRemoved")
        default:
            return
        }
        communicationListeners.insert(communicationListener)
    }

    public func off(event _: String, listener: @escaping EventListener) {
        let communicationListener = CommunicationListener(listener: listener)
        if communicationListeners.contains(communicationListener) {
            selfHostedTrouterClient.unregisterListener(communicationListener)
            communicationListeners.remove(communicationListener)
        }
    }
}

public class CommunicationSkypeTokenProvider: NSObject, TrouterSkypetokenProvider {
    var skypeToken: String?
    public func getSkypetoken(_: Bool) -> String! {
        return skypeToken
    }

    public init(skypeToken: String? = nil) {
        self.skypeToken = skypeToken
    }
}

class CommunicationCache: NSObject, TrouterConnectionDataCache {
    var data: String?
    func store(_ data: String!) {
        self.data = data
    }

    func load() -> String! {
        if data == nil {
            data = ""
        }
        return data
    }
}

class CommunicationListener: NSObject, TrouterListener {
    var listener: EventListener
    var logger: ClientLogger

    init(
        listener: @escaping EventListener,
        logger: ClientLogger = ClientLoggers.default(tag: "AzureCommunicationListener")
    ) {
        self.listener = listener
        self.logger = logger
    }

    func onTrouterConnected(_: String!, _: TrouterConnectionInfo!) {
        logger.info("Trouter Connected")
    }

    func onTrouterDisconnected() {
        logger.info("Trouter Disconnected")
    }

    func onTrouterRequest(_ request: TrouterRequest!, _ response: TrouterResponse!) {
        logger.info("Received a Trouter request \n")

        do {
            let requestJsonData = request.body.data(using: .utf8)!
            let generalPayload = try JSONDecoder().decode(BasePayload.self, from: requestJsonData)
            let chatEventId = try ChatEventId(forCode: generalPayload._eventId)

            // Convert trouter payload to chat event payload
            let chatEvent = toEventPayload(request: request, chatEventId: chatEventId)
            if let unwrapped = chatEvent {
                listener(unwrapped, chatEventId)
            }

            response.body = "Request has been handled"
            response.status = 200
            let result: TrouterSendResponseResult = response.send()
            logger.info("Sent a response to Trouter: \(result)")
        } catch {
            logger.error("Error: \(error)")
        }
    }
}

public typealias EventListener = (_ response: Any, _ eventId: ChatEventId) -> Void
