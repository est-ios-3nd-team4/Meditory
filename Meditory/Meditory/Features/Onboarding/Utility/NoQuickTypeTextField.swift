//
//  NoQuickTypeTextField.swift
//  Meditory
//
//  Created by hyunsic on 8/14/25.
//

import SwiftUI
import UIKit

///키보드 딜레이와  자동완성제안을 없는 키보드를 사용하기 위해 구현
struct NoQuickTypeTextField: UIViewRepresentable {
  var isPad = UIDevice.isPad
  @Binding var text: String
  var placeholder: String = ""
  var keyboardType: UIKeyboardType = .default
  var onSubmit: (()->Void)

  /// 기본 UIKit의 텍스트 필드 정의
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

  /// 텍스트 필드의 내용 변환
  func updateUIView(_ uiView: UITextField, context: Context) {
    if uiView.text != text {
      uiView.text = text
    }
  }

  /// SwiftUI에서 쓰기 위한 브리징
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  /// 텍스트필드의 델리게이트 구현
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
