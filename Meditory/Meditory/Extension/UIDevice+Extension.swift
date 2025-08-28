//
//  UIDevice+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/4/25.
//

import UIKit

extension UIDevice {
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}

enum widthTier {
  case small
  case regular
  case plus
}

func deviceWidthTier() -> widthTier {
  let width = UIScreen.main.bounds.width
  if width <= 375 {
    return .small
  }
  if width >= 428 {
    return .plus
  }
  return .regular
}
