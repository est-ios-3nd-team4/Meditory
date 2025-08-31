//
//  OnboardingTextInputView.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

import SwiftUI

/// 사용자의 정보를 입력받는  텍스트 뷰 컴포넌트
struct TextInputView: View {
  
  // MARK: - 뷰의 속성
  let isPad = UIDevice.isPad
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

  
  // MARK: - 뷰의 바디
  var body: some View {
    VStack(alignment: .leading) {
      
      /// 상단의 타이틀
      HStack {
        /// 메인 타이틀
        Text(title)
          .adaptiveFont(.defaultFontSize - 4,weight: .medium)
          .foregroundStyle(.gray)
        
        /// 유효성의 검증에 실패했을 경우 표시할 에러 메시지
        if let error = errorMessage {
          Spacer()
          Text(error)
            .foregroundStyle(.red)
            .adaptiveFont(.defaultFontSize - 6,weight: .medium)
        }
      }
      
      /// 하단의 텍스트 필드
      HStack {
        /// 자동 완성 제안을 없애기 위해 UIKit 에서 래핑한 커스텀 텍스트필드
        NoQuickTypeTextField(text: $inputText, placeholder: placeholder, keyboardType: keyboardType,onSubmit: {
          onAction?()
        })
        .adaptiveFont(.defaultFontSize - 4,weight: .semiBold)
          .padding(.horizontal)
          .frame(height: 60)
          .background(
            colorScheme == .light ? Color.gray.opacity(0.1) : Color.white.opacity(0.1),
            in: RoundedRectangle(cornerRadius: 16)
          )
          .overlay(alignment: .trailing) {
            /// 각 필드에 적합한 단위 표시 텍스트
            if let unit = unit {
              Text(unit)
                .padding(.trailing, isPad ? 12 : 8)
                .adaptiveFont(.defaultFontSize - 3, weight: .bold)
                .foregroundStyle(Color.textGray)
                .padding(.trailing, .smallSpacing)
            }
          }
      }
      /// 사용자 인풋의 입력에 따라 유효성을 검증
      .onChange(of: inputText) {
        guard needValidation else { return }
        _ = validator?()
      }
    }
  }
}
