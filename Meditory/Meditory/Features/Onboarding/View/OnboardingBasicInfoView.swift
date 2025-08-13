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
          inputText: $vm.name,
          needValidation: true,
          validator: { vm.validateName(context: vm.name) },
          isValid: $vm.isValid
        )
        TextInputView(
          placeholder: "출생년도",
          unit: "년",
          keyboardType: .decimalPad,
          inputText: $vm.age,
          needValidation: true,
          validator: {
            if vm.age.contains(".") { return true }
            guard vm.age.count == 8 else { return true }
            let (formatted, date) = DateFormatter.plainStringToDate(plainString: vm.age)
            if let date = date {
              Task {
                await MainActor.run { vm.age = formatted }
              }
              vm.birthDate = date
              return true
            } else {
              vm.birthDate = nil
              return false
            }
          },
          isValid: $vm.isValid
        )
        TextInputView(
          placeholder: "키",
          unit: "cm",
          keyboardType: .decimalPad,
          inputText: $vm.height,
          needValidation: true,
          validator: { vm.validateHeightAndWeight(context: vm.height) },
          isValid: $vm.isValid
        )
        TextInputView(
          placeholder: "체중",
          unit: "kg",
          keyboardType: .decimalPad,
          inputText: $vm.weight,
          needValidation: true,
          validator: { vm.validateHeightAndWeight(context: vm.weight) },
          isValid: $vm.isValid
        )
      }
      Spacer()
    }
    .padding(.horizontal,.defaultSpacing+4)
    .frame(maxWidth: .infinity)
  }
}
