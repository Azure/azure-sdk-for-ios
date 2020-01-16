**CLASS**

# `PagedCollection`

```swift
public class PagedCollection<SingleElement: Codable>: PagedCollectionDelegate
```

> A collection that fetches paged results in a lazy fashion.

## Properties
### `items`

```swift
public var items: Element?
```

> Returns the current running list of items.

### `pageItems`

```swift
public var pageItems: Element?
```

> Returns the subset of items that corresponds to the current page.

### `underestimatedCount`

```swift
public var underestimatedCount: Int
```

## Methods
### `init(client:request:data:codingKeys:decoder:delegate:)`

```swift
public init(client: PipelineClient, request: HTTPRequest, data: Data?, codingKeys: PagedCodingKeys? = nil,
            decoder: JSONDecoder? = nil, delegate: PagedCollectionDelegate? = nil) throws
```

### `nextPage(then:)`

```swift
public func nextPage(then completion: @escaping (Result<Element?, Error>) -> Void)
```

> Retrieves the next page of results asynchronously.

### `nextItem(then:)`

```swift
public func nextItem(then completion: @escaping (Result<SingleElement?, Error>) -> Void)
```

> Retrieves the next item in the collection, automatically fetching new pages when needed.

### `continuationUrl(continuationToken:queryParams:requestUrl:)`

```swift
public func continuationUrl(continuationToken: String, queryParams _: inout [String: String],
                            requestUrl _: String) -> String
```

> Format a URL for a paged response using a provided continuation token.
