// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import Foundation
import UIKit

public enum ApplicationUtil {
    // MARK: Static Methods

    /// Boolean describing whether the application is executing within an app extension.
    public static var isExecutingInAppExtension: Bool {
        let mainBundlePath = Bundle.main.bundlePath
        if mainBundlePath.count == 0 {
            return false
        }
        return mainBundlePath.hasSuffix("appex")
    }

        /// Simple access to the shared application when not executing within an app extension.
        @available(iOSApplicationExtension, unavailable)
        public static var sharedApplication: UIApplication? {
            guard !isExecutingInAppExtension else { return nil }
            return UIApplication.shared
        }

        /// Returns the current `UIViewController` for a parent controller.
        /// - Parameter parent: The parent `UIViewController`. If none provided, will attempt to discover the most
        /// relevant controller.
        @available(iOSApplicationExtension, unavailable)
        public static func currentViewController(forParent parent: UIViewController? = nil) -> UIViewController? {
            // return the current view controller of the parent
            if let parent = parent {
                return currentViewController(withRootViewController: parent)
            }

            // if this is an app extension, return nil
            guard !isExecutingInAppExtension else { return nil }

            for window in sharedApplication!.windows where window.isKeyWindow {
                return currentViewController(withRootViewController: window.rootViewController)
            }
            return nil
        }

        /// Attempt to find the top-most view controller for a given root view controller.
        /// - Parameter root: The root `UIViewController`.
        @available(iOSApplicationExtension, unavailable)
        public static func currentViewController(withRootViewController root: UIViewController?) -> UIViewController? {
            if let tabBarController = root as? UITabBarController {
                return currentViewController(withRootViewController: tabBarController.selectedViewController)
            } else if let navController = root as? UINavigationController {
                return currentViewController(withRootViewController: navController.visibleViewController)
            } else if let presented = root?.presentedViewController {
                return currentViewController(withRootViewController: presented)
            } else {
                return root
            }
        }
}
