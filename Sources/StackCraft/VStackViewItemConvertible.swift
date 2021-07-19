//
//  VStackViewItemConvertible.swift
//
//  Copyright © 2021 dDomovoj. All rights reserved.
//

import Foundation

public protocol VStackViewItemConvertible {

  var items: [VStackViewItemConvertible] { get }

}

extension Array: VStackViewItemConvertible where Element == VStackViewItemConvertible {

  public var items: [VStackViewItemConvertible] { self }

}

