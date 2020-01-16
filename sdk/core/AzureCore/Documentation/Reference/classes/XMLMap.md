**CLASS**

# `XMLMap`

```swift
public class XMLMap: Sequence, IteratorProtocol
```

> A map of XML document path keys and metadata needed to convert an XML
> payload into a JSON payload.

## Methods
### `init(_:)`

```swift
public init(_ existingValues: [String: XMLMetadata])
```

> Initialize directly with paths and values

### `init(withPagedCodingKeys:innerType:)`

```swift
public init(withPagedCodingKeys codingKeys: PagedCodingKeys, innerType: XMLModel.Type)
```

> Generate XML map for PagedCollection types.

### `next()`

```swift
public func next() -> (String, XMLMetadata)?
```
