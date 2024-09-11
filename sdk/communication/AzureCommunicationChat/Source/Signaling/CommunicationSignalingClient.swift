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

import AzureCommunicationCommon
import AzureCore
import Foundation
import Trouter

/// Signaling errors enum for errors that might occur when realtime-notifications are started.
public enum CommunicationSignalingError: Error {
    case failedToRefreshToken(String)
}

/// Handler for signaling errors.
public typealias CommunicationSignalingErrorHandler = (CommunicationSignalingError) -> Void

/// TrouterTokenRefreshHandler for fetching tokens.
internal typealias TrouterTokenRefreshHandler = (_ stopSignalingClient: Bool, Error?) -> Void

class CommunicationSignalingClient {
    private var selfHostedTrouterClient: SelfHostedTrouterClient?
    private var communicationSkypeTokenProvider: CommunicationSkypeTokenProvider
    private var trouterUrlRegistrar: TrouterUrlRegistrar?
    private var logger: ClientLogger
    private var communicationHandlers: [ChatEventId: CommunicationHandler] = [:]
    private var configuration: RealTimeNotificationConfiguration?
    private var configApiVersion: String

    // Step 1: Initialize with basic properties
    init(
        communicationSkypeTokenProvider: CommunicationSkypeTokenProvider,
        logger: ClientLogger = ClientLoggers.default(tag: "AzureCommunicationSignalingClient")
    ) throws {
        self.logger = logger
        self.communicationSkypeTokenProvider = communicationSkypeTokenProvider
        self.configApiVersion = "2024-09-01"
    }

    // Step 2: Configure with fetched TrouterSettings
    public func configure(token: String, endpoint: String, completionHandler: @escaping (Result<Void, AzureError>) -> Void) {
        self.getTrouterSettings(token: token, endpoint: endpoint) { result in
            switch result {
            case .success(let configuration):
                self.configuration = configuration

                let trouterSkypeTokenHeaderProvider = TrouterSkypetokenAuthHeaderProvider(
                    skypetokenProvider: self.communicationSkypeTokenProvider
                )
                
                // Remove the "https://" prefix from the URLs
                var trouterHostname = configuration.trouterServiceUrl.replacingOccurrences(of: "https://", with: "")
                let registrarBasePath = configuration.registrarServiceUrl.replacingOccurrences(of: "https://", with: "")
                
                // Add the suffix "/v3/a" to trouterHostname
                trouterHostname += "/v4/a"

                self.selfHostedTrouterClient = SelfHostedTrouterClient.create(
                    withClientVersion: defaultClientVersion,
                    authHeadersProvider: trouterSkypeTokenHeaderProvider,
                    dataCache: nil,
                    trouterHostname: trouterHostname
                )

                guard let regData = defaultRegistrationData else {
                    completionHandler(.failure(AzureError.client("Failed to create TrouterUrlRegistrationData.")))
                    return
                }

                guard let trouterUrlRegistrar = TrouterUrlRegistrar.create(
                    with: self.communicationSkypeTokenProvider,
                    registrationData: regData,
                    registrarHostnameAndBasePath: registrarBasePath,
                    maxRegistrationTtlS: 3600
                ) as? TrouterUrlRegistrar else {
                    completionHandler(.failure(AzureError.client("Failed to create TrouterUrlRegistrar.")))
                    return
                }

                self.trouterUrlRegistrar = trouterUrlRegistrar
                completionHandler(.success(()))

            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func start() {
        // Guard to check if selfHostedTrouterClient and trouterUrlRegistrar are initialized
        guard let selfHostedTrouterClient = self.selfHostedTrouterClient,
              let trouterUrlRegistrar = self.trouterUrlRegistrar else {
            logger.error("Failed to start: SelfHostedTrouterClient or TrouterUrlRegistrar is not initialized.")
            return
        }
        
        selfHostedTrouterClient.withRegistrar(trouterUrlRegistrar)
        selfHostedTrouterClient.start()
        selfHostedTrouterClient.setUserActivityState(UserActivityState.TrouterUserActivityStateActive)
    }

    func stop() {
        // Guard to check if selfHostedTrouterClient is initialized
        guard let selfHostedTrouterClient = self.selfHostedTrouterClient else {
            logger.error("Failed to stop: SelfHostedTrouterClient is not initialized.")
            return
        }
        
        selfHostedTrouterClient.stop()
        communicationHandlers.forEach { _, handler in
            selfHostedTrouterClient.unregisterListener(handler)
        }
        communicationHandlers.removeAll()
    }

    func on(event: ChatEventId, handler: @escaping TrouterEventHandler) {
        // Guard to check if selfHostedTrouterClient is initialized
        guard let selfHostedTrouterClient = self.selfHostedTrouterClient else {
            logger.error("Failed to register event handler: SelfHostedTrouterClient is not initialized.")
            return
        }
        
        let logger = ClientLoggers.default(tag: "AzureCommunicationHandler-\(event)")
        let communicationHandler = CommunicationHandler(handler: handler, logger: logger)
        selfHostedTrouterClient.register(communicationHandler, forPath: "/\(event)")
        communicationHandlers[event] = communicationHandler
    }

    func off(event: ChatEventId) {
        // Guard to check if selfHostedTrouterClient is initialized
        guard let selfHostedTrouterClient = self.selfHostedTrouterClient else {
            logger.error("Failed to unregister event handler: SelfHostedTrouterClient is not initialized.")
            return
        }
        
        if let communicationHandler = communicationHandlers[event] {
            selfHostedTrouterClient.unregisterListener(communicationHandler)
            communicationHandlers.removeValue(forKey: event)
        }
    }
    
    private func getTrouterSettings(
            token: String,
            endpoint: String,
            completionHandler: @escaping (Result<RealTimeNotificationConfiguration, AzureError>) -> Void
        ) {
            let urlString = "\(endpoint)/chat/config/realTimeNotifications?api-version=\(configApiVersion)"
            guard let url = URL(string: urlString) else {
                completionHandler(.failure(AzureError.client("Invalid URL constructed for real-time notifications settings.")))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let session = URLSession.shared
            session.dataTask(with: request) { data, response, error in
                if let error = error {
                    completionHandler(.failure(AzureError.service("Error", error)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completionHandler(.failure(AzureError.client("Received non-200 response from server.")))
                    return
                }

                guard let data = data else {
                    completionHandler(.failure(AzureError.client("No data received from the server.")))
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let trouterSettings = try decoder.decode(RealTimeNotificationConfiguration.self, from: data)
                    
                    completionHandler(.success(trouterSettings))
                } catch {
                    completionHandler(.failure(AzureError.client("Failed to decode trouter settings: \(error.localizedDescription)")))
                }
            }.resume()
        }
}

class CommunicationSkypeTokenProvider: NSObject, TrouterSkypetokenProvider {
    /// The cached skypeToken.
    var token: String

    /// The CommunicationTokenCredential.
    var credential: CommunicationTokenCredential

    /// Called from getSkypetoken, handle token errors here.
    var tokenRefreshHandler: TrouterTokenRefreshHandler

    /// Current number of token fetch retries.
    var tokenRetries: Int

    /// Max number of token retries allowed.
    let maxTokenRetries: Int = 3

    /// Return the cached token, will attempt to refresh the token if forceRefresh is true.
    func getSkypetoken(_ forceRefresh: Bool) -> String! {
        if forceRefresh {
            tokenRetries += 1

            // We have to return the token but don't attempt to refresh again
            // Pass true to the callback to signal that we should stop the connection
            if tokenRetries > maxTokenRetries {
                tokenRefreshHandler(true, nil)
                return token
            }

            // Fetch new token
            credential.token { token, error in
                // Let callback know we are attempting to refresh
                self.tokenRefreshHandler(false, error)
                guard let newToken = token?.token else {
                    return
                }
                // Cache the new token
                self.token = newToken
            }
        } else {
            tokenRetries = 0
        }

        return token
    }

    /// Initialize CommunicationSkypetokenProvider
    /// - Parameters:
    ///   - token: The token to cache.
    ///   - credential: CommunicationTokenCredential for refreshing the token.
    ///   - tokenRefreshHandler: Called when the token is expired, stopSignalingClient will be true if retry attempts
    /// are exceeded.
    init(
        token: String,
        credential: CommunicationTokenCredential,
        tokenRefreshHandler: @escaping TrouterTokenRefreshHandler
    ) {
        self.token = token
        self.credential = credential
        self.tokenRefreshHandler = tokenRefreshHandler
        self.tokenRetries = 0
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
        do {
            logger.info("Trouter Connected")
            let chatEvent = try TrouterEventUtil.create(chatEvent: ChatEventId.realTimeNotificationConnected, from: nil)
            handler(chatEvent)
        } catch {
            logger.error("Error: \(error)")
        }
    }

    func onTrouterDisconnected() {
        do {
            logger.info("Trouter Disconnected")
            let chatEvent = try TrouterEventUtil.create(
                chatEvent: ChatEventId.realTimeNotificationDisconnected,
                from: nil
            )
            handler(chatEvent)
        } catch {
            logger.error("Error: \(error)")
        }
    }

    func onTrouterRequest(_ request: TrouterRequest, _ response: TrouterResponse) {
        logger.info("Received a Trouter request \n")

        do {
            guard let requestJsonData = request.body.data(using: .utf8) else {
                throw AzureError.client("Unable to convert request body to Data.")
            }

            let generalPayload = try JSONDecoder().decode(BasePayload.self, from: requestJsonData)
            let chatEventId = try ChatEventId(forCode: generalPayload.eventId)

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


