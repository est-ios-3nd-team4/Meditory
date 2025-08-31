//
//  OnboardingBasicInfoView.swift
//  Meditory
//
//  Created by hyunsic on 8/11/25.
//
import SwiftUI

/// 기본 설문 정보를 입력받는 뷰
struct OnboardingBasicInfoView: View {
  
  // MARK: - 뷰 속성
  var vm: OnboardingViewModel
  
  @State private var preScroll: FormField? = nil
  @State private var scrollTask: Task<Void,Never>? = nil
  
  let focusedField: FocusState<FormField?>.Binding
  let bottomSpacing: CGFloat
  let isInitialLoadComplete: Bool
  let isEditing: Bool
  
  // MARK: - 뷰 바디
  var body: some View {
    /// 스크롤 뷰의 위치를 읽어오기 위한 리더
    ScrollViewReader { proxy in
      ScrollView(.vertical) {
        VStack {
          /// 상단 텍스트 뷰
          if let prompt = Prompt.promptMessage[.base] {
            TitleView(prompt: prompt)
          }
          VStack(spacing: .defaultSpacing) {
            /// 이름 입력 텍스트뷰
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
            /// 출생년도 입력 텍스트뷰
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
              if !isEditing || isEditing && !isInitialLoadComplete {
                focusedField.wrappedValue = .height
              }
            })
            .id(FormField.birthDate)
            .focused(focusedField, equals: .birthDate)
            /// 키 입력 텍스트뷰
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
              if !isEditing || isEditing && !isInitialLoadComplete {
                focusedField.wrappedValue = .weight
              }
            }
            /// 체중 입력 텍스트뷰
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
          scrollTask?.cancel()
          scrollTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.1))
            scroll(proxy)
          }
        }
      }
      .scrollIndicators(.never)
    }
  }
  
  /// 포커스 변화에 따라 스크롤 하는 메소드
  private func scroll(_ proxy: ScrollViewProxy) {
    guard let id = focusedField.wrappedValue else { return }
    if preScroll != id {
      var transaction = Transaction()
      transaction.disablesAnimations = true
      withTransaction(transaction) {
        proxy.scrollTo(id, anchor: .bottom)
        preScroll = id
        return
      }
    }
    withAnimation(.easeOut(duration: 0.15)) {
      proxy.scrollTo(id, anchor: .bottom)
    }
  }
}
