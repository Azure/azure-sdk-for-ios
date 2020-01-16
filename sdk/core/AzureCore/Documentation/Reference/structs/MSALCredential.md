**STRUCT**

# `MSALCredential`

```swift
public struct MSALCredential: TokenCredential
```

> An MSAL credential object.

## Methods
### `init(tenant:clientId:authority:redirectUri:account:)`

```swift
public init(tenant: String, clientId: String, authority: String, redirectUri: String? = nil,
            account: MSALAccount? = nil) throws
```

> Create an OAuth credential.
> - Parameters:
>   - tenant: Tenant ID (a GUID) for the AAD instance.
>   - clientId: The service principal client or application ID (a GUID).
>   - authority: An authority URI for the application.
>   - redirectUri: An optional redirect URI for the application.
>   - account: Initial value of the `MSALAccount` object, if known.

#### Parameters

| Name | Description |
| ---- | ----------- |
| tenant | Tenant ID (a GUID) for the AAD instance. |
| clientId | The service principal client or application ID (a GUID). |
| authority | An authority URI for the application. |
| redirectUri | An optional redirect URI for the application. |
| account | Initial value of the `MSALAccount` object, if known. |

### `init(tenant:clientId:application:account:)`

```swift
public init(tenant: String, clientId: String, application: MSALPublicClientApplication,
            account: MSALAccount? = nil)
```

> Create an OAuth credential.
> - Parameters:
>   - tenant: Tenant ID (a GUID) for the AAD instance.
>   - clientId: The service principal client or application ID (a GUID).
>   - application: An `MSALPublicClientApplication` object.
>   - account: Initial value of the `MSALAccount` object, if known.

#### Parameters

| Name | Description |
| ---- | ----------- |
| tenant | Tenant ID (a GUID) for the AAD instance. |
| clientId | The service principal client or application ID (a GUID). |
| application | An `MSALPublicClientApplication` object. |
| account | Initial value of the `MSALAccount` object, if known. |

### `token(forScopes:then:)`

```swift
public func token(forScopes scopes: [String], then completion: @escaping (AccessToken?) -> Void)
```

> Retrieve a token for the provided scope.
> - Parameters:
>   - scopes: A list of a scope strings for which to retrieve the token.
>   - completion: A completion handler which forwards the access token.

#### Parameters

| Name | Description |
| ---- | ----------- |
| scopes | A list of a scope strings for which to retrieve the token. |
| completion | A completion handler which forwards the access token. |