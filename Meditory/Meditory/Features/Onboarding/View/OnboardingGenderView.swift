//
//  OnboardingGenderView.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

import SwiftUI

struct OnboardingGenderView: View {
  @ObservedObject var vm: OnboardingViewModel
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
        ImageWithTitle(gender: Gender.female, isSelected: vm.gender == Gender.female.title) {
          vm.gender = Gender.female.title
        }
        Spacer()
      }
    }
    .padding(.horizontal, .defaultSpacing + 4)
    .frame(maxWidth: .infinity)
    .padding(.bottom, 20)
    VStack(alignment: .leading, spacing: .defaultSpacing) {
      if let info = prompt.info {
        Text(info)
          .font(.notoSans(weight: .medium, size: 16))
          .foregroundStyle(.textGray)
          .padding(.bottom,.defaultSpacing)
      }
        ForEach(question, id: \.self) { item in
          RowItemCell(model: item, isSelected: vm.selectionSet.contains(item), subTitleSize: 12)
            .onTapGesture {
              onAction?(item)
            }
        }
      }
    .padding(.horizontal, .defaultSpacing + 4)
    .opacity(vm.gender != Gender.male.title ? 1 : 0)
    .allowsHitTesting(vm.gender != Gender.male.title)
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
