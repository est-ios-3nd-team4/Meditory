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
  var itemCount: String
  @Binding var selections: Set<QuestionModel>
  @Binding var isSelected: Bool
  var onAction: ((QuestionModel) -> Void)?
  var body: some View {
    ScrollView {
      TitleView(prompt: prompt,extra: itemCount)
        .padding(.horizontal, .defaultSpacing + 4)
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

