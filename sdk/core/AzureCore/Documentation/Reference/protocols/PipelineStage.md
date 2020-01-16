**PROTOCOL**

# `PipelineStage`

```swift
public protocol PipelineStage
```

> Protocol for implementing pipeline stages.

## Properties
### `next`

```swift
var next: PipelineStage?
```

## Methods
### `on(request:then:)`

```swift
func on(request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler)
```

> Request modification hook.
> - Parameters:
>   - request: The `PipelineRequest` input.
>   - completion: A completion handler which forwards the modified request.

#### Parameters

| Name | Description |
| ---- | ----------- |
| request | The `PipelineRequest` input. |
| completion | A completion handler which forwards the modified request. |

### `on(response:then:)`

```swift
func on(response: PipelineResponse, then completion: @escaping OnResponseCompletionHandler)
```

> Response modification hook.
> - Parameters:
>   - response: The `PipelineResponse` input.
>   - completion: A completion handler which forwards the modified response.

#### Parameters

| Name | Description |
| ---- | ----------- |
| response | The `PipelineResponse` input. |
| completion | A completion handler which forwards the modified response. |

### `on(error:then:)`

```swift
func on(error: PipelineError, then completion: @escaping OnErrorCompletionHandler)
```

> Response error hook.
> - Parameters:
>   - error: The `PipelineError` input.
>   - completion: A completion handler which forwards the error along with a boolean
>   that indicates whether the exception was handled or not.

#### Parameters

| Name | Description |
| ---- | ----------- |
| error | The `PipelineError` input. |
| completion | A completion handler which forwards the error along with a boolean that indicates whether the exception was handled or not. |

### `process(request:then:)`

```swift
func process(request pipelineRequest: PipelineRequest, then completion: @escaping PipelineStageResultHandler)
```

> Executes the policy method.
> - Parameters:
>   - pipelineRequest: The `PipelineRequest` input.
>   - completion: A `PipelineStageResultHandler` completion handler.

#### Parameters

| Name | Description |
| ---- | ----------- |
| pipelineRequest | The `PipelineRequest` input. |
| completion | A `PipelineStageResultHandler` completion handler. |