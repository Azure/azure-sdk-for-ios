**STRUCT**

# `ApplicationUtil`

```swift
public struct ApplicationUtil
```

## Methods
### `currentViewController(forParent:)`

```swift
public static func currentViewController(forParent parent: UIViewController? = nil) -> UIViewController?
```

> Returns the current `UIViewController` for a parent controller.
> - Parameter parent: The parent `UIViewController`. If none provided, will attempt to discover the most
> relevant controller.

#### Parameters

| Name | Description |
| ---- | ----------- |
| parent | The parent `UIViewController`. If none provided, will attempt to discover the most relevant controller. |

### `currentViewController(withRootViewController:)`

```swift
public static func currentViewController(withRootViewController root: UIViewController?) -> UIViewController?
```

> Attempt to find the top-most view controller for a given root view controller.
> - Parameter root: The root `UIViewController`.

#### Parameters

| Name | Description |
| ---- | ----------- |
| root | The root `UIViewController`. |