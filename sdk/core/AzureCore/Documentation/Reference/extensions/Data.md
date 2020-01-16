**EXTENSION**

# `Data`

## Properties
### `base64String`

```swift
public var base64String: String
```

> Returns the base64-encoded string representation of a `Data` object.

### `hexString`

```swift
public var hexString: String
```

> Returns the hex string representation of a `Data` object.

## Methods
### `hmac(algorithm:key:)`

```swift
public func hmac(algorithm: CryptoAlgorithm, key: Data) throws -> Data
```

> Calculate the HMAC digest of data.
> - Parameter algorithm: The HMAC algorithm to use.
> - Parameter key: The key used to compute the HMAC, in `Data` format.
> - Returns: The HMAC digest in `Data` format.

#### Parameters

| Name | Description |
| ---- | ----------- |
| algorithm | The HMAC algorithm to use. |
| key | The key used to compute the HMAC, in `Data` format. |

### `hash(algorithm:)`

```swift
public func hash(algorithm: CryptoAlgorithm) throws -> Data
```

> Compute the hash function of a string.
> - Parameter algorithm: The cryptographic algorithm to use.
> - Returns: The hash digest in `Data` format. This can then be converted to a base64 or hex
>            string using the `base64String` or `hexString` extension methods.

#### Parameters

| Name | Description |
| ---- | ----------- |
| algorithm | The cryptographic algorithm to use. |