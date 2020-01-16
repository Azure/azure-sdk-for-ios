**CLASS**

# `HeadersPolicy`

```swift
public class HeadersPolicy: PipelineStage
```

## Properties
### `next`

```swift
public var next: PipelineStage?
```

### `headers`

```swift
public var headers: HTTPHeaders
```

## Methods
### `init(baseHeaders:)`

```swift
public init(baseHeaders: HTTPHeaders? = nil)
```

### `add(header:value:)`

```swift
public func add(header: HTTPHeader, value: String)
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