//
//  CommunicationSignalingClient.swift
//  AzureCommunicationSignaling
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import TrouterModulePrivate
import AzureCore

public class CommunicationSignalingClient {
    private var selfHostedTrouterClient: SelfHostedTrouterClient
    private var communicationSkypeTokenProvider: CommunicationSkypeTokenProvider
    private var trouterUrlRegistrar: TrouterUrlRegistrar
    private var logger: ClientLogger

    public init (skypeTokenProvider: CommunicationSkypeTokenProvider,
                 logger: ClientLogger = ClientLoggers.default(tag: "AzureCommunicationSignalingClient")) {
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
            trouterHostname: getTrouterHostname())

        let regData: TrouterUrlRegistrationData = createRegistrationData()
        // swiftlint:disable force_cast
        trouterUrlRegistrar = TrouterUrlRegistrar.create(
            with: communicationSkypeTokenProvider,
            registrationData: regData,
            registrarHostnameAndBasePath: getRegistrarHostnameAndBasePath() ,
            maxRegistrationTtlS: 3600) as! TrouterUrlRegistrar
        // swiftlint:enable force_cast
    }

    public func start() {
        selfHostedTrouterClient.withRegistrar(trouterUrlRegistrar)
        selfHostedTrouterClient.start()
    }

    public func stop() {
        selfHostedTrouterClient.stop()
    }

    public func on (event: String, listener: @escaping EventListener) {
        switch event {
        case ChatEventId.chatMessageReceived.rawValue:
            selfHostedTrouterClient.register(CommunicationListener(listener: listener), forPath: "/chatMessageReceived")
        case ChatEventId.typingIndicatorReceived.rawValue:
            selfHostedTrouterClient.register(CommunicationListener(listener: listener), forPath: "/typingIndicatorReceived")
        case ChatEventId.readReceiptReceived.rawValue:
            selfHostedTrouterClient.register(CommunicationListener(listener: listener), forPath: "/readReceiptReceived")
        case ChatEventId.chatMessageEdited.rawValue:
            selfHostedTrouterClient.register(CommunicationListener(listener: listener), forPath: "/chatMessageEdited")
        case ChatEventId.chatMessageDeleted.rawValue:
            selfHostedTrouterClient.register(CommunicationListener(listener: listener), forPath: "/chatMessageDeleted")
        case ChatEventId.chatThreadCreated.rawValue:
            selfHostedTrouterClient.register(CommunicationListener(listener: listener), forPath: "/chatThreadCreated")
        case ChatEventId.chatThreadPropertiesUpdated.rawValue:
            selfHostedTrouterClient.register(CommunicationListener(listener: listener), forPath: "/chatThreadPropertiesUpdated")
        case ChatEventId.chatThreadDeleted.rawValue:
            selfHostedTrouterClient.register(CommunicationListener(listener: listener), forPath: "/chatThreadDeleted")
        case ChatEventId.participantsAdded.rawValue:
            selfHostedTrouterClient.register(CommunicationListener(listener: listener), forPath: "/participantsAdded")
        case ChatEventId.participantsRemoved.rawValue:
            selfHostedTrouterClient.register(CommunicationListener(listener: listener), forPath: "/participantsRemoved")
        default:
            return
        }
    }
}

public class CommunicationSkypeTokenProvider: NSObject, TrouterSkypetokenProvider {
    var skypeToken: String?
    public func getSkypetoken(_ forceRefresh: Bool) -> String! {
        return self.skypeToken
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
        if self.data == nil {
            self.data = ""
        }
        return self.data
    }
}

class CommunicationListener: NSObject, TrouterListener {
    var listener: EventListener
    var logger: ClientLogger

    init (listener: @escaping EventListener,
          logger: ClientLogger = ClientLoggers.default(tag: "AzureCommunicationListener")) {
        self.listener = listener
        self.logger = logger
    }

    func onTrouterConnected(_ endpointUrl: String!, _ connectionInfo: TrouterConnectionInfo!) {
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
                logger.error("event Id does not match with what are supported")
                fatalError("event Id does not match with what are supported")
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
