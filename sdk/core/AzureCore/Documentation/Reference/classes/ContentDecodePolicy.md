**CLASS**

# `ContentDecodePolicy`

```swift
public class ContentDecodePolicy: PipelineStage
```

## Properties
### `next`

```swift
public var next: PipelineStage?
```

### `jsonRegex`

```swift
public let jsonRegex = NSRegularExpression("^(application|text)/([0-9a-z+.]+)?json$")
```

### `logger`

```swift
public var logger: ClientLogger?
```

## Methods
### `init()`

```swift
public init()
```

### `on(response:then:)`

```swift
public func on(response: PipelineResponse, then completion: @escaping OnResponseCompletionHandler)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| response | The `PipelineResponse` input. |
| completion | A completion handler which forwards the modified response. |