**CLASS**

# `PipelineContext`

```swift
public class PipelineContext
```

## Methods
### `of(keyValues:)`

```swift
public static func of(keyValues: [AnyHashable: AnyObject]) -> PipelineContext
```

### `add(value:forKey:)`

```swift
public func add(value: AnyObject, forKey key: AnyHashable)
```

### `add(value:forKey:)`

```swift
public func add(value: AnyObject, forKey key: ContextKey)
```

### `value(forKey:)`

```swift
public func value(forKey key: AnyHashable) -> AnyObject?
```

### `value(forKey:)`

```swift
public func value(forKey key: ContextKey) -> AnyObject?
```
