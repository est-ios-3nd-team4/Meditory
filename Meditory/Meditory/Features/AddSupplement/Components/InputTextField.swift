//
//  InputTextField.swift
//  Meditory
//
//  Created by 홍승아 on 8/5/25.
//

import UIKit
import SwiftUI

struct InputTextField: UIViewRepresentable {
  
  let fontSize: CGFloat
  let placeHolder: String
  
  func makeUIView(context: Context) -> some UIView {
    let textField = UITextField()
    textField.delegate = context.coordinator
    textField.returnKeyType = .done
    textField.attributedPlaceholder = NSAttributedString(
      string: placeHolder,
      attributes: [
        .foregroundColor: UIColor.textGray
      ]
    )
    textField.tintColor = .textGray
    textField.font = UIFont(name: "NotoSans-Medium", size: fontSize)
    textField.clearButtonMode = .whileEditing 
    
    return textField
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
    
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, UITextFieldDelegate {
    var parent: InputTextField
    
    init(_ parent: InputTextField) {
      self.parent = parent
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
      return true
    }
  }
}
