import Cocoa

extension Wrappable {

  func wrappableViewChanged() {
    wrappedView?.trackingAreas.forEach {
      wrappedView?.removeTrackingArea($0)
    }

    guard let wrappedView = wrappedView else {
      return
    }

    let options: NSTrackingArea.Options = [NSTrackingArea.Options.inVisibleRect, NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.activeInKeyWindow]
    let trackingArea = NSTrackingArea(rect: wrappedView.bounds,
                                      options: options,
                                      owner: self, userInfo: nil)
    wrappedView.addTrackingArea(trackingArea)
  }

}
