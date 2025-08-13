//
//  OnboardingBasicInfoView.swift
//  Meditory
//
//  Created by hyunsic on 8/11/25.
//
import SwiftUI

struct OnboardingBasicInfoView: View {
  @ObservedObject var vm: OnboardingViewModel
  var prompt: PromptMessage

  var body: some View {
    VStack {
      HStack {
        VStack(alignment: .leading) {
          Text(prompt.title)
            .font(.notoSans(weight: .bold, size: 28))
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .layoutPriority(1)
            .padding(.vertical,10)
          if let info = prompt.info {
            Text(info)
              .font(.notoSans(weight: .medium, size: 16))
              .foregroundStyle(.textGray)
          }
        }
        Spacer()
      }
      .padding(.bottom, .defaultSpacing + 4)
      VStack(spacing: .defaultSpacing) {
        TextInputView(
          placeholder: "이름",
          inputText: vm.binding(for: .name),
          needValidation: true,
          validator: {vm.isValid(for: .name)},
        )
        TextInputView(
          placeholder: "출생년도",
          unit: "년",
          keyboardType: .decimalPad,
          inputText: vm.binding(for: .birthDate),
          needValidation: true,
          validator: {vm.isValid(for: .birthDate)},
        )
        TextInputView(
          placeholder: "키",
          unit: "cm",
          keyboardType: .decimalPad,
          inputText: vm.binding(for: .height),
          needValidation: true,
          validator: { vm.isValid(for: .height) },
        )
        TextInputView(
          placeholder: "체중",
          unit: "kg",
          keyboardType: .decimalPad,
          inputText: vm.binding(for: .weight),
          needValidation: true,
          validator: { vm.isValid(for: .weight) }
        )
      }
      Spacer()
    }
    .padding(.horizontal,.defaultSpacing+4)
    .frame(maxWidth: .infinity)
  }
}
