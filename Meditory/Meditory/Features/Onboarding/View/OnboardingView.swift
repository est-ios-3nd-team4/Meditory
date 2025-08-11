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
  @StateObject private var userStore = UserStore()

  var buttonLabel: String {
    let base = (currentStep == Step.allCases.last ? "완료" : "다음")
    switch currentStep {
//      case .selectAllergy:
//        return base + "\(vm.selectionSet.count)/\t9\(Questions.allergy.count)"
//      case .selectDisease:
//        return base + "\(vm.selectionSet.count)/\(Questions.diseases.count)"
//      case .selectMedication:
//        return base + "\(vm.selectionSet.count)/\(Questions.medication.count)"
      default:
        return base
    }
  }
  
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
              .foregroundColor(.main)
              .animation(.easeInOut(duration: 0.3), value: currentStep)
          }
        }
        .frame(height: 10)
        .padding(.top, 10)
      }
      .padding(.horizontal)
      Spacer()
      stepContent(for: currentStep)
      Button(/*currentStep == Step.allCases.last ? "완료" : "다음"*/buttonLabel) {
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
      .disabled(currentStep == Step.allCases.last || vm.isValid != true)
      .frame(maxWidth: .infinity)
      .font(.notoSans(weight: .bold, size: 24))
      .padding()
      .background(vm.isValid != true ? Color.backgroundGray : Color.main)
      .foregroundColor(.white)
      .cornerRadius(10)
      .padding(.horizontal)
      .padding(.bottom, 20)
    }
  }

  @ViewBuilder
  func stepContent(for step: Step) -> some View {
    if let question = Step.stepQuestions[step] {
      switch step {
        case .name:
          OnboardingTextInputView(
            prompt: question.title,
            placeholder: question.placeHolder ?? "",
            inputText: $vm.name,
            needValidation:true,
            validator:{vm.validateName(context: vm.name)},
            isValid:$vm.isValid)
        case .birthDate:
          OnboardingTextInputView(
            prompt: question.title(name:vm.name),
            placeholder: question.placeHolder ?? "",
            keyboardType: UIKeyboardType.decimalPad,
            inputText: $vm.age,
            needValidation:true,
            validator:{
              if vm.age.contains("."){ return true }
              guard vm.age.count == 8 else { return false }
              let (formatted,date) = DateFormatter.plainStringToDate(plainString: vm.age)
              if let date = date {
                Task{
                  await MainActor.run {vm.age = formatted}
                }
                vm.birthDate = date
                return true
              } else {
                vm.birthDate = nil
                return false
              }
              
            },
            isValid:$vm.isValid
          )
        case .height:
          OnboardingTextInputView(
            prompt: question.title(name:vm.name),
            placeholder: question.placeHolder ?? "",
            unit: question.unit,
            keyboardType: UIKeyboardType.decimalPad,
            inputText: $vm.height,
            needValidation:true,
            validator:{vm.validateHeightAndWeight(context: vm.height)},
            isValid:$vm.isValid
          )
        case .weight:
          OnboardingTextInputView(
            prompt: question.title(name:vm.name),
            placeholder: question.placeHolder ?? "",
            unit: question.unit,
            keyboardType: UIKeyboardType.decimalPad,
            inputText: $vm.weight,
            needValidation:true,
            validator:{vm.validateHeightAndWeight(context: vm.weight)},
            isValid:$vm.isValid
          )
        case .gender:
          OnboardingTwoOptionView(
            prompt: question.title(name:vm.name),
            info: question.info,
            isSelected: $vm.isSelected,
            isValid:$vm.isValid,
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
            info: question.info,
            isSelected: $vm.isSelected,
            isValid:$vm.isValid,
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
            isValid:$vm.isValid,
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
            isValid:$vm.isValid,
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
            isValid:$vm.isValid,
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
            isValid:$vm.isValid,
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
        case .recommendation:
          OnboardingCollectionItemsView(prompt: question.title,info:question.info)
      }
    }
  }
}

#Preview {
  OnboardingView()
}
