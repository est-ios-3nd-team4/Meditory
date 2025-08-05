//
//  Font+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/4/25.
//

import SwiftUI

extension Font {
  enum NotoSansWeight {
    case medium
    case semiBold
    case bold
  }
  
  static func notoSans(weight: NotoSansWeight = .medium, size: CGFloat) -> Font {
    switch weight {
    case .medium:
      return custom("NotoSansKR-Medium", size: size)
    case .semiBold:
      return custom("NotoSansKR-SemiBold", size: size)
    case .bold:
      return custom("NotoSansKR-Bold", size: size)
    }
  }
}
