# AzurePush

![Current State: Preview Release](https://img.shields.io/badge/Current_State-Preview_Release-brightgreen.svg)

The SDK for Azure Notification Hubs (which can be found [here](https://github.com/Azure/azure-notificationhubs/tree/master/iOS/WindowsAzureMessaging)) has been refactored to ensure its API works seamlessly with the other SDKs in AzureMobile and to provide the best possible developer experience; the result is AzurePush.

AzurePush provides push notification functionality through the [Azure Notification Hubs](https://docs.microsoft.com/en-us/azure/notification-hubs/).

# Configure

Before using ` AzurePush`, you will need to configure it with your Azure notification hub name and connection string using the `AzurePush.configure` function. We recommend doing this in `application(_:didFinishLaunchingWithOptions:)`.

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    AzurePush.configure(withHubName: "<Notification Hub Name>", andConnectionString: "<Connection String>")
}
```

# Usage

## Native Device Registration

To [register a device with a notification hub](https://docs.microsoft.com/en-us/azure/notification-hubs/notification-hubs-push-notification-registration-management#what-is-device-registration), call `AzurePush.registerForRemoteNotifications(withDeviceToken:tags:completion:)` in `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`.

```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    AzurePush.registerForRemoteNotifications(withDeviceToken: deviceToken, tags: []) { r in 
        // successful registration = r.resource
    }
}
```

## Template Device Registration

[Templates](https://docs.microsoft.com/en-us/azure/notification-hubs/notification-hubs-templates-cross-platform-push-messages) enable a client application to specify the exact format of the notifications it wants to receive.

To register a device using a template, first create a `Template` object, then call `AzurePush.registerForRemoteNotifications(withDeviceToken:usingTemplate:tags:completion)`.

```swift
let template = Registration.Template(
    name: "<template name>"
    body: "<template body in template expression language>"
    expiry: "<expiry>"
)
```

```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    AzurePush.registerForRemoteNotifications(withDeviceToken: deviceToken, usingTemplate: template, tags: []) { r in 
        // successful registration = r.resource
    }
}
```

## Unregistration

To cancel a native registration, use `AzurePush.unregisterForRemoteNotifications(completion:)`.

```swift
AzurePush.unregisterForRemoteNotifications { r in 
    // r.result.isSuccess == successfully registered
}
```

To cancel a template registration, use `AzurePush.unregisterForRemoteNotifications(forRegistrationWithTemplateNamed:completion:)`.

```swift
AzurePush.unregisterForRemoteNotifications(forRegistrationWithTemplateNamed: "<template name>") { r in 
    // r.result.isSuccess == successfully registered
}
```
