//
//  OnboardingDiseaseView.swift
//  Meditory
//
//  Created by hyunsic on 8/8/25.
//

import SwiftUI

struct OnboardingConcernView: View {
  let items = QuestionModel.concernModel
  let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]
  let prompt: Prompt
  let name: String
  @Binding var selections: Set<QuestionModel>
  @Binding var isSelected: Bool
  var onAction: ((QuestionModel) -> Void)?
  var body: some View {
    ScrollView {
      TitleView(prompt: prompt)
        .padding([.horizontal], .defaultSpacing + 4)
      OnboardingFlowLayoutLineLimit(items: items, content: { item in
        CapsuleShappedText(title: item.title,isSelected: selections.contains(item))
          .onTapGesture {
            onAction?(item)
          }
      })
      .padding(.horizontal, .defaultSpacing + 4)
    }
    .scrollIndicators(.never)
  }
}

#Preview {
  OnboardingConcernView(
    prompt: Prompt(title: "고민되시거나 개선하고 싶은 건강 고민을 선택해주세요"),
    name: "Jason",
    selections: .constant(.init()),
    isSelected: .constant(false)
  )
}
