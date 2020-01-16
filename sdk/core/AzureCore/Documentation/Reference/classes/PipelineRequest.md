**CLASS**

# `PipelineRequest`

```swift
public final class PipelineRequest: Copyable, PipelineContextSupporting
```

## Properties
### `httpRequest`

```swift
public var httpRequest: HTTPRequest
```

### `logger`

```swift
public var logger: ClientLogger
```

### `context`

```swift
public var context: PipelineContext?
```

## Methods
### `init(request:logger:)`

```swift
public convenience init(request: HTTPRequest, logger: ClientLogger)
```

### `init(request:logger:context:)`

```swift
public init(request: HTTPRequest, logger: ClientLogger, context: PipelineContext?)
```

### `init(copy:)`

```swift
public required convenience init(copy: PipelineRequest)
```
