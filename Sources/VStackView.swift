//
//  VStackView.swift
//
//  Created by Dzmitry Duleba on 6/06/21.
//  Copyright © 2021 dDomovoj. All rights reserved.
//

import UIKit

extension UIView {

  func asComponent() -> VStackView.Component { .init(self) }

}

extension CGFloat {

  var fixedSpacing: VStackView.Spacing { .fixed(self) }

  var floatingSpacing: VStackView.Spacing { .floating(self) }

}

extension Int {

  var fixedSpacing: VStackView.Spacing { .fixed(CGFloat(self)) }

  var floatingSpacing: VStackView.Spacing { .floating(CGFloat(self)) }

}

protocol VStackViewItemConvertible {

  var items: [VStackViewItemConvertible] { get }

}

extension Array: VStackViewItemConvertible where Element == VStackViewItemConvertible {

  var items: [VStackViewItemConvertible] { self }

}

class VStackView: View {

  var items: [VStackViewItemConvertible] = [] { didSet { setNeedsReload() } }

  enum Value: Equatable {
    case fixed(CGFloat)
    case floating(CGFloat)
  }

  enum Alignment {
    case leading
    case center
    case trailing
  }

  struct Spacing: Equatable, VStackViewItemConvertible {

    fileprivate let value: Value

    var items: [VStackViewItemConvertible] { [self] }

    static func fixed(_ value: CGFloat) -> Spacing { .init(value: .fixed(value)) }

    static func floating(_ value: CGFloat) -> Spacing { .init(value: .floating(value)) }

  }

  struct Component: Equatable, VStackViewItemConvertible {

    let view: UIView
    fileprivate var preferredHeight: Value?
    fileprivate var preferredWidth: CGFloat?
    fileprivate var shouldLayout: Bool = true
    fileprivate var alignment: Alignment = .leading
    fileprivate var insets: UIEdgeInsets = .zero

    var items: [VStackViewItemConvertible] { [self] }

    // MARK: - Init

    init(_ view: UIView) {
      self.view = view
    }

    // MARK: - Public

    func height(_ value: Value) -> Component {
      var copy = self
      copy.preferredHeight = value
      return copy
    }

    func width(_ value: CGFloat) -> Component {
      var copy = self
      copy.preferredWidth = value
      return copy
    }

    func skipLayout() -> Component {
      var copy = self
      copy.shouldLayout = false
      return copy
    }

    func alignment(_ value: Alignment) -> Component {
      var copy = self
      copy.alignment = value
      return copy
    }

    func insets(_ value: UIEdgeInsets) -> Component {
      var copy = self
      copy.insets = value
      return copy
    }

  }

  private var needsReload = true
  private var needsLayoutComponents = true
  private var transforms: [CGFloat] = []

  private func components() -> [Component] {
    items.compactMap { $0 as? Component }
  }

  private func spacings() -> [Spacing] {
    items.compactMap { $0 as? Spacing }
  }

  override class var requiresConstraintBasedLayout: Bool { false }

  // MARK: - Lifecycle

  override func setup() {
    super.setup()
    translatesAutoresizingMaskIntoConstraints = true
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    updateIfNeeded()
  }

  // MARK: - Public

  func reload(@Builder builder: () -> [VStackViewItemConvertible]) -> Void {
    items = builder()
  }

  func setNeedsReload() {
    needsReload = true
    setNeedsLayout()
  }

  func spacing(before component: Component) -> CGFloat {
    updateIfNeeded()
    guard let idx = items.firstIndex(where: { ($0 as? Component) == component }),
          idx - 1 < items.count - 1,
          items[idx - 1] is Spacing else { return 0 }

    return transforms[idx - 1]
  }

  func spacing(after component: Component) -> CGFloat {
    updateIfNeeded()
    guard let idx = items.firstIndex(where: { ($0 as? Component) == component }),
          idx + 1 < items.count - 1,
          items[safe: idx + 1] is Spacing else { return 0 }

    return transforms[idx + 1]
  }

  func height(of component: Component) -> CGFloat {
    updateIfNeeded()
    guard let idx = items.firstIndex(where: { ($0 as? Component) == component }) else { return 0 }

    return transforms[idx]
  }

}

// MARK: - Private

private extension VStackView {

  func updateIfNeeded() {
    if needsReload { reload() }
    if needsLayoutComponents { layoutComponents() }
  }

  func reload() {
    defer { needsReload = false }

    let components = self.components()
    subviews.forEach { subview in
      if !components.contains(where: { $0.view == subview }) {
        subview.removeFromSuperview()
      }
    }
    addSubviews(components.filter { $0.shouldLayout }.map(\.view))
  }

  // swiftlint:disable:next cyclomatic_complexity
  func layoutComponents() {
    if bounds.isEmpty { return }
    defer { needsLayoutComponents = false }

    let components = self.components()
    let totalFixedHeight = components.reduce(into: CGFloat(0)) {
      if case .fixed(let height) = $1.preferredHeight { $0 += height }
      if $1.shouldLayout, $1.preferredHeight == nil {
        if let width = $1.preferredWidth {
          let widthToFit = width
          var frame = $1.view.frame
          frame.size = $1.view.sizeThatFits(.init(width: widthToFit, height: .greatestFiniteMagnitude))
          $1.view.frame = frame
        }
        else {
          var frame = $1.view.frame
          frame.origin.x = $1.insets.left
          let container = $1.view.superview?.bounds ?? .zero
          let widthToFit = max(container.width - $1.insets.left - $1.insets.right, 0)
          frame.size = $1.view.sizeThatFits(.init(width: widthToFit, height: .greatestFiniteMagnitude))
          $1.view.frame = frame
        }
        $0 += $1.view.bounds.height
      }
    }
    let targetTotalFloatingHeight = components.map(\.preferredHeight).reduce(into: CGFloat(0)) {
      if case .floating(let height) = $1 { $0 += height }
    }

    let spacings = self.spacings()
    let totalFixedSpacing = spacings.reduce(into: CGFloat(0)) {
      if case .fixed(let spacing) = $1.value { $0 += spacing }
    }
    let targetTotalFloatingSpacing = spacings.reduce(into: CGFloat(0)) {
      if case .floating(let spacing) = $1.value { $0 += spacing }
    }

    let targetFloatingSpace = targetTotalFloatingHeight + targetTotalFloatingSpacing
    let freeFloatingSpace = height - totalFixedHeight - totalFixedSpacing
    let floatingMultiplier = targetFloatingSpace != 0 ? (freeFloatingSpace / targetFloatingSpace) : 0

    transforms = [CGFloat](repeating: 0, count: items.count)
    var accumulator: CGFloat = 0
    items.enumerated().forEach { idx, item in
      let transform: CGFloat
      if let component = item as? Component {
        switch component.preferredHeight {
        case .fixed(let height):
          transform = height
          if component.shouldLayout {
            component.view.frame.size.height = height
          }
        case .floating(let targetHeight):
          let height = floatingMultiplier * targetHeight
          transform = height
          if component.shouldLayout {
            component.view.frame.size.height = height
          }
        case .none:
          transform = component.shouldLayout ? component.view.bounds.height : 0
        }

        layout(component: component, transform: transform, accumulator: accumulator)
      }
      else if let spacing = item as? Spacing {
        switch spacing.value {
        case .fixed(let spacing):
          transform = spacing
        case .floating(let targetSpacing):
          let spacing = targetSpacing * floatingMultiplier
          transform = spacing
        }
      }
      else {
        transform = 0
      }

      accumulator += transform
      transforms[idx] = transform
    }
  }

  func layout(component: Component, transform: CGFloat, accumulator: CGFloat) {
    if component.shouldLayout {
      if let width = component.preferredWidth {
        switch component.alignment {
        case .leading:
          component.view.frame =
            .init(x: component.insets.left, y: accumulator, width: width, height: transform)
        case .trailing:
          let container = component.view.superview?.bounds ?? .zero
          let x = container.width - width - component.insets.right
          component.view.frame =
            .init(x: x, y: accumulator, width: width, height: transform)
        case .center:
          let container = component.view.superview?.bounds ?? .zero
          let x = (container.width - width) * 0.5 + (component.insets.left - component.insets.right)
          component.view.frame =
            .init(x: x, y: accumulator, width: width, height: transform)
        }
      }
      else {
        let container = component.view.superview?.bounds ?? .zero
        let width = container.width - component.insets.left - component.insets.right
        component.view.frame =
          .init(x: component.insets.left, y: accumulator, width: width, height: transform)
      }
    }
  }

}

// MARK: - @resultBuilder Support

extension VStackView {

  @resultBuilder
  struct Builder {

    typealias Component = VStackViewItemConvertible

    static func buildBlock(_ components: Component...) -> [VStackViewItemConvertible] {
      components.flatMap { $0.items }
    }

    static func buildOptional(_ component: [Component]?) -> [VStackViewItemConvertible] {
      component?.flatMap { $0.items } ?? []
    }

    static func buildEither(first component: [Component]) -> [VStackViewItemConvertible] {
      component.flatMap { $0.items }
    }

    static func buildEither(second component: [Component]) -> [VStackViewItemConvertible] {
      component.flatMap { $0.items }
    }

    static func buildArray(_ components: [Component]) -> [VStackViewItemConvertible] {
      components.flatMap { $0.items }
    }

  }
}