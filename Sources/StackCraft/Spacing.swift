//
//  Spacing.swift
//
//  Copyright © 2021 dDomovoj. All rights reserved.
//

import UIKit

public struct Spacing: Equatable, VStackViewItemConvertible, HStackViewItemConvertible {

  internal let value: Value

  public var vItems: [VStackViewItemConvertible] { [self] }

  public var hItems: [HStackViewItemConvertible] { [self] }

  public static func fixed(_ value: CGFloat) -> Spacing { .init(value: .fixed(value)) }

  public static func floating(_ value: CGFloat) -> Spacing { .init(value: .floating(value)) }

}
