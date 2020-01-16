**CLASS**

# `PipelineClient`

```swift
open class PipelineClient
```

> Base class for all pipeline-based service clients.

## Properties
### `baseUrl`

```swift
public var baseUrl: String
```

### `logger`

```swift
public var logger: ClientLogger
```

## Methods
### `init(baseUrl:transport:policies:logger:)`

```swift
public init(baseUrl: String, transport: HTTPTransportStage, policies: [PipelineStage],
            logger: ClientLogger)
```

### `url(forTemplate:withKwargs:)`

```swift
public func url(forTemplate templateIn: String, withKwargs kwargs: [String: String]? = nil) -> String
```

### `request(_:context:then:)`

```swift
public func request(_ request: HTTPRequest,
                    context: PipelineContext?,
                    then completion: @escaping (Result<Data?, Error>, HTTPResponse) -> Void)
```
