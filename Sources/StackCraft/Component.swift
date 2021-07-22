//
//  Component.swift
//
//  Copyright © 2021 dDomovoj. All rights reserved.
//

import UIKit

public extension VStackView {

  struct Component: Equatable, VStackViewItemConvertible {

    public enum Width: Equatable {
      case fit
      case fill
      case fixed(CGFloat)
    }

    internal var preferredHeight: Value?
    internal var preferredWidth: Width = .fill
    internal var shouldLayout: Bool = true
    internal var alignment: Alignment = .leading
    internal var insets: UIEdgeInsets = .zero

    public let view: UIView
    public var vItems: [VStackViewItemConvertible] { [self] }

    // MARK: - Init

    public init(_ view: UIView) {
      self.view = view
    }

    // MARK: - Public

    public func height(_ value: Value) -> Component {
      var copy = self
      copy.preferredHeight = value
      return copy
    }

    public func width(_ value: Width) -> Component {
      var copy = self
      copy.preferredWidth = value
      return copy
    }

    public func size(_ value: CGSize) -> Component {
      var copy = self
      copy.preferredWidth = .fixed(value.width)
      copy.preferredHeight = .fixed(value.height)
      return copy
    }

    public func skipLayout() -> Component {
      var copy = self
      copy.shouldLayout = false
      return copy
    }

    public func alignment(_ value: Alignment) -> Component {
      var copy = self
      copy.alignment = value
      return copy
    }

    public func insets(_ value: UIEdgeInsets) -> Component {
      var copy = self
      copy.insets = value
      return copy
    }

  }
}

public extension HStackView {

  struct Component: Equatable, HStackViewItemConvertible {

    public enum Height: Equatable {
      case fit
      case fill
      case fixed(CGFloat)
    }

    internal var preferredWidth: Value?
    internal var preferredHeight: Height = .fill
    internal var shouldLayout: Bool = true
    internal var alignment: Alignment = .top
    internal var insets: UIEdgeInsets = .zero

    public let view: UIView
    public var hItems: [HStackViewItemConvertible] { [self] }

    // MARK: - Init

    public init(_ view: UIView) {
      self.view = view
    }

    // MARK: - Public

    public func width(_ value: Value) -> Component {
      var copy = self
      copy.preferredWidth = value
      return copy
    }

    public func height(_ value: Height) -> Component {
      var copy = self
      copy.preferredHeight = value
      return copy
    }

    public func size(_ value: CGSize) -> Component {
      var copy = self
      copy.preferredWidth = .fixed(value.width)
      copy.preferredHeight = .fixed(value.height)
      return copy
    }

    public func skipLayout() -> Component {
      var copy = self
      copy.shouldLayout = false
      return copy
    }

    public func alignment(_ value: Alignment) -> Component {
      var copy = self
      copy.alignment = value
      return copy
    }

    public func insets(_ value: UIEdgeInsets) -> Component {
      var copy = self
      copy.insets = value
      return copy
    }

  }
}

