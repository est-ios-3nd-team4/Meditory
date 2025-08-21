//
//  Color+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/4/25.
//

import SwiftUI

extension Color {
  static let background = Color(UIColor.systemBackground)
  static let label = Color(UIColor.label)
  static let chartBackground = Color(
    .sRGB,
    red: 239/255,
    green: 239/255,
    blue: 239/255,
    opacity: 1.0
  )
  
  init(red: Int, green: Int, blue: Int, opacity: Double = 1.0) {
    self.init(
      .sRGB,
      red: Double(red) / 255,
      green: Double(green) / 255,
      blue: Double(blue) / 255,
      opacity: opacity
    )
  }
}
