//
//  DismissKeyboardOnTap.swift
//  Meditory
//
//  Created by 홍승아 on 8/28/25.
//

import SwiftUI
import UIKit

struct DismissKeyboardOnTap: ViewModifier {
  func body(content: Content) -> some View {
    content
      .simultaneousGesture(
        TapGesture().onEnded {
          UIApplication.shared.hideKeyboard()
        }
      )
  }
}
