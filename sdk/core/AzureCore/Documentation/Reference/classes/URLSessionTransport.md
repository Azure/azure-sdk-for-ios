**CLASS**

# `URLSessionTransport`

```swift
public class URLSessionTransport: HTTPTransportStage
```

## Properties
### `next`

```swift
public var next: PipelineStage?
```

## Methods
### `init()`

```swift
public init()
```

### `open()`

```swift
public func open()
```

### `close()`

```swift
public func close()
```

### `sleep(duration:)`

```swift
public func sleep(duration: Int)
```

### `process(request:then:)`

```swift
public func process(request pipelineRequest: PipelineRequest,
                    then completion: @escaping PipelineStageResultHandler)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| pipelineRequest | The `PipelineRequest` input. |
| completion | A `PipelineStageResultHandler` completion handler. |