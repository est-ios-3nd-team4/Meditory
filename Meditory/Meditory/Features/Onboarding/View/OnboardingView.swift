//
//  OnboardingView.swift
//  Meditory
//
//  Created by hyunsic on 8/11/25.
//

import SwiftData
import SwiftUI

enum FormField: Hashable {
  case name
  case birthDate
  case height
  case weight
}

struct OnboardingView: View {
  let onFinished: () -> Void
  @State private var currentStep: Step = .base

  @StateObject var vm: OnboardingViewModel
  @StateObject private var keyboardObserver = KeyboardObserver()
  @FocusState private var focusedField: FormField?

  @Environment(\.modelContext) var context: ModelContext

  private let buttonHeight: CGFloat = 50
  private let buttonTopSpacing: CGFloat = 8

  init(userStore: UserStore, onFinished: @escaping () -> Void = {}) {
    self.onFinished = onFinished
    _vm = StateObject(wrappedValue: OnboardingViewModel(userStore: userStore))
  }

  var body: some View {
    VStack {
      progressIndicator()
      if currentStep == .base {
        OnboardingBasicInfoView(
          vm: vm,
          focusedField: $focusedField,
          bottomSpacing: keyboardObserver.bottomInset + 50
        )
      } else {
        setContent(for: currentStep)
      }
      Spacer(minLength: 0)
      nextButton()
    }
  }

  @ViewBuilder
  func setContent(for step: Step) -> some View {
    if let prompt = Step.prompt[step] {
      let name = vm.name
      switch step {
      case .gender:
        OnboardingGenderView(
          vm: vm,
          prompt: prompt,
          name: name,
          isSelected: $vm.isSelected,
          isValid: $vm.isValid,
          selections: $vm.selectionSet,
          image: Gender.male.image,
          title: Gender.male.title,
          secondImage: Gender.female.image,
          secondTitle: Gender.female.title,
          onAction: { model in
            if vm.selectionSet.contains(model) {
              vm.selectionSet.remove(model)
            } else {
              vm.selectionSet.insert(model)
            }
          }
        )
      case .allergy:
        OnboardingAllergyView(
          prompt: prompt,
          name: name,
          selections: $vm.selectionSet,
          isSelected: $vm.isSelected
        ) { item in
          if vm.selectionSet.contains(item) {
            vm.selectionSet.remove(item)
          } else {
            vm.selectionSet.insert(item)
          }
        }
      case .disease:
        OnboardingDiseaseView(
          prompt: prompt,
          name: name,
          selections: $vm.selectionSet,
          isSelected: $vm.isSelected
        ) { item in
          if vm.selectionSet.contains(item) {
            vm.selectionSet.remove(item)
          } else {
            vm.selectionSet.insert(item)
          }
        }
      case .concern:
        OnboardingConcernView(
          prompt: prompt,
          name: name,
          selections: $vm.selectionSet,
          isSelected: $vm.isSelected
        ) { item in
          if vm.selectionSet.contains(item) {
            vm.selectionSet.remove(item)
          } else {
            vm.selectionSet.insert(item)
          }
        }
      default:
        EmptyView()
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
          withAnimation {
            currentStep = next
          }
        } else {
          onFinished()
          vm.signUp(context: context)
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
      .disabled(!vm.isNextButtonOn)
      .padding(.vertical, buttonTopSpacing)
    }
    .padding(.horizontal, .defaultSpacing + 4)
  }
}

#Preview {
  //  OnboardingView()
}
