**CLASS**

# `HTTPResponse`

```swift
public class HTTPResponse: DataStringConvertible
```

## Properties
### `httpRequest`

```swift
public var httpRequest: HTTPRequest?
```

### `statusCode`

```swift
public var statusCode: Int?
```

### `headers`

```swift
public var headers = HTTPHeaders()
```

### `blockSize`

```swift
public var blockSize: Int
```

### `data`

```swift
public var data: Data?
```

## Methods
### `init(request:statusCode:blockSize:)`

```swift
public init(request: HTTPRequest, statusCode: Int?, blockSize: Int = 4096)
```
