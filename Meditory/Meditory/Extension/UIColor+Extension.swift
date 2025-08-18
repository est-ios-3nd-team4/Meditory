//
//  UIColor+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/14/25.
//

import UIKit

extension UIColor {
  convenience init(red: Int, green: Int, blue: Int, opacity: Double = 1.0) {
    self.init(
      red: Double(red) / 255,
      green: Double(green) / 255,
      blue: Double(blue) / 255,
      alpha: opacity
    )
  }
}
