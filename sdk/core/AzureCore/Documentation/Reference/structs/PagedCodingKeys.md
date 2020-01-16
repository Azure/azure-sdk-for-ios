**STRUCT**

# `PagedCodingKeys`

```swift
public struct PagedCodingKeys
```

> Defines the property keys used to conform to the Azure paging design.

## Properties
### `items`

```swift
public let items: String
```

### `xmlItemName`

```swift
public let xmlItemName: String?
```

### `continuationToken`

```swift
public let continuationToken: String
```

## Methods
### `init(items:continuationToken:xmlItemName:)`

```swift
public init(items: String = "items", continuationToken: String = "continuationToken",
            xmlItemName xmlName: String? = nil)
```
