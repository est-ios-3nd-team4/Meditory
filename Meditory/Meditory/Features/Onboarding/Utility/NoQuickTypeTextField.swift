//
//  NoQuickTypeTextField.swift
//  Meditory
//
//  Created by hyunsic on 8/14/25.
//

import SwiftUI
import UIKit

struct NoQuickTypeTextField: UIViewRepresentable {
  @Binding var text: String
  var placeholder: String = ""
  var keyboardType: UIKeyboardType = .default
  var onSubmit: (()->Void)

  func makeUIView(context: Context) -> UITextField {
    let tf = UITextField()
    tf.placeholder = placeholder
    tf.autocorrectionType = .no
    tf.spellCheckingType = .no
    tf.keyboardType = keyboardType
    tf.delegate = context.coordinator
    tf.addTarget(self, action: #selector(Coordinator.returnPressed(_:)), for: .editingDidEndOnExit)
    return tf
  }

  func updateUIView(_ uiView: UITextField, context: Context) {
    uiView.text = text
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
      return false
    }
  }
}
