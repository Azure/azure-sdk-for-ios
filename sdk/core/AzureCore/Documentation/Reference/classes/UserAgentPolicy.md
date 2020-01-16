**CLASS**

# `UserAgentPolicy`

```swift
public class UserAgentPolicy: PipelineStage
```

## Properties
### `next`

```swift
public var next: PipelineStage?
```

### `userAgentOverwrite`

```swift
public let userAgentOverwrite: Bool
```

### `userAgent`

```swift
public var userAgent: String
```

## Methods
### `init(baseUserAgent:userAgentOverwrite:)`

```swift
public init(baseUserAgent: String? = nil, userAgentOverwrite: Bool = false)
```

### `appendUserAgent(value:)`

```swift
public func appendUserAgent(value: String)
```

### `on(request:then:)`

```swift
public func on(request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| request | The `PipelineRequest` input. |
| completion | A completion handler which forwards the modified request. |