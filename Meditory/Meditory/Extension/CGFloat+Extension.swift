//
//  CGFloat+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/5/25.
//

import UIKit

extension CGFloat {
  // MARK: - Spacing
  static let smallSpacing: CGFloat = 8
  static let defaultSpacing: CGFloat = UIDevice.isPad ? 20 : 16
  static let bottomInset: CGFloat = 33
  
  // MARK: - CornerRadius
  static let smallRadius: CGFloat = 10
  static let defaultRadius: CGFloat = 20
  
  // MARK: - FontSize
  static let defaultFontSize: CGFloat = UIDevice.isPad ? 23 : 18
}
