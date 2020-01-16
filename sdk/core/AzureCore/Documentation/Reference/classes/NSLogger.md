**CLASS**

# `NSLogger`

```swift
public class NSLogger: ClientLogger
```

## Properties
### `level`

```swift
public var level: ClientLogLevel
```

## Methods
### `init(tag:level:)`

```swift
public init(tag: String? = nil, level: ClientLogLevel = .info)
```

### `log(_:atLevel:)`

```swift
public func log(_ message: () -> String?, atLevel messageLevel: ClientLogLevel)
```
