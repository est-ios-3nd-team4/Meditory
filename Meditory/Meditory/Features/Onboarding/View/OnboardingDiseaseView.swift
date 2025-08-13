//
//  OnboardingDiseaseView.swift
//  Meditory
//
//  Created by hyunsic on 8/8/25.
//

import SwiftUI

struct OnboardingDiseaseView: View {
  let items = QuestionModel.diseaseModel
  let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]
  let prompt: PromptMessage
  let name: String
  @Binding var selections: Set<QuestionModel>
  @Binding var isSelected: Bool
  var onAction: ((QuestionModel) -> Void)?
  var body: some View {
    ScrollView {
    HStack {
      VStack(alignment: .leading) {
        Text(prompt.title(name: name))
          .font(.notoSans(weight: .bold, size: 24))
          .padding(.vertical, 10)
        if let info = prompt.info {
          Text(info)
            .font(.notoSans(weight: .bold, size: 16))
            .foregroundStyle(.textGray)
        }
      }
      Spacer()
    }
    .padding([.horizontal], .defaultSpacing + 4)
      LazyVGrid(columns: columns) {
        ForEach(items, id: \.title) { item in
          CollectionItemCell(model: item, isSelected: selections.contains(item))
            .onTapGesture {
              onAction?(item)
            }
        }
      }
    }
    .scrollIndicators(.never)
  }
}

#Preview {
  OnboardingDiseaseView(
    prompt: PromptMessage(title: "고민되시거나 개선하고 싶은 건강 고민을 선택해주세요"),
    name: "Jason",
    selections: .constant(.init()),
    isSelected: .constant(false)
  )
}
