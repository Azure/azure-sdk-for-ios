**CLASS**

# `OSLogger`

```swift
public class OSLogger: ClientLogger
```

## Properties
### `level`

```swift
public var level: ClientLogLevel
```

## Methods
### `init(withLogger:level:)`

```swift
public init(withLogger osLogger: OSLog, level: ClientLogLevel = .info)
```

### `init(subsystem:category:level:)`

```swift
public init(
    subsystem: String = "com.azure",
    category: String? = nil,
    level: ClientLogLevel = .info
)
```

### `log(_:atLevel:)`

```swift
public func log(_ message: () -> String?, atLevel messageLevel: ClientLogLevel)
```
