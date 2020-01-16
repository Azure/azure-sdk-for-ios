**ENUM**

# `CryptoAlgorithm`

```swift
public enum CryptoAlgorithm
```

> Crypto HMAC algorithms and digest lengths

## Cases
### `sha1`

```swift
case sha1, md5, sha256, sha384, sha512, sha224
```

## Properties
### `hmacAlgorithm`

```swift
public var hmacAlgorithm: CCHmacAlgorithm
```

> Underlying CommonCrypto HMAC algorithm.

### `digestLength`

```swift
public var digestLength: Int
```

> Digest length for the HMAC algorithm.

## Methods
### `hash(_:_:_:)`

```swift
public func hash(_ data: UnsafeRawPointer!, _ len: CC_LONG, _ message: UnsafeMutablePointer<UInt8>!) -> Data
```

> Compute a hash of the underlying data using the specfied algorithm.
