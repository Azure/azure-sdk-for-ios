**PROTOCOL**

# `PagedCollectionDelegate`

```swift
public protocol PagedCollectionDelegate: AnyObject
```

> Protocol which allows clients to customize how they work with Paged Collections.

## Methods
### `continuationUrl(continuationToken:queryParams:requestUrl:)`

```swift
func continuationUrl(continuationToken: String, queryParams: inout [String: String], requestUrl: String) -> String
```
