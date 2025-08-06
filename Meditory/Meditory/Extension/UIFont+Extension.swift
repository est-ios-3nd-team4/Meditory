//
//  UIFont+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/6/25.
//

import UIKit

extension UIFont {
  enum NotoSansWeight {
    case regular
    case medium
    case semiBold
    case bold
  }
  
  static func notoSans(weight: NotoSansWeight = .medium, size: CGFloat) -> UIFont? {
    switch weight {
    case .regular:
      return UIFont(name: "NotoSansKR-Regular", size: size)
    case .medium:
      return UIFont(name: "NotoSansKR-Medium", size: size)
    case .semiBold:
      return UIFont(name: "NotoSansKR-SemiBold", size: size)
    case .bold:
      return UIFont(name: "NotoSansKR-Bold", size: size)
    }
  }
}
