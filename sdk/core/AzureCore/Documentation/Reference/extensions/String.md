**EXTENSION**

# `String`

## Properties
### `base64String`

```swift
public var base64String: String
```

> Returns the base64 representation of a string.

### `decodeHex`

```swift
public var decodeHex: Data?
```

> Returns the decoded `Data` of a hex string, or nil.

### `decodeBase64`

```swift
public var decodeBase64: Data?
```

> Returns the decoded `Data` of a base64-encoded string, or nil.

### `rfc1123Date`

```swift
public var rfc1123Date: Date?
```

## Methods
### `hmac(algorithm:key:)`

```swift
public func hmac(algorithm: CryptoAlgorithm, key: Data) throws -> Data
```

> Calculate the HMAC digest of a string.
> - Parameter algorithm: The cryptographic algorithm to use.
> - Parameter key: The key used to compute the HMAC, in `Data` format.
> - Returns: The HMAC digest in `Data` format.

#### Parameters

| Name | Description |
| ---- | ----------- |
| algorithm | The cryptographic algorithm to use. |
| key | The key used to compute the HMAC, in `Data` format. |

### `hash(algorithm:)`

```swift
public func hash(algorithm: CryptoAlgorithm) throws -> Data
```

> Compute the hash function of a string.
> - Parameter algorithm: The cryptographic algorithm to use.
> - Returns: The hash digest in `Data` format. This can then be converted to a base64 or hex string using the
>    `base64String` or `hexString` extension methods.

#### Parameters

| Name | Description |
| ---- | ----------- |
| algorithm | The cryptographic algorithm to use. |

### `parseQueryString()`

```swift
public func parseQueryString() -> [String: String]?
```

> Parses a query string into a dictionary of key-value pairs.
