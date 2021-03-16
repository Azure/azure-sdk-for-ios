//
//  CommunicationSignalingClient.swift
//  AzureCommunicationSignaling
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore
import Foundation
import TrouterModulePrivate
import UIKit

public class CommunicationSignallingClient {
    private var selfHostedTrouterClient: SelfHostedTrouterClient
    private var communicationSkypeTokenProvider: CommunicationSkypeTokenProvider
    private var trouterUrlRegistrar: TrouterUrlRegistrar
    private var logger: ClientLogger
    private var communicationListeners: Set<CommunicationListener> = []

    public init(
        skypeTokenProvider: CommunicationSkypeTokenProvider,
        logger: ClientLogger = ClientLoggers.default(tag: "AzureCommunicationSignalingClient")
    ) {
        self.communicationSkypeTokenProvider = skypeTokenProvider
        self.logger = logger
        let trouterSkypeTokenHeaderProvider = TrouterSkypetokenAuthHeaderProvider(
            skypetokenProvider: communicationSkypeTokenProvider
        )

        let communicationCache = CommunicationCache()
        selfHostedTrouterClient = SelfHostedTrouterClient.create(
            withClientVersion: getClientVersion(),
            authHeadersProvider: trouterSkypeTokenHeaderProvider,
            dataCache: communicationCache,
            trouterHostname: getTrouterHostname()
        )

        let regData: TrouterUrlRegistrationData = createRegistrationData()
        // swiftlint:disable force_cast
        trouterUrlRegistrar = TrouterUrlRegistrar.create(
            with: communicationSkypeTokenProvider,
            registrationData: regData,
            registrarHostnameAndBasePath: getRegistrarHostnameAndBasePath(),
            maxRegistrationTtlS: 3600
        ) as! TrouterUrlRegistrar
        // swiftlint:enable force_cast
    }

    public convenience init?(
        token: String?
    ) {
        guard let skypeToken = token else {
            return nil
        }

        let skypeTokenProvider = CommunicationSkypeTokenProvider(skypeToken: skypeToken)
        self.init(skypeTokenProvider: skypeTokenProvider)
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
            guard let chatEventId = eventIds[generalPayload._eventId] else {
                throw AzureError.client("event Id does not match with what are supported")
            }

            // convert trouter payload to chat event payload
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
