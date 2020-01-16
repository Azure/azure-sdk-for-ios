**EXTENSION**

# `PipelineStage`

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

### `on(response:then:)`

```swift
public func on(response: PipelineResponse, then completion: @escaping OnResponseCompletionHandler)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| response | The `PipelineResponse` input. |
| completion | A completion handler which forwards the modified response. |

### `on(error:then:)`

```swift
public func on(error: PipelineError, then completion: @escaping OnErrorCompletionHandler)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| error | The `PipelineError` input. |
| completion | A completion handler which forwards the error along with a boolean that indicates whether the exception was handled or not. |

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