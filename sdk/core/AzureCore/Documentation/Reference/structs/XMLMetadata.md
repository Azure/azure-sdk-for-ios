**STRUCT**

# `XMLMetadata`

```swift
public struct XMLMetadata
```

> Class containing metadata needed to translate an XML payload into the desired
> JSON payload.

## Properties
### `jsonName`

```swift
public let jsonName: String
```

### `jsonType`

```swift
public let jsonType: ElementToJsonStrategy
```

### `attributeStrategy`

```swift
public let attributeStrategy: AttributeToJsonStrategy
```

## Methods
### `init(jsonName:jsonType:attributes:)`

```swift
public init(jsonName: String, jsonType: ElementToJsonStrategy = .property,
            attributes: AttributeToJsonStrategy = .ignored)
```
