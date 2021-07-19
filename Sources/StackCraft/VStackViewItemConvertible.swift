//
//  VStackViewItemConvertible.swift
//
//  Copyright © 2021 dDomovoj. All rights reserved.
//

import Foundation

public protocol VStackViewItemConvertible {

  var vItems: [VStackViewItemConvertible] { get }

}

extension Array: VStackViewItemConvertible where Element == VStackViewItemConvertible {

  public var vItems: [VStackViewItemConvertible] { self }

}

