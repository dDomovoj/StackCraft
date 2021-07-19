//
//  HStackView~ResultBuilder.swift
//
//  Copyright © 2021 dDomovoj. All rights reserved.
//

import UIKit

public extension HStackView {

  @resultBuilder
  struct Builder {

    public typealias Component = HStackViewItemConvertible

    public static func buildBlock(_ components: Component...) -> [HStackViewItemConvertible] {
      components.flatMap { $0.items }
    }

    public static func buildOptional(_ component: [Component]?) -> [HStackViewItemConvertible] {
      component?.flatMap { $0.items } ?? []
    }

    public static func buildEither(first component: [Component]) -> [HStackViewItemConvertible] {
      component.flatMap { $0.items }
    }

    public static func buildEither(second component: [Component]) -> [HStackViewItemConvertible] {
      component.flatMap { $0.items }
    }

    public static func buildArray(_ components: [Component]) -> [HStackViewItemConvertible] {
      components.flatMap { $0.items }
    }

  }
}

