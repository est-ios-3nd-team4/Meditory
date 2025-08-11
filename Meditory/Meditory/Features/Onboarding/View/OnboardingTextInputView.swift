//
//  OnboardingTextInputView.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

import SwiftUI

struct OnboardingTextInputView: View {
  let prompt: String
  let placeholder: String
  let unit: String?
  let keyboardType: UIKeyboardType
  @Binding var inputText: String
  @Environment(\.colorScheme) var colorScheme
  let needValidation: Bool
  let validator: (() -> Bool)?
  @Binding var isValid: Bool?

  init(
    prompt: String,
    placeholder: String,
    unit: String? = nil,
    keyboardType: UIKeyboardType = .default,
    inputText: Binding<String>,
    needValidation: Bool = false,
    validator: (() -> Bool)? = nil,
    isValid: Binding<Bool?> = .constant(nil)
  ) {
    self.prompt = prompt
    self.placeholder = placeholder
    self.unit = unit
    self.keyboardType = keyboardType
    self._inputText = inputText
    self.needValidation = needValidation
    self.validator = validator
    self._isValid = isValid
  }

  var body: some View {
    Text(prompt)
      .font(.notoSans(weight: .bold, size: 24))
      .padding(.bottom, 20)
    VStack(alignment: .leading) {
      HStack {
        Text(placeholder)
          .foregroundStyle(.gray)
        Spacer()
      }
      HStack {
        TextField("", text: $inputText)
          .keyboardType(keyboardType)
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
            }
          }
      }
      Spacer()
        .onChange(of: inputText) {
          guard needValidation, let validate = validator else { return }
          let result = validate()
          isValid = result
        }
    }
    .onDisappear(perform: {
      isValid = false
    })
    .padding()
    .padding(.top, 16)
  }
}

#Preview {
  OnboardingTextInputView(prompt: "고객님의 \n이름을 알려주세요", placeholder: "성함", unit: "H", inputText: .constant("제이슨"))
}
