**PROTOCOL**

# `ObjectiveCBridgeable`

```swift
public protocol ObjectiveCBridgeable
```

> This protocol is used internally to expose a Swift
> type to a type that is representable in Objective-C
> as the type `ObjectiveCType` or one of its subclasses.

## Methods
### `init(bridgedFromObjectiveC:)`

```swift
init(bridgedFromObjectiveC: ObjectiveCType)
```

> Reconstructs a Swift value of type `Self`
> from its corresponding value of type
> `ObjectiveCType`.

### `bridgeToObjectiveC()`

```swift
func bridgeToObjectiveC() -> ObjectiveCType
```

> Converts `self` to its corresponding
> `ObjectiveCType`.
