//
//  InputTextField.swift
//  Meditory
//
//  Created by 홍승아 on 8/5/25.
//

import UIKit
import SwiftUI

struct InputTextField: UIViewRepresentable {
  
  @Binding var text: String
  
  let font: UIFont? = .notoSans(size: UIDevice.isPad ? 20 : 16)
  let placeHolder: String
  let placHolderTextColor: UIColor = .textGray
  let tintColor: UIColor = .textGray
  
  var didBeginEditing: (() -> Void)? = nil
  var shouldReturn: (() -> Void)? = nil
  
  func makeUIView(context: Context) -> some UIView {
    let textField = UITextField()
    textField.delegate = context.coordinator
    textField.returnKeyType = .done
    textField.attributedPlaceholder = NSAttributedString(
      string: placeHolder,
      attributes: [
        .foregroundColor: placHolderTextColor
      ]
    )
    textField.tintColor = tintColor
    textField.font = font
    textField.clearButtonMode = .whileEditing
    
    textField.addTarget(
      context.coordinator,
      action: #selector(Coordinator.textDidChange(_:)),
      for: .editingChanged
    )
    
    return textField
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
    guard let textField = uiView as? UITextField else { return }
    
    if textField.text != text {
      textField.text = text
    }
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
      parent.shouldReturn?()
      return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
      parent.didBeginEditing?()
    }
    
    @objc func textDidChange(_ textField: UITextField) {
      parent.text = textField.text ?? ""
    }
  }
}
