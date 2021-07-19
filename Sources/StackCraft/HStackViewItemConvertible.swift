//
//  HStackViewItemConvertible.swift
//
//  Copyright © 2021 dDomovoj. All rights reserved.
//

import Foundation

public protocol HStackViewItemConvertible {

  var hItems: [HStackViewItemConvertible] { get }

}

extension Array: HStackViewItemConvertible where Element == HStackViewItemConvertible {

  public var hItems: [HStackViewItemConvertible] { self }

}


