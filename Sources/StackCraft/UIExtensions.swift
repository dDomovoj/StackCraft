//
//  UIExtensions.swift
//
//  Created by Dzmitry Duleba on 6/06/21.
//  Copyright © 2021 dDomovoj. All rights reserved.
//

import UIKit

public extension UIView {

  func asComponent() -> VStackView.Component { .init(self) }

}

public extension CGFloat {

  var fixedSpacing: VStackView.Spacing { .fixed(self) }

  var floatingSpacing: VStackView.Spacing { .floating(self) }

}

public extension Int {

  var fixedSpacing: VStackView.Spacing { .fixed(CGFloat(self)) }

  var floatingSpacing: VStackView.Spacing { .floating(CGFloat(self)) }

}
