import Foundation

#if os(iOS)
  import UIKit
#endif

/// A refresh delegate for handling reloading of a Spot
public protocol RefreshDelegate: class {

  /// A delegate method for when your component controller was refreshed using pull to refresh
  ///
  /// - parameter components: A collection of components.
  /// - parameter refreshControl: A UIRefreshControl
  /// - parameter completion: A completion closure that should be triggered when the update is completed
  #if os(iOS)
  func componentsDidReload(_ components: [Component], refreshControl: UIRefreshControl, completion: Completion)
  #endif
}
