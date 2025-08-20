//
//  OnboardingAllergyView.swift
//  Meditory
//
//  Created by hyunsic on 8/5/25.
//

import SwiftUI

struct OnboardingAllergyView: View {
  let prompt:Prompt
  let name:String
  var questions = QuestionModel.allergyModel
  @Binding var selections: Set<QuestionModel>
  @Binding var isSelected: Bool
  var onAction: ((QuestionModel) -> Void)?
  var body: some View {
    ScrollView {
      TitleView(prompt: prompt)
      .padding([.horizontal],.defaultSpacing + 4)
      ForEach(questions, id: \.self) { item in
        RowItemCell(model: item, isSelected: selections.contains(item))
          .onTapGesture {
            onAction?(item)
          }
      }
      .padding(.horizontal, .defaultSpacing + 4)
    }
    .scrollIndicators(.never)
  }
}
