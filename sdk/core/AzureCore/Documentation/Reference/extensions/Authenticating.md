**EXTENSION**

# `Authenticating`

## Methods
### `on(request:then:)`

```swift
public func on(request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| request | The `PipelineRequest` input. |
| completion | A completion handler which forwards the modified request. |