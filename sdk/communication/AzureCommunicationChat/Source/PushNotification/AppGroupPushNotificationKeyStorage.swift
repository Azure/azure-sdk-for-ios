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

public class AppGroupPushNotificationKeyStorage: PushNotificationKeyStorage {
    var sharedDefault: UserDefaults
    var keyTag: String

    public init?(appGroupId: String, keyTag: String) throws {
        guard let shareDefault = UserDefaults(suiteName: appGroupId) else {
            throw AzureError
                .client(
                    "Failed to init AppGroupPushNotificationKeyStorage. The UserDefaults doesn't exist for the app group ID."
                )
        }
        self.sharedDefault = shareDefault
        self.keyTag = keyTag
    }

    public func onPersistKey(_ encryptionKey: String, expiryTime: Date) throws {
        // 1.Retrieve the existing key dictionary from app group
        var prevKeyDict = sharedDefault.dictionary(forKey: keyTag)

        // If this is the first time we store the key, we'll need to create a new key dictionary
        if prevKeyDict == nil {
            prevKeyDict = [:]
        }

        guard var keyDict = prevKeyDict as? [String: Date] else {
            throw AzureError
                .client(
                    "Failed to persist encryption key. The format of the existing key dictionary in UserDefaults doesn't match [String: Date]."
                )
        }

        // 2.Insert a new key-value pair([current encryption key - current time]) into the dictionary
        keyDict[encryptionKey] = expiryTime

        // 3.Remove the expired key-value pairs from dictionary
        for (key, expiryTime) in keyDict {
            let curTime = Date()
            if expiryTime <= curTime {
                keyDict.removeValue(forKey: key)
            }
        }

        // 4.Store the updated dictionary into App Group
        sharedDefault.set(keyDict, forKey: keyTag)
    }

    public func onRetrieveKeys() throws -> [String] {
        // 1.Retrieve the existing key dictionary from app group
        guard let prevKeyDict = sharedDefault.dictionary(forKey: keyTag) else {
            throw AzureError
                .client(
                    "There is no encryption key in UserDefaults."
                )
        }

        guard var keyDict = prevKeyDict as? [String: Date] else {
            throw AzureError
                .client(
                    "Failed to retrieve encryption key. The format of the existing key dictionary in UserDefaults doesn't match [String: Date]."
                )
        }

        var decryptionKeys: [String] = []
        let curTime = Date()

        // 2.Iterate over the key-value pairs in the existing key dictionary:
        //   if the key has not expired, add the encryption key in the key array
        //   if the key has expired, remove the K-V pair from the existing dictionary
        for (key, expiryTime) in keyDict {
            if expiryTime > curTime {
                decryptionKeys.append(key)
            } else {
                keyDict.removeValue(forKey: key)
            }
        }

        guard decryptionKeys.count > 0 else {
            throw AzureError.client("All encryption keys in UserDefaults expire.")
        }

        // 3.Store the updated dictionary into App Group
        sharedDefault.set(keyDict, forKey: keyTag)

        // 4.Return the key array
        return decryptionKeys
    }
}
