//
//  UIExtensions.swift
//
//  Copyright © 2021 dDomovoj. All rights reserved.
//

import UIKit

// MARK: - Vertical

public struct StackViewVertical<T> {

  public typealias Base = T

  let base: T

  init(_ base: T) { self.base = base }

}

public extension UIView {

  var vertical: StackViewVertical<UIView> { .init(self) }

}

public extension CGFloat {

  var vertical: StackViewVertical<CGFloat> { .init(self) }

}

public extension Int {

  var vertical: StackViewVertical<Int> { .init(self) }

}

public extension StackViewVertical where Base == UIView {

  var component: VStackView.Component { .init(base) }

}

public extension StackViewVertical where Base == Int {

  var fixed: VStackView.Spacing { .fixed(CGFloat(base)) }

  var floating: VStackView.Spacing { .floating(CGFloat(base)) }

}

public extension StackViewVertical where Base == CGFloat {

  var fixed: VStackView.Spacing { .fixed(base) }

  var floating: VStackView.Spacing { .floating(base) }

}


// MARK: - Horizontal


public struct StackViewHorizontal<T> {

  public typealias Base = T

  let base: T

  init(_ base: T) { self.base = base }

}

public extension UIView {

  var horizontal: StackViewHorizontal<UIView> { .init(self) }

}

public extension CGFloat {

  var horizontal: StackViewHorizontal<CGFloat> { .init(self) }

}

public extension Int {

  var horizontal: StackViewHorizontal<Int> { .init(self) }

}

public extension StackViewHorizontal where Base == UIView {

  var component: HStackView.Component { .init(base) }

}

public extension StackViewHorizontal where Base == Int {

  var fixed: HStackView.Spacing { .fixed(CGFloat(base)) }

  var floating: HStackView.Spacing { .floating(CGFloat(base)) }

}

public extension StackViewHorizontal where Base == CGFloat {

  var fixed: HStackView.Spacing { .fixed(base) }

  var floating: HStackView.Spacing { .floating(base) }

}
