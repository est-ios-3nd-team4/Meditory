//
//  OnboardingDiseaseView.swift
//  Meditory
//
//  Created by hyunsic on 8/8/25.
//

import SwiftUI

struct OnboardingDiseaseView: View {
  let isPad = UIDevice.isPad
  let items = QuestionModel.diseaseModel
  let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]
  let padColumns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible())
  ]
  let prompt: Prompt
  let name: String
  @Binding var selections: Set<QuestionModel>
  @Binding var isSelected: Bool
  var onAction: ((QuestionModel) -> Void)?
  var body: some View {
    ScrollView {
      TitleView(prompt: prompt,name:name)
      .padding(.horizontal, .defaultSpacing + 4)
      LazyVGrid(columns: columns, spacing: 24) {
        ForEach(items, id: \.title) { item in
          CollectionItemCell(model: item, isSelected: selections.contains(item))
            .onTapGesture {
              onAction?(item)
            }
        }
      }
      .padding(.horizontal,.defaultSpacing + 4)
    }
    .scrollIndicators(.never)
  }
}

#Preview {
  OnboardingDiseaseView(
    prompt: Prompt(title: "고민되시거나 개선하고 싶은 건강 고민을 선택해주세요"),
    name: "Jason",
    selections: .constant(.init()),
    isSelected: .constant(false)
  )
}
