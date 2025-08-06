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
      .onChange(of: currentStep) { _, newValue in
        print(newValue.rawValue)
      }
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
    switch step {
    case .name:
      OnboardingTextInputView(prompt: "고객님의 \n이름을 알려주세요", placeholder: "이름", inputText: $vm.name)
    case .age:
      OnboardingTextInputView(
        prompt: "\(vm.name)님의 나이를 알려주세요",
        placeholder: "연령",
        keyboardType: UIKeyboardType.numberPad,
        inputText: $vm.age
      )
    case .height:
      OnboardingTextInputView(
        prompt: "\(vm.name)님의 키를 알려주세요",
        placeholder: "신장",
        unit: "CM",
        keyboardType: UIKeyboardType.numberPad,
        inputText: $vm.height
      )
    case .weight:
      OnboardingTextInputView(
        prompt: "\(vm.name)님의 몸무게를 알려주세요",
        placeholder: "체중",
        unit: "KG",
        keyboardType: UIKeyboardType.numberPad,
        inputText: $vm.weight
      )
    case .gender:
      OnboardingTwoOptionView(
        prompt: "\(vm.name) 님의 성별을 알려주세요",
        isSelected: $vm.isSelected,
        image: "male_icon",
        title: "남성",
        action: {
          vm.gender = "남성"
        },
        secondImage: "female_icon",
        secondTitle: "여성"
      ) {
        vm.gender = "여성"
      }
    case .pregnancy:
      OnboardingTwoOptionView(
        prompt: "\(vm.name) 님은 현재 임신중이십니까?",
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
        prompt: "\(vm.name) 님은 현재 수유중이신가요?",
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
        prompt: "\(vm.name) 님은 현재 질병이 있으신가요?",
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
        prompt: "\(vm.name) 님이 앓고계신 질환을 알려주세요",
        questions: questions.diseases,
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
        prompt: "\(vm.name) 님은 식품에 알레르기가 있으신가요?",
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
        prompt: "\(vm.name) 님이 갖고 있는 모든 알러지를 선택해 주세요",
        info: "알레르기에 따라 피해야하는 영양성분을 확인할 수 있어요",
        questions: questions.allergy,
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
        prompt: "\(vm.name) 님은 현재 복용중인 약물이 있으신가요?",
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
        prompt: "\(vm.name) 님이 복용중이신 약물을 모두 선택해 주세요",
        questions: questions.medication,
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

#Preview {
  OnboardingView()
}
