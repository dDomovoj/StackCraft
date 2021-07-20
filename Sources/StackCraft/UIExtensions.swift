//
//  UIExtensions.swift
//
//  Copyright © 2021 dDomovoj. All rights reserved.
//

import UIKit

public extension UIView {

  var vComponent: VStackView.Component { .init(self) }

  var hComponent: HStackView.Component { .init(self) }

}

public extension Int {

  var fixed: Spacing { .fixed(CGFloat(self)) }

  var floating: Spacing { .floating(CGFloat(self)) }

}

public extension CGFloat {

  var fixed: Spacing { .fixed(self) }

  var floating: Spacing { .floating(self) }

}
