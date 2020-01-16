**ENUM**

# `HTTPResponseError`

```swift
public enum HTTPResponseError: Error
```

## Cases
### `general(_:)`

```swift
case general(String)
```

### `decode(_:)`

```swift
case decode(String)
```

### `resourceExists(_:)`

```swift
case resourceExists(String)
```

### `resourceNotFound(_:)`

```swift
case resourceNotFound(String)
```

### `clientAuthentication(_:)`

```swift
case clientAuthentication(String)
```

### `resourceModified(_:)`

```swift
case resourceModified(String)
```

### `tooManyRedirects(_:)`

```swift
case tooManyRedirects(String)
```

### `statusCode(_:)`

```swift
case statusCode(String)
```
