//
//  Spacing.swift
//
//  Copyright © 2021 dDomovoj. All rights reserved.
//

import UIKit

public extension VStackView {

  struct Spacing: Equatable, VStackViewItemConvertible {

    internal let value: Value

    public var items: [VStackViewItemConvertible] { [self] }

    public static func fixed(_ value: CGFloat) -> Spacing { .init(value: .fixed(value)) }

    public static func floating(_ value: CGFloat) -> Spacing { .init(value: .floating(value)) }

  }

}

public extension HStackView {

  struct Spacing: Equatable, HStackViewItemConvertible {

    internal let value: Value

    public var items: [HStackViewItemConvertible] { [self] }

    public static func fixed(_ value: CGFloat) -> Spacing { .init(value: .fixed(value)) }

    public static func floating(_ value: CGFloat) -> Spacing { .init(value: .floating(value)) }

  }

}
