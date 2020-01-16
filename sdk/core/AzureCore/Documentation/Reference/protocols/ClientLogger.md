**PROTOCOL**

# `ClientLogger`

```swift
public protocol ClientLogger
```

## Properties
### `level`

```swift
var level: ClientLogLevel
```

## Methods
### `debug(_:)`

```swift
func debug(_: @autoclosure @escaping () -> String?)
```

### `info(_:)`

```swift
func info(_: @autoclosure @escaping () -> String?)
```

### `warning(_:)`

```swift
func warning(_: @autoclosure @escaping () -> String?)
```

### `error(_:)`

```swift
func error(_: @autoclosure @escaping () -> String?)
```

### `log(_:atLevel:)`

```swift
func log(_: @escaping () -> String?, atLevel: ClientLogLevel)
```
