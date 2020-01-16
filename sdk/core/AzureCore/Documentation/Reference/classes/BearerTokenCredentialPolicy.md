**CLASS**

# `BearerTokenCredentialPolicy`

```swift
public class BearerTokenCredentialPolicy: Authenticating
```

## Properties
### `next`

```swift
public var next: PipelineStage?
```

## Methods
### `init(credential:scopes:)`

```swift
public init(credential: TokenCredential, scopes: [String])
```

### `authenticate(request:then:)`

```swift
public func authenticate(request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler)
```

> Authenticates an HTTP `PipelineRequest` with an OAuth token.
> - Parameters:
>   - request: A `PipelineRequest` object.
>   - completion: A completion handler that forwards the modified pipeline request.

#### Parameters

| Name | Description |
| ---- | ----------- |
| request | A `PipelineRequest` object. |
| completion | A completion handler that forwards the modified pipeline request. |

### `on(request:then:)`

```swift
public func on(request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler)
```

> Authenticates an HTTP `PipelineRequest` with an OAuth token.
> - Parameters:
>   - request: A `PipelineRequest` object.
>   - completion: A completion handler that forwards the modified pipeline request.

#### Parameters

| Name | Description |
| ---- | ----------- |
| request | A `PipelineRequest` object. |
| completion | A completion handler that forwards the modified pipeline request. |