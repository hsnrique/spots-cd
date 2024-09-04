#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

/// ViewPreparer prepares views before they are used inside `DataSource` and `Delegate`.
/// It configures wrappable views by resolving the view from the view registry using the `kind` of the `Item`.
/// Views are registered on `Configuration.views`.
/// It also makes sure that the resolved views get configured by invoking `configure(_ item: inout Item)` from `ItemConfigurable`
/// on the view in question.
class ViewPreparer {
  let configuration: Configuration

  init(configuration: Configuration = .shared) {
    self.configuration = configuration
  }

  /// Prepare the view located at a specific index inside of a component using the parent frame.
  ///
  /// - Parameters:
  ///   - view: The view that should be prepared.
  ///   - index: The index of the item on the model.
  ///   - component: The component that the item belongs to.
  ///   - parentFrame: The frame of the parent view, only applies to wrappable views.
  func prepareView(_ view: View, atIndex index: Int, in component: Component, parentFrame: CGRect = CGRect.zero) {
    switch view {
    case let view as Wrappable:
      prepareWrappableView(view, atIndex: index, in: component, parentFrame: parentFrame)
    case let view as ItemConfigurable:
      prepareItemConfigurableView(view, atIndex: index, in: component)
    default:
      prepareItemWithModel(at: index, for: view, in: component)
    }
  }

  /// Prepare a wrappable view.
  /// Wrapper views are used when you register non-dequable views in the view registry such as `NSView` or `UIView`.
  /// These view get wrapped in wrapper views, either `ListWrapper` or `GridWrapper` depending on which user interface
  /// they belong to.
  ///
  /// - Parameters:
  ///   - view: The view that should be prepared.
  ///   - index: The index of the item on the model.
  ///   - component: The component that the item belongs to.
  ///   - parentFrame: The frame of the parent view.
  func prepareWrappableView(_ view: Wrappable, atIndex index: Int, in component: Component, parentFrame: CGRect = CGRect.zero) {
    let identifier = component.identifier(at: index)

    if let wrappedView = configuration.views.make(identifier, parentFrame: parentFrame)?.view {
      view.configure(with: wrappedView)
      if let configurableView = wrappedView as? ItemConfigurable {
        prepareItemConfigurableView(configurableView, atIndex: index, in: component)
      } else {
        if let model = component.model.items[index].model {
          guard let presenter = configuration.presenters[component.model.items[index].kind] else {
            return
          }

          let size = presenter.configure(
            view: wrappedView,
            model: model,
            containerSize: component.view.frame.size
          )

          component.model.items[index].size.height = size.height
          if component.model.layout.span == 0 {
            component.model.items[index].size.width = size.width
          }
        } else {
          component.model.items[index].size.height = wrappedView.frame.size.height
        }
      }
    }
  }

  /// Configure view with model data using the `ItemConfigurable` protocol.
  /// This will invoke `configure(_ item: inout Item) on the view that gets passed into the component.
  ///
  /// - Parameters:
  ///   - view: The view that should be prepared.
  ///   - index: The index of the item on the model.
  ///   - component: The component that the item belongs to.
  func prepareItemConfigurableView(_ view: ItemConfigurable, atIndex index: Int, in component: Component) {
    view.configure(with: component.model.items[index])

    if component.model.items[index].size.height == 0.0 {
      component.model.items[index].size = view.computeSize(for: component.model.items[index], containerSize: component.view.frame.size)
    }
  }

  private func prepareItemWithModel(at index: Int, for view: View, in component: Component) {
      guard let item = component.item(at: index),
        let model = item.model else {
        return
      }

      guard let presenter = configuration.presenters[item.kind] else {
        return
      }

    component.model.items[index].size.height = presenter.configure(
      view: view,
      model: model,
      containerSize:
      component.view.frame.size).height
  }
}
