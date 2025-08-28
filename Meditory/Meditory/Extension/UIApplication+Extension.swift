//
//  UIApplication+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/28/25.
//

import UIKit

extension UIApplication {
  func hideKeyboard() {
    sendAction(#selector(UIResponder.resignFirstResponder),
               to: nil, from: nil, for: nil)
  }
}
