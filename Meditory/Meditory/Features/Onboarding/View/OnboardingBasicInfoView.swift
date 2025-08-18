//
//  OnboardingBasicInfoView.swift
//  Meditory
//
//  Created by hyunsic on 8/11/25.
//
import SwiftUI

struct OnboardingBasicInfoView: View {
  @ObservedObject var vm: OnboardingViewModel
  let focusedField: FocusState<FormField?>.Binding
  let bottomSpacing: CGFloat

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView(.vertical) {
        VStack {
          if let prompt = Step.prompt[.base] {
            HStack {
              VStack(alignment: .leading) {
                Text(prompt.title)
                  .font(.notoSans(weight: .bold, size: 28))
                  .padding(.vertical, 10)
                if let info = prompt.info {
                  Text(info)
                    .font(.notoSans(weight: .medium, size: 16))
                    .foregroundStyle(.textGray)
                }
              }
              Spacer()
            }
            .padding(.bottom, .defaultSpacing + 4)
//            TopTitleView(prompt: prompt)
          }
          VStack(spacing: .defaultSpacing) {
            TextInputView(
              placeholder: "이름",
              inputText: vm.binding(for: .name),
              needValidation: true,
              validator: { vm.isValid(for: .name) },
            )
            .id(FormField.name)
            .focused(focusedField, equals: .name)
            TextInputView(
              placeholder: "출생년도",
              unit: "년",
              keyboardType: .decimalPad,
              inputText: vm.binding(for: .birthDate),
              needValidation: true,
              validator: { vm.isValid(for: .birthDate) },
            )
            .id(FormField.birthDate)
            .focused(focusedField, equals: .birthDate)
            TextInputView(
              placeholder: "키",
              unit: "cm",
              keyboardType: .decimalPad,
              inputText: vm.binding(for: .height),
              needValidation: true,
              validator: { vm.isValid(for: .height) },
            )
            .id(FormField.height)
            .focused(focusedField, equals: .height)
            TextInputView(
              placeholder: "체중",
              unit: "kg",
              keyboardType: .decimalPad,
              inputText: vm.binding(for: .weight),
              needValidation: true,
              validator: { vm.isValid(for: .weight) }
            )
            .id(FormField.weight)
            .focused(focusedField, equals: .weight)
          }
          Spacer()
        }
        .padding(.horizontal, .defaultSpacing + 4)
        .padding(.bottom, bottomSpacing)
        .onChange(of: focusedField.wrappedValue) {
          scroll(proxy)
        }
      }
      .scrollIndicators(.never)
      .onAppear {
        scroll(proxy)
      }
    }
  }
  private func scroll(_ proxy: ScrollViewProxy) {
    guard let id = focusedField.wrappedValue else { return }
    withAnimation(.easeOut(duration: 0.2)) {
      proxy.scrollTo(id, anchor: .bottom)
    }
  }
}
