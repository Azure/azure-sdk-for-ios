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
import UIKit
import UserNotifications
import AzureCommunicationChat
import AzureCommunicationCommon

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let token = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwM19pbnQiLCJ4NXQiOiJlU0t5M1lPd2FzazIxN3ZKWmVWZFhOcDBSNm8iLCJ0eXAiOiJKV1QifQ.eyJza3lwZWlkIjoiYWNzOjE4OGQ0Y2VhLTBhOWItNDg0MC04ZmRjLTdhNWM3MWZlOWJkMF8wMDAwMDAwZi1hNGYyLWExNDYtMGY5Yy0wOTQ4MjIwMDExNGEiLCJzY3AiOjE3OTIsImNzaSI6IjE2NDUwNTc1MjMiLCJleHAiOjE2NDUxNDM5MjMsImFjc1Njb3BlIjoiY2hhdCIsInJlc291cmNlSWQiOiIxODhkNGNlYS0wYTliLTQ4NDAtOGZkYy03YTVjNzFmZTliZDAiLCJpYXQiOjE2NDUwNTc1MjN9.aZMQRQPmGCUEG4NLT-4JtY0qY8wFMKy8qrZFk9WnRXIF198BLTA4m1ir41yLkHiSxGPhM0gvlLBXvFBiWFPRRkGioxY2UnH9L7lR0bZTCJvrbqzMISo-jWTZh5yjZ2BspiF_vvKqeiV0wo0xb_hNOhpY-VUJkx66UUpuicu-xHtJti3-jJ2nCtpLURCoRYG8JIZb9f4Z6-mRbWfEyh3gTUKlTvexCI8B4ISlM-zl9ryp_rhyRm2n15Sh0QEET4eKvMozjHDtGTFLa5bfDGKBg95BVn_ugW9LdEwu4Pi1wswpDm3eNhZRN_nVDZdj8rw32jWUg1uitWP00jiLnqOH4g"
    
    let endpoint = "https://chat-int-runner.int.communication.azure.net"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerForPushNotifications()
        // Check if launched from notification
        let notificationOption = launchOptions?[.remoteNotification]
        // 1
        if let notification = notificationOption as? [String: AnyObject], let aps = notification["aps"] as? [String: AnyObject] {
            print("received notification")
            print(aps)
            print(notification)
        }
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self?.getNotificationSettings()
        }
    }

    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        UserDefaults.standard.set(token, forKey: "APNSToken")
        do {
            let credential = try CommunicationTokenCredential(token: self.token)
            let options = AzureCommunicationChatClientOptions()
            let chatClient = try ChatClient(endpoint: self.endpoint, credential: credential, withOptions: options)
            
            // Start push notifications
            guard let apnsToken = UserDefaults.standard.string(forKey: "APNSToken") else {
                print("Failed to get APNS token")
                return
            }

            let semaphore = DispatchSemaphore(value: 0)
            DispatchQueue.global(qos: .background).async {
                chatClient.startPushNotifications(deviceToken: apnsToken) { result in
                    switch result {
                    case .success:
                        print("Started Push Notifications")
                    case let .failure(error):
                        print("Failed To Start Push Notifications: \(error)")
                    }
                    semaphore.signal()
                }
                semaphore.wait()
            }
        } catch {
            print("Failed Push Notification Test")
        }
    }

    func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register: \(error)")
    }
    func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler:
    @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }

        print("received notification")
        print(aps)
        print(userInfo)

        do {
            let credential = try CommunicationTokenCredential(token: self.token)
            let options = AzureCommunicationChatClientOptions()
            let chatClient = try ChatClient(endpoint: self.endpoint, credential: credential, withOptions: options)
            
            // Handle push
            chatClient.handlePush(notification: userInfo, completionHandler: self.pushHandler)
            
        } catch {
            print("failed to handle push")
        }
    }
        
    func pushHandler(event: PushNotificationEvent?, error: Error?) {
        // Handle notifications
    }
}



