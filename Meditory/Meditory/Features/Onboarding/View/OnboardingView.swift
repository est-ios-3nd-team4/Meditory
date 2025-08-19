//
//  OnboardingView.swift
//  Meditory
//
//  Created by hyunsic on 8/11/25.
//

import SwiftData
import SwiftUI

struct OnboardingView: View {
  @Environment(\.modelContext) var context: ModelContext

  @StateObject var vm: OnboardingViewModel
  @StateObject private var keyboardObserver = KeyboardObserver()
  @FocusState private var focusedField: FormField?

  @State private var currentStep: Step = .base
  @State private var isSelected: Bool = false

  private let buttonHeight: CGFloat = 50
  private let buttonTopSpacing: CGFloat = 8
  private let onFinished: () -> Void

  init(userStore: UserStore, onFinished: @escaping () -> Void = {}) {
    self.onFinished = onFinished
    _vm = StateObject(wrappedValue: OnboardingViewModel(userStore: userStore))
  }

  var body: some View {
    VStack {
      progressIndicator()
      setContent(for: currentStep)
      Spacer(minLength: 0)
      nextButton()
    }
  }

  @ViewBuilder
  func setContent(for step: Step) -> some View {
    if let prompt = Prompt.promptMessage[step] {
      let name = vm.name
      switch step {
      case .base:
        OnboardingBasicInfoView(vm: vm, focusedField: $focusedField, bottomSpacing: keyboardObserver.bottomInset + 50)
      case .gender:
        OnboardingGenderView(
          vm: vm,
          isSelected: $isSelected,
          prompt: prompt,
          name: name,
          onAction: {
            selectItem(item: $0, vm: vm)
          }
        )
      case .allergy:
        OnboardingAllergyView(
          prompt: prompt,
          name: name,
          selections: $vm.selectionSet,
          isSelected: $isSelected
        ) {
          selectItem(item: $0, vm: vm)
        }
      case .disease:
        OnboardingDiseaseView(
          prompt: prompt,
          name: name,
          selections: $vm.selectionSet,
          isSelected: $isSelected
        ) {
          selectItem(item: $0, vm: vm)
        }
      case .concern:
        OnboardingConcernView(
          prompt: prompt,
          name: name,
          selections: $vm.selectionSet,
          isSelected: $isSelected
        ) { selectItem(item: $0, vm: vm) }
      }
    }
  }

  @ViewBuilder
  func progressIndicator() -> some View {
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: Step.totalCount)
    HStack {
      LazyVGrid(columns: columns) {
        ForEach(Step.allCases, id: \.self) { index in
          Text(String(index.rawValue + 1))
            .font(.notoSans(size: 13))
            .foregroundStyle(index == currentStep ? Color.white : Color.gray)
            .frame(width: 25, height: 25)
            .background {
              Circle()
                .fill(index == currentStep ? Color.main : Color.gray.opacity(0.2))
            }
        }
      }
      .frame(width: 160)
      .padding(.horizontal, .defaultSpacing + 4)
      Spacer()
    }
    .padding(.top, 60)
  }

  @ViewBuilder
  func nextButton() -> some View {
    VStack(spacing: .smallSpacing) {
      Button {
        if let next = currentStep.nextView() {
          if currentStep == .base {
            vm.validateAllField()
          }
          currentStep = next
        } else {
          onFinished()
          vm.signUp(context: context)
          print(vm.selectionSet)
        }
      } label: {
        RoundedRectangle(cornerRadius: .smallRadius)
          .fill(vm.isNextButtonOn ? Color.main : Color.gray.opacity(0.4))
          .frame(height: 50)
          .overlay {
            Text(currentStep != .concern ? "다음" : "완료")
              .font(.notoSans(weight: .semiBold, size: 18))
              .foregroundStyle(.white)
          }
      }
      //      .disabled(!vm.isNextButtonOn)
      .padding(.vertical, buttonTopSpacing)
    }
    .padding(.horizontal, .defaultSpacing + 4)
  }

  func selectItem(item: QuestionModel, vm: OnboardingViewModel) {
    if vm.selectionSet.contains(item) {
      vm.selectionSet.remove(item)
    } else {
      vm.selectionSet.insert(item)
    }
  }
}

#Preview {
  //  OnboardingView()
}
