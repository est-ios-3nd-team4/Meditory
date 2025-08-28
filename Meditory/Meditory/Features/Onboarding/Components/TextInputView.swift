//
//  OnboardingTextInputView.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

import SwiftUI

struct TextInputView: View {
  
  let title: String
  let placeholder: String
  let unit: String?
  let keyboardType: UIKeyboardType
  @Binding var inputText: String
  @Environment(\.colorScheme) var colorScheme
  let needValidation: Bool
  let validator: (() -> Bool)?
  @Binding var isValid: Bool?
  let errorMessage: String?
  let onAction:(()->Void)?
  
  init(
    title: String,
    placeholder: String,
    unit: String? = nil,
    keyboardType: UIKeyboardType = .default,
    inputText: Binding<String>,
    needValidation: Bool = false,
    validator: (() -> Bool)? = nil,
    isValid: Binding<Bool?> = .constant(nil),
    errorMessage: String? = nil,
    onAction:(()->Void)? = nil
  ) {
    self.title = title
    self.placeholder = placeholder
    self.unit = unit
    self.keyboardType = keyboardType
    self._inputText = inputText
    self.needValidation = needValidation
    self.validator = validator
    self._isValid = isValid
    self.errorMessage = errorMessage
    self.onAction = onAction
  }

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text(title)
          .foregroundStyle(.gray)
        if let error = errorMessage {
          Spacer()
          Text(error)
            .foregroundStyle(.red)
            .adaptiveFont(12,weight: .medium)
        }
      }
      HStack {
        NoQuickTypeTextField(text: $inputText, placeholder: placeholder, keyboardType: keyboardType,onSubmit: {
          onAction?()
        })
        .adaptiveFont(14,weight: .semiBold)
          .padding(.horizontal)
          .frame(height: 60)
          .background(
            colorScheme == .light ? Color.gray.opacity(0.1) : Color.white.opacity(0.1),
            in: RoundedRectangle(cornerRadius: 16)
          )
          .overlay(alignment: .trailing) {
            if let unit = unit {
              Text(unit)
                .padding(.trailing, 8)
                .adaptiveFont(16,weight: .bold)
                .foregroundStyle(Color.textGray)
                .padding(.trailing, .smallSpacing)
            }
          }
      }
      .onChange(of: inputText) {
        guard needValidation else { return }
        _ = validator?()
      }
    }
  }
}

#Preview("Light") {
  TextInputView(title: "이름",placeholder:"홍길동", unit: nil, inputText: .constant("Json"))
}
#Preview("Dark") {
  TextInputView(title: "이름",placeholder:"홍길동", unit: nil, inputText: .constant("Json"))
    .preferredColorScheme(.dark)
}
