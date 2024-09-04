#if os(iOS)
  import UIKit

  /// An extension to add rotation validation.
  extension UIViewController {
    /// Check if view controller should perform rotation.
    ///
    /// - Returns: Return boolean value to decide if view should rotate or not.
    func components_shouldAutorotate() -> Bool {
      if let parentViewController = parent {
        return parentViewController.components_shouldAutorotate()
      }

      return shouldAutorotate
    }
  }
#endif
