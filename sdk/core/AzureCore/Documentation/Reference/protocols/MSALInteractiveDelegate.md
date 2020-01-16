**PROTOCOL**

# `MSALInteractiveDelegate`

```swift
public protocol MSALInteractiveDelegate: class
```

> Delegate protocol for view controllers to hook into the MSAL interactive flow.

## Methods
### `parentForWebView()`

```swift
func parentForWebView() -> UIViewController
```

### `didCompleteMSALRequest(withResult:)`

```swift
func didCompleteMSALRequest(withResult result: MSALResult)
```
