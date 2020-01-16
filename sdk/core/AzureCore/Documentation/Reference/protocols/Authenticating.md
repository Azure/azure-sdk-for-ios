**PROTOCOL**

# `Authenticating`

```swift
public protocol Authenticating: PipelineStage
```

## Methods
### `authenticate(request:then:)`

```swift
func authenticate(request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler)
```
