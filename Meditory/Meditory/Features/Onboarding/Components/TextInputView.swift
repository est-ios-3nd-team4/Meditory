//
//  OnboardingTextInputView.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

import SwiftUI

struct TextInputView: View {
  
  let placeholder: String
  let unit: String?
  let keyboardType: UIKeyboardType
  @Binding var inputText: String
  @Environment(\.colorScheme) var colorScheme
  let needValidation: Bool
  let validator: (() -> Bool)?
  @Binding var isValid: Bool?
  let onAction:(()->Void)?
  
  init(
    placeholder: String,
    unit: String? = nil,
    keyboardType: UIKeyboardType = .default,
    inputText: Binding<String>,
    needValidation: Bool = false,
    validator: (() -> Bool)? = nil,
    isValid: Binding<Bool?> = .constant(nil),
    onAction:(()->Void)? = nil
  ) {
    self.placeholder = placeholder
    self.unit = unit
    self.keyboardType = keyboardType
    self._inputText = inputText
    self.needValidation = needValidation
    self.validator = validator
    self._isValid = isValid
    self.onAction = onAction
  }

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text(placeholder)
          .foregroundStyle(.gray)
      }
      HStack {
        NoQuickTypeTextField(text: $inputText, placeholder: "", keyboardType: keyboardType,onSubmit: {
          onAction?()
        })
          .font(.notoSans(weight: .semiBold, size: 16))
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
                .font(.notoSans(weight: .bold, size: 16))
                .foregroundStyle(Color.textGray)
                .padding(.trailing, .smallSpacing)
            }
          }
      }
      .onChange(of: inputText) {
        guard needValidation, let validate = validator else { return }
        let result = validate()
        isValid = result
      }
    }
    .onDisappear(perform: {
      isValid = false
    })
  }
}

#Preview("Light") {
  TextInputView(placeholder: "이름", unit: nil, inputText: .constant("Json"))
}
#Preview("Dark") {
  TextInputView(placeholder: "이름", unit: nil, inputText: .constant("Json"))
    .preferredColorScheme(.dark)
}
