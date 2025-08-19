//
//  OnboardingAllergyView.swift
//  Meditory
//
//  Created by hyunsic on 8/5/25.
//

import SwiftUI

struct OnboardingAllergyView: View {
  let prompt:PromptMessage
  let name:String
  var questions = QuestionModel.allergyModel
  @Binding var selections: Set<QuestionModel>
  @Binding var isSelected: Bool
  var onAction: ((QuestionModel) -> Void)?
  var body: some View {
    ScrollView {
      HStack {
        VStack(alignment: .leading, ) {
          Text(prompt.title(name: name))
            .font(.notoSans(weight: .bold, size: 28))
            .padding(.vertical, 10)
          if let info = prompt.info {
            Text(info)
              .font(.notoSans(weight: .bold, size: 16))
              .foregroundStyle(.textGray)
          }
        }
        Spacer()
      }
      .padding([.bottom,.horizontal],.defaultSpacing + 4)
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
