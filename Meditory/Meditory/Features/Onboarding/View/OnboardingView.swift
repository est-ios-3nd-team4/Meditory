//
//  OnboardingView.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

import SwiftUI

struct OnboardingView: View {
  @State private var currentStep: Step = .name
  @State private var showEndingSheet: Bool = false
  @State private var completedStep: Set<Step> = []
  @StateObject private var vm = OnboardingViewModel()

  var body: some View {
    VStack {
      VStack(alignment: .leading, spacing: 8) {
        GeometryReader { geometry in
          ZStack(alignment: .leading) {
            Capsule()
              .frame(height: 10)
              .foregroundColor(Color.gray.opacity(0.2))
            Capsule()
              .frame(width: geometry.size.width * CGFloat(completedStep.count) / CGFloat(Step.totalCount), height: 10)
              .foregroundColor(.accent)
              .animation(.easeInOut(duration: 0.3), value: currentStep)
          }
        }
        .frame(height: 10)
        .padding(.top, 10)
      }
      .padding(.horizontal)
      Spacer()
      stepContent(for: currentStep)
      Button(currentStep == Step.allCases.last ? "완료" : "다음") {
        if let next = currentStep.next(
          gender: vm.gender,
          isPregnancy: vm.isPregnancy,
          hasDisease: vm.hasDisease,
          hasAllergy: vm.hasAllergy,
          takesMedication: vm.takingMedication
        ) {
          if let currentScene = Step.allCases.firstIndex(of: currentStep),
            let nextScene = Step.allCases.firstIndex(of: next)
          {
            if currentScene <= nextScene {
              let skippedSteps = Step.allCases[currentScene...nextScene]
              completedStep.formUnion(skippedSteps)
            }
          }
          currentStep = next
        }
        if currentStep == Step.allCases.last {
          showEndingSheet = true
        }
      }
      .disabled(currentStep == Step.allCases.last)
      .frame(maxWidth: .infinity)
      .font(.notoSans(weight: .bold, size: 24))
      .padding()
      .background(Color.accent)
      .foregroundColor(.white)
      .cornerRadius(12)
      .padding(.horizontal)
      .padding(.bottom, 20)
    }
  }

  @ViewBuilder
  func stepContent(for step: Step) -> some View {
    if let question = Step.stepQuestions[step] {
      switch step {
        case .name:
          OnboardingTextInputView(prompt: question.title, placeholder: question.placeHolder ?? "", inputText: $vm.name)
        case .age:
          OnboardingTextInputView(
            prompt: question.title(name:vm.name),
            placeholder: question.placeHolder ?? "",
            keyboardType: UIKeyboardType.decimalPad,
            inputText: $vm.age
          )
        case .height:
          OnboardingTextInputView(
            prompt: question.title(name:vm.name),
            placeholder: question.placeHolder ?? "",
            unit: question.unit,
            keyboardType: UIKeyboardType.decimalPad,
            inputText: $vm.height
          )
        case .weight:
          OnboardingTextInputView(
            prompt: question.title(name:vm.name),
            placeholder: question.placeHolder ?? "",
            unit: question.unit,
            keyboardType: UIKeyboardType.decimalPad,
            inputText: $vm.weight
          )
        case .gender:
          OnboardingTwoOptionView(
            prompt: question.title(name:vm.name),
            isSelected: $vm.isSelected,
            image: Gender.male.image,
            title: Gender.male.title,
            action: {
              vm.gender = Gender.male.title
            },
            secondImage: Gender.female.image,
            secondTitle: Gender.female.title
          ) {
            vm.gender = Gender.female.title
          }
        case .pregnancy:
          OnboardingTwoOptionView(
            prompt: question.title(name:vm.name),
            isSelected: $vm.isSelected,
            image: YesOrNo.yes.image,
            title: YesOrNo.yes.title,
            action: {
              vm.isPregnancy = true
            },
            secondImage: YesOrNo.no.image,
            secondTitle: YesOrNo.no.title
          ) {
            vm.isPregnancy = false
          }
        case .breastfeeding:
          OnboardingTwoOptionView(
            prompt: question.title(name:vm.name),
            isSelected: $vm.isSelected,
            image: YesOrNo.yes.image,
            title: YesOrNo.yes.title,
            action: {
              vm.isBreastfeeding = true
            },
            secondImage: YesOrNo.no.image,
            secondTitle: YesOrNo.no.title
          ) {
            vm.isBreastfeeding = false
          }
        case .hasDisease:
          OnboardingTwoOptionView(
            prompt: question.title(name:vm.name),
            isSelected: $vm.hasDisease,
            image: YesOrNo.yes.image,
            title: YesOrNo.yes.title,
            action: {
              vm.hasDisease = true
            },
            secondImage: YesOrNo.no.image,
            secondTitle: YesOrNo.no.title
          ) {
            vm.hasDisease = false
          }
        case .selectDisease:
          OnboardingListSelectionView(
            prompt: question.title(name:vm.name),
            questions: Questions.diseases,
            selections: $vm.selectionSet
          ) { item in
            if vm.selectionSet.contains(item) {
              vm.selectionSet.remove(item)
            } else {
              vm.selectionSet.insert(item)
            }
          }
        case .hasAllergy:
          OnboardingTwoOptionView(
            prompt: question.title(name:vm.name),
            isSelected: $vm.hasAllergy,
            image: YesOrNo.yes.image,
            title: YesOrNo.yes.title,
            action: {
              vm.hasAllergy = true
            },
            secondImage: YesOrNo.no.image,
            secondTitle: YesOrNo.no.title
          ) {
            vm.hasAllergy = false
          }
        case .selectAllergy:
          OnboardingListSelectionView(
            prompt: question.title(name:vm.name),
            info: question.info,
            questions: Questions.allergy,
            selections: $vm.selectionSet
          ) { item in
            if vm.selectionSet.contains(item) {
              vm.selectionSet.remove(item)
            } else {
              vm.selectionSet.insert(item)
            }
          }
        case .takingMedication:
          OnboardingTwoOptionView(
            prompt: question.title(name:vm.name),
            isSelected: $vm.takingMedication,
            image: YesOrNo.yes.image,
            title: YesOrNo.yes.title,
            action: {
              vm.takingMedication = true
            },
            secondImage: YesOrNo.no.image,
            secondTitle: YesOrNo.no.title
          ) {
            vm.takingMedication = false
          }
        case .selectMedication:
          OnboardingListSelectionView(
            prompt: question.title(name:vm.name),
            questions: Questions.medication,
            selections: $vm.selectionSet
          ) {
            item in
            if vm.selectionSet.contains(item) {
              vm.selectionSet.remove(item)
            } else {
              vm.selectionSet.insert(item)
            }
          }
        case .end:
          EmptyView()
      }
    }
  }
}

#Preview {
  OnboardingView()
}
