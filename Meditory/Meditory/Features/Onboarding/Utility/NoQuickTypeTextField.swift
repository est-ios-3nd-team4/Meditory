//
//  NoQuickTypeTextField.swift
//  Meditory
//
//  Created by hyunsic on 8/14/25.
//

import SwiftUI
import UIKit

struct NoQuickTypeTextField: UIViewRepresentable {
  var isPad = UIDevice.isPad
  @Binding var text: String
  var placeholder: String = ""
  var keyboardType: UIKeyboardType = .default
  var onSubmit: (()->Void)

  func makeUIView(context: Context) -> UITextField {
    let tf = UITextField()
    tf.placeholder = placeholder
    tf.font = UIFont.notoSans(weight: .medium, size: isPad ? 20 : 16)
    tf.autocorrectionType = .no
    tf.spellCheckingType = .no
    tf.keyboardType = keyboardType
    tf.delegate = context.coordinator
    tf.addTarget(context.coordinator, action: #selector(Coordinator.returnPressed(_:)), for: .editingDidEndOnExit)
    return tf
  }

  func updateUIView(_ uiView: UITextField, context: Context) {
    if uiView.text != text {
      uiView.text = text
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, UITextFieldDelegate {
    var parent: NoQuickTypeTextField
    init(_ parent: NoQuickTypeTextField) { self.parent = parent }
    func textFieldDidChangeSelection(_ textField: UITextField) {
      parent.text = textField.text ?? ""
    }
    @objc func returnPressed(_ textField: UITextField) {
      parent.onSubmit()
      textField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      returnPressed(textField)
      return true
    }
  }
}
