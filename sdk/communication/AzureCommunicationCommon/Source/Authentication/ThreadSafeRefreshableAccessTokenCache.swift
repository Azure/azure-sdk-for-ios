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

#if canImport(AzureCore)
    import AzureCore
#endif
import Foundation

internal class ThreadSafeRefreshableAccessTokenCache {
    private var currentToken: CommunicationAccessToken {
        didSet {
            maybeScheduleRefresh()
        }
    }

    private let scheduleProactivelyRefreshing: Bool
    private var proactiveRefreshTimer: Timer?

    private let proactiveRefreshingInterval = TimeInterval(600)
    private let onDemandRefreshingInterval = TimeInterval(120)

    private let tokenRefresher: TokenRefreshAction

    private typealias TimerAction = () -> Void
    internal typealias AccessTokenRefreshAction = (@escaping CommunicationTokenCompletionHandler) -> Void
    internal typealias TokenRefreshAction = (@escaping TokenRefreshHandler) -> Void

    public convenience init(refreshProactively: Bool, tokenRefresher: @escaping TokenRefreshAction) {
        self.init(
            refreshProactively: refreshProactively,
            initialValue: CommunicationAccessToken(token: "", expiresOn: Date()),
            tokenRefresher: tokenRefresher
        )
    }

    public init(
        refreshProactively: Bool,
        initialValue: CommunicationAccessToken,
        tokenRefresher: @escaping TokenRefreshAction
    ) {
        self.scheduleProactivelyRefreshing = refreshProactively
        self.currentToken = initialValue
        self.tokenRefresher = tokenRefresher

        // didSet is not called from the initialization context
        maybeScheduleRefresh()
    }

    private func refreshAccessToken(completionHandler: @escaping CommunicationTokenCompletionHandler) {
        tokenRefresher { newToken, error in
            if let error = error {
                completionHandler(nil, error)
                return
            }

            do {
                let newAccessToken = try JwtTokenParser.createAccessToken(newToken!)
                completionHandler(newAccessToken, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }

    let anyThreadRefreshing = DispatchSemaphore(value: 1)
    public func getValue(
        _ completionHandler: @escaping CommunicationTokenCompletionHandler
    ) {
        if !shouldRefresh() {
            completionHandler(currentToken, nil)
            return
        }

        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.anyThreadRefreshing.wait()

            guard let self = self else { return }

            defer { self.anyThreadRefreshing.signal() }

            if !self.shouldRefresh() {
                completionHandler(self.currentToken, nil)
                return
            }

            self.refreshAccessToken { [weak self] accessToken, error in
                guard let self = self else { return }

                if error != nil {
                    completionHandler(nil, error)
                    return
                }

                self.currentToken = accessToken!
                completionHandler(self.currentToken, nil)
            }
        }
    }

    private func shouldRefresh() -> Bool {
        if currentToken.token.isEmpty {
            return true
        }

        let timeInterval = scheduleProactivelyRefreshing
            ? -proactiveRefreshingInterval
            : -onDemandRefreshingInterval

        return Date() >= currentToken.expiresOn.addingTimeInterval(timeInterval)
    }

    private func maybeScheduleRefresh() {
        if !scheduleProactivelyRefreshing {
            return
        }

        let actionPeriod = shouldRefresh()
            ? TimeInterval.zero
            : (currentToken.expiresOn - proactiveRefreshingInterval).timeIntervalSinceNow

        proactiveRefreshTimer?.invalidate()

        proactiveRefreshTimer = Timer.scheduledTimer(withTimeInterval: actionPeriod, repeats: false) { [weak self] _ in
            self?.getValue { _, _ in }
        }
    }

    deinit {
        proactiveRefreshTimer?.invalidate()
    }
}
