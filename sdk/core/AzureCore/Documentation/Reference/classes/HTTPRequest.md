**CLASS**

# `HTTPRequest`

```swift
public class HTTPRequest: DataStringConvertible
```

## Properties
### `httpMethod`

```swift
public let httpMethod: HTTPMethod
```

### `url`

```swift
public var url: String
```

### `headers`

```swift
public var headers: HTTPHeaders
```

### `files`

```swift
public var files: [String]?
```

### `data`

```swift
public var data: Data?
```

### `query`

```swift
public var query: [URLQueryItem]?
```

## Methods
### `init(method:url:queryParams:headers:files:data:)`

```swift
public init(method: HTTPMethod, url: String,
            queryParams: [String: String], headers: HTTPHeaders,
            files: [String]? = nil, data: Data? = nil)
```

### `update(queryParams:)`

```swift
public func update(queryParams: [String: String]?)
```
