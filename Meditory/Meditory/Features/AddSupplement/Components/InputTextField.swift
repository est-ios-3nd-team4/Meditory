//
//  InputTextField.swift
//  Meditory
//
//  Created by 홍승아 on 8/5/25.
//

import UIKit
import SwiftUI

/// SwiftUI에서 UIKit의 `UITextField`를 사용하기 위한 커스텀 뷰
/// - placeholder 색상, tintColor, clearButtonMode 등 기본 스타일이 설정되어 있음
/// - 편집 시작/리턴 키 입력 이벤트를 클로저로 전달 가능
struct InputTextField: UIViewRepresentable {
  
  @Binding var text: String
  
  let font: UIFont? = .notoSans(size: UIDevice.isPad ? 20 : 16)
  let placeHolder: String
  let placHolderTextColor: UIColor = .textGray
  let tintColor: UIColor = .textGray
  
  /// 편집 시작 시 호출되는 콜백
  var didBeginEditing: (() -> Void)? = nil
  /// 리턴 키 입력 시 호출되는 콜백
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
