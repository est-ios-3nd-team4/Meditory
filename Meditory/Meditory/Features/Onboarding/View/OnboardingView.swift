//
//  OnboardingView.swift
//  Meditory
//
//  Created by hyunsic on 8/11/25.
//

import SwiftUI

struct OnboardingView: View {
  @State private var currentStep: Step = .base
  @State private var chosen: Bool = false

  @StateObject var vm: OnboardingViewModel = OnboardingViewModel()

  private let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: Step.totalCount)

  var body: some View {
    VStack {
      HStack {
        LazyVGrid(columns: columns) {
          ForEach(Step.allCases, id: \.self) { index in
            Text(String(index.rawValue + 1))
              .font(.notoSans(size: 13))
              .foregroundStyle(index == currentStep ? Color.white : Color.gray)
              .background {
                Circle()
                  .fill(index == currentStep ? Color.main : Color.gray.opacity(0.4))
                  .frame(width: 25, height: 25)
              }
          }
        }
        .frame(width: 160)
        .padding(.horizontal)
        Spacer()
      }
      .padding(.top, 60)
      setContent(for: currentStep)
      Button {
        if let next = currentStep.nextView() {
          currentStep = next
        }
        if currentStep == .concern {
          print(vm.selectionSet)
        }
      } label: {
        RoundedRectangle(cornerRadius: .smallRadius)
          .fill(vm.isValid != true ? Color.gray.opacity(0.4) : .main)
          .frame(height: 50)
          .overlay {
            Text(currentStep != .concern ? "다음" : "완료")
              .font(.notoSans(weight: .semiBold, size: 18))
              .foregroundStyle(.white)
          }
      }
      .padding(.horizontal, .defaultSpacing + 4)
    }
  }

  @ViewBuilder
  func setContent(for step: Step) -> some View {
    if let question = Step.question[step] {
      switch step {
      case .base:
        OnboardingBaseView(vm: vm, question: question)
      case .gender:
        OnboardingTwoOptionView(
          prompt: question.title(name: vm.name),
          info: question.subtitle,
          isSelected: $vm.isSelected,
          isGenderSelected: $vm.isGenderSelected,
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
        OnboardingListView(
          prompt: question.title(name: vm.name),
          info: "알레르기에 따라 피해야하는 영양성분을 확인할 수 있어요",
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
        OnboardingCollectionView(
          prompt: question.title(name: vm.name),
          info: question.subtitle,
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
        OnboardingCollectionView(
          prompt: question.title(name: vm.name),
          info: question.subtitle,
          selections: $vm.selectionSet,
          isSelected: $vm.isSelected
        ) { item in
          if vm.selectionSet.contains(item) {
            vm.selectionSet.remove(item)
          } else {
            vm.selectionSet.insert(item)
          }
        }
      }
    }
  }
}

#Preview {
  OnboardingView()
}
