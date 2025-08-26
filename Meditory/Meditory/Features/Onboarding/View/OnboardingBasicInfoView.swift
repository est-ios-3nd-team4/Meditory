//
//  OnboardingBasicInfoView.swift
//  Meditory
//
//  Created by hyunsic on 8/11/25.
//
import SwiftUI

struct OnboardingBasicInfoView: View {
  var vm: OnboardingViewModel
  let focusedField: FocusState<FormField?>.Binding
  let bottomSpacing: CGFloat

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView(.vertical) {
        VStack {
          if let prompt = Prompt.promptMessage[.base] {
            TitleView(prompt: prompt)
          }
          VStack(spacing: .defaultSpacing) {
            TextInputView(
              title: "이름",
              placeholder: "홍길동",
              inputText: vm.binding(for: .name),
              needValidation: true,
              validator: { vm.isValid(for: .name) },
              errorMessage: vm.errorMessage[.name],
              onAction:{
                focusedField.wrappedValue = .birthDate
              },
            )
            .id(FormField.name)
            .focused(focusedField, equals: .name)
            TextInputView(
              title: "출생년도",
              placeholder: "2000",
              unit: "년",
              keyboardType: .decimalPad,
              inputText: vm.binding(for: .birthDate),
              needValidation: true,
              validator: { vm.isValid(for: .birthDate) },
              errorMessage: vm.errorMessage[.birthDate],
            )
            .onChange(of: vm.birthDate, { 
              focusedField.wrappedValue = .height
            })
            .id(FormField.birthDate)
            .focused(focusedField, equals: .birthDate)
            TextInputView(
              title: "키",
              placeholder: "170",
              unit: "cm",
              keyboardType: .decimalPad,
              inputText: vm.binding(for: .height),
              needValidation: true,
              validator: { vm.isValid(for: .height) },
              errorMessage: vm.errorMessage[.height],
            )
            .id(FormField.height)
            .focused(focusedField, equals: .height)
            .onChange(of: vm.height) {
              focusedField.wrappedValue = .weight
            }
            TextInputView(
              title: "체중",
              placeholder: "80",
              unit: "kg",
              keyboardType: .decimalPad,
              inputText: vm.binding(for: .weight),
              needValidation: true,
              validator: { vm.isValid(for: .weight) },
              errorMessage: vm.errorMessage[.weight],
            )
            .id(FormField.weight)
            .focused(focusedField, equals: .weight)
          }
          .padding(.top,-18)
        }
        .padding(.horizontal, .defaultSpacing + 4)
        .padding(.bottom, bottomSpacing)
        .onChange(of: focusedField.wrappedValue) {
          scroll(proxy)
        }
      }
      .scrollIndicators(.never)
    }
  }
  private func scroll(_ proxy: ScrollViewProxy) {
    guard let id = focusedField.wrappedValue else { return }
    withAnimation(.easeOut(duration: 0.2)) {
      proxy.scrollTo(id, anchor: .bottom)
    }
  }
}
