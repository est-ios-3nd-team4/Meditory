//
//  OnboardingGenderView.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

import SwiftUI

struct OnboardingGenderView: View {
  let isPad = UIDevice.isPad
  var vm: OnboardingViewModel
  @Environment(\.colorScheme) var colorScheme
  @Binding var isSelected: Bool
  var prompt: Prompt
  var name: String
  var onAction: ((QuestionModel) -> Void)?
  var question = QuestionModel.feminineModel

  var body: some View {
    VStack {
      TitleView(prompt: prompt,name: name)
      HStack(spacing: .defaultSpacing * 2) {
        Spacer()
        ImageWithTitle(gender: Gender.male, isSelected: vm.gender == Gender.male.title) {
          vm.gender = Gender.male.title
        }
        if isPad {
          Spacer()
        }
        ImageWithTitle(gender: Gender.female, isSelected: vm.gender == Gender.female.title) {
          vm.gender = Gender.female.title
        }
        Spacer()
      }
    }
    .padding(.horizontal, .defaultSpacing + 4)
    .frame(maxWidth: .infinity)
    .adaptivePadding(.bottom, 20,small: -10)
    VStack(alignment: .leading, spacing: .defaultSpacing) {
        Text("아래에 해당하는 상태가 있다면 선택해주세요.")
          .adaptiveFont(.defaultFontSize - 2 ,weight: .medium)
          .foregroundStyle(.textGray)
          .padding(.bottom,.defaultSpacing)
        ForEach(question, id: \.self) { item in
          RowItemCell(model: item, isSelected: vm.selectionSet.contains(item))
            .onTapGesture {
              onAction?(item)
            }
        }
      }
    .padding(.horizontal, .defaultSpacing + 4)
    .opacity(vm.gender == Gender.female.title ? 1 : 0)
    .allowsHitTesting(vm.gender == Gender.female.title)
  }

}

#Preview {
  //  OnboardingGenderView(
  //    vm: OnboardingViewModel(), prompt: promptMessage(title: "성별"), name: "Jason",
  //    isSelected: .constant(true),
  //    isGenderSelected: false,
  //    isValid: .constant(true),
  //    selections: .constant(.init()),
  //    image: "male_icon",
  //    title: "남성",
  //    action: nil,
  //    secondImage: "female_icon",
  //    secondTitle: "여성",
  //    secondAction: nil,
  //
  //  )
}
