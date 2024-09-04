import UIKit

/**
 A Controller extension to handle scrollViewDidScroll
 */
extension SpotsController {

  /// Tells the delegate when the user scrolls the content view within the receiver.
  ///
  /// - parameter scrollView: The scroll-view object in which the scrolling occurred.

  open func scrollViewDidScroll(_ scrollView: UIScrollView) {
    #if os(tvOS)
      self.scrollView.layoutViews()
      guard scrollDelegate?.didScroll(in: scrollView) != true else {
        return
      }
      let multiplier: CGFloat = 1
    #else
      let multiplier: CGFloat = !refreshPositions.isEmpty
        ? CGFloat(1 + refreshPositions.count)
        : 1
    #endif

    let offset = scrollView.contentOffset
    let size = scrollView.contentSize
    let windowHeight = scrollView.window?.frame.size.height ?? 0
    let windowViewOffset = windowHeight - scrollView.frame.size.height
    let itemOffset = (size.height - scrollView.bounds.size.height * 2) > 0
      ? scrollView.bounds.size.height * 2
      : (components.last?.model.items.last?.size.height ?? 0) * 6
    let shouldFetch = !refreshing &&
      size.height > scrollView.bounds.height &&
      offset.y > size.height - windowViewOffset - scrollView.bounds.height * multiplier &&
      !refreshPositions.contains(size.height - itemOffset)

    guard let delegate = scrollDelegate else {
      return
    }

    if scrollView.contentOffset.y < 0 && !refreshing {
      refreshing = true
      delegate.didReachBeginning(in: scrollView) {
        self.refreshing = false
      }
    }

    // Scroll did reach top
    if abs(scrollView.contentOffset.y) == scrollView.contentInset.top &&
      !refreshing {
      refreshing = true
      delegate.didReachBeginning(in: scrollView) {
        self.refreshing = false
      }
    }

    if shouldFetch {
      // Infinite scrolling
      refreshPositions.append(size.height - itemOffset)
      refreshing = true
      delegate.didReachEnd(in: scrollView) {
        self.refreshing = false
      }
    }
  }
}
