//
//  VStackView~ResultBuilder.swift
//
//  Copyright © 2021 dDomovoj. All rights reserved.
//

import UIKit

public extension VStackView {

  @resultBuilder
  struct Builder {

    public typealias Component = VStackViewItemConvertible

    public static func buildBlock(_ components: Component...) -> [VStackViewItemConvertible] {
      components.flatMap { $0.items }
    }

    public static func buildOptional(_ component: [Component]?) -> [VStackViewItemConvertible] {
      component?.flatMap { $0.items } ?? []
    }

    public static func buildEither(first component: [Component]) -> [VStackViewItemConvertible] {
      component.flatMap { $0.items }
    }

    public static func buildEither(second component: [Component]) -> [VStackViewItemConvertible] {
      component.flatMap { $0.items }
    }

    public static func buildArray(_ components: [Component]) -> [VStackViewItemConvertible] {
      components.flatMap { $0.items }
    }

  }
}

