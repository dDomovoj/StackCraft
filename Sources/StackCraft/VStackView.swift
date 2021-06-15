//
//  VStackView.swift
//
//  Created by Dzmitry Duleba on 6/06/21.
//  Copyright © 2021 dDomovoj. All rights reserved.
//

import UIKit

public class VStackView: UIView {

  public var items: [VStackViewItemConvertible] = [] { didSet { setNeedsReload() } }

  public enum Value: Equatable {
    case fixed(CGFloat)
    case floating(CGFloat)
  }

  public enum Alignment {
    case leading
    case center
    case trailing
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

  public func reload(@Builder builder: () -> [VStackViewItemConvertible]) -> Void {
    items = builder()
  }

  public func setNeedsReload() {
    needsReload = true
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
    components.filter { $0.shouldLayout }.map(\.view)
      .forEach { addSubview($0) }
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
    let freeFloatingSpace = bounds.size.height - totalFixedHeight - totalFixedSpacing
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
