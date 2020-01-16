**CLASS**

# `KeychainUtil`

```swift
public class KeychainUtil
```

## Methods
### `store(string:forKey:)`

```swift
public func store(string: String, forKey key: String) throws
```

### `store(secret:forKey:)`

```swift
public func store(secret: Data, forKey key: String) throws
```

### `secret(forKey:)`

```swift
public func secret(forKey key: String) throws -> Data
```

### `string(forKey:)`

```swift
public func string(forKey key: String) throws -> String
```

### `deleteSecret(forKey:)`

```swift
public func deleteSecret(forKey key: String) throws
```
