//
//  HStackView.swift
//
//  Copyright © 2021 dDomovoj. All rights reserved.
//

import UIKit

public class HStackView: UIView {

  public var items: [HStackViewItemConvertible] = [] { didSet { setNeedsReload() } }

  public enum Alignment {
    case top
    case center
    case bottom
  }

  private var previousBounds: CGRect = .zero
  private var needsReload = true
  private var needsLayoutComponents = true
  private var transforms: [CGFloat] = []

  private func components() -> [Component] {
    items.compactMap { $0 as? Component }
  }

  private func spacings() -> [Spacing] {
    items.compactMap { $0 as? Spacing }
  }

  public override class var requiresConstraintBasedLayout: Bool { false }

  // MARK: - Init

  override public init(frame: CGRect) {
      super.init(frame: frame)
      previousBounds = CGRect(origin: .zero, size: frame.size)
      setup()
  }

  required public init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      setup()
  }

  // MARK: - Lifecycle

  override public func layoutSubviews() {
    super.layoutSubviews()
    defer { previousBounds = bounds }

    if bounds != previousBounds {
      needsLayoutComponents = true
    }
    updateIfNeeded()
  }

  // MARK: - Public

  public func setup() {
    backgroundColor = .clear
    translatesAutoresizingMaskIntoConstraints = true
    setNeedsLayout()
    setNeedsUpdateConstraints()
  }

  public func reload(@Builder builder: () -> [HStackViewItemConvertible]) -> Void {
    items = builder()
  }

  public func setNeedsReload() {
    needsReload = true
    needsLayoutComponents = true
    setNeedsLayout()
  }

  public func spacing(before component: Component) -> CGFloat {
    updateIfNeeded()
    guard let idx = items.firstIndex(where: { ($0 as? Component) == component }),
          (0..<items.count).contains(idx - 1),
          items[idx - 1] is Spacing else { return 0 }

    return transforms[idx - 1]
  }

  public func spacing(after component: Component) -> CGFloat {
    updateIfNeeded()
    guard let idx = items.firstIndex(where: { ($0 as? Component) == component }),
          (0..<items.count).contains(idx + 1),
          items[idx + 1] is Spacing else { return 0 }

    return transforms[idx + 1]
  }

  public func height(of component: Component) -> CGFloat {
    updateIfNeeded()
    guard let idx = items.firstIndex(where: { ($0 as? Component) == component }) else { return 0 }

    return transforms[idx]
  }

}

// MARK: - Private

private extension HStackView {

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
    components.filter { $0.shouldLayout }.map(\.view)
      .forEach { addSubview($0) }
  }

  // swiftlint:disable:next cyclomatic_complexity
  func layoutComponents() {
    if bounds.isEmpty { return }
    defer { needsLayoutComponents = false }

    let components = self.components()
    let totalFixedWidth = components.reduce(into: CGFloat(0)) {
      if case .fixed(let height) = $1.preferredWidth { $0 += height }
      if $1.shouldLayout, $1.preferredWidth == nil {
        switch $1.preferredHeight {
        case .fixed(let height):
          let heightToFit = height
          let size = $1.view.sizeThatFits(.init(width: .greatestFiniteMagnitude, height: heightToFit))
          let roundedSize = CGSize(width: size.width.rounded(.up), height: height)
          var frame = $1.view.frame
          frame.size = roundedSize
          $1.view.frame = frame
        case .fit:
          let container = $1.view.superview?.bounds ?? .zero
          let heightToFit = max(container.height - $1.insets.top - $1.insets.bottom, 0)
          let size = $1.view.sizeThatFits(.init(width: .greatestFiniteMagnitude, height: heightToFit))
          let roundedSize = CGSize(width: size.width.rounded(.up), height: size.height.rounded(.up))
          var frame = $1.view.frame
          frame.size = roundedSize
          $1.view.frame = frame
        case .fill:
          let container = $1.view.superview?.bounds ?? .zero
          let heightToFit = max(container.height - $1.insets.top - $1.insets.bottom, 0)
          let size = $1.view.sizeThatFits(.init(width: .greatestFiniteMagnitude, height: heightToFit))
          let roundedSize = CGSize(width: size.width.rounded(.up), height: heightToFit)
          var frame = $1.view.frame
          frame.size = roundedSize
          $1.view.frame = frame
        }
        $0 += $1.view.bounds.width
      }
    }
    let targetTotalFloatingWidth = components.map(\.preferredWidth).reduce(into: CGFloat(0)) {
      if case .floating(let width) = $1 { $0 += width }
    }

    let spacings = self.spacings()
    let totalFixedSpacing = spacings.reduce(into: CGFloat(0)) {
      if case .fixed(let spacing) = $1.value { $0 += spacing }
    }
    let targetTotalFloatingSpacing = spacings.reduce(into: CGFloat(0)) {
      if case .floating(let spacing) = $1.value { $0 += spacing }
    }

    let targetFloatingSpace = targetTotalFloatingWidth + targetTotalFloatingSpacing
    let freeFloatingSpace = bounds.size.width - totalFixedWidth - totalFixedSpacing
    let floatingMultiplier = targetFloatingSpace != 0 ? (freeFloatingSpace / targetFloatingSpace) : 0

    transforms = [CGFloat](repeating: 0, count: items.count)
    var accumulator: CGFloat = 0
    items.enumerated().forEach { idx, item in
      let transform: CGFloat
      if let component = item as? Component {
        switch component.preferredWidth {
        case .fixed(let width):
          transform = width
          if component.shouldLayout {
            component.view.frame.size.width = width
          }
        case .floating(let targetWidth):
          let width = (floatingMultiplier * targetWidth).rounded()
          transform = width
          if component.shouldLayout {
            component.view.frame.size.width = width
          }
        case .none:
          transform = component.shouldLayout ? component.view.bounds.width : 0
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

      accumulator += (transform * 2.0).rounded(.up) / 2.0
      transforms[idx] = transform
    }
  }

  func layout(component: Component, transform: CGFloat, accumulator: CGFloat) {
    if component.shouldLayout {
      let height: CGFloat
      if case .fixed(let value) = component.preferredHeight {
        height = value
      } else {
        height = component.view.bounds.height
      }
      if height > 0 {
        switch component.alignment {
        case .top:
          let y = component.insets.top
          component.view.frame =
            .init(x: accumulator, y: y.rounded(), width: transform, height: height)
        case .bottom:
          let container = component.view.superview?.bounds ?? .zero
          let y = container.height - height - component.insets.bottom
          component.view.frame =
            .init(x: accumulator, y: y.rounded(), width: transform, height: height)
        case .center:
          let container = component.view.superview?.bounds ?? .zero
          let y = (container.height - height) * 0.5 + (component.insets.top - component.insets.bottom)
          component.view.frame =
            .init(x: accumulator, y: y.rounded(), width: transform, height: height)
        }
      }
      else {
        let container = component.view.superview?.bounds ?? .zero
        let height = container.height - component.insets.top - component.insets.bottom
        let y = component.insets.top
        component.view.frame =
          .init(x: accumulator, y: y.rounded(), width: transform, height: height)
      }
    }
  }

}

