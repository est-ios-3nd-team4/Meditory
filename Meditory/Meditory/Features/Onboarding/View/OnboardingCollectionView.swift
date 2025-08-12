//
//  OnboardingCollectionView.swift
//  Meditory
//
//  Created by hyunsic on 8/8/25.
//

import SwiftUI

struct OnboardingCollectionView: View {
  let items = QuestionModel.concernModel
  let columns = [
    GridItem(.flexible(), spacing: 8),
    GridItem(.flexible(), spacing: 8),
    GridItem(.flexible(), spacing: 8),
  ]
  let prompt: String
  var info: String?
  @Binding var selections: Set<QuestionModel>
  @Binding var isSelected: Bool
  var onAction: ((QuestionModel) -> Void)?
  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(prompt)
          .font(.notoSans(weight: .bold, size: 24))
          .padding(.vertical, 10)
        if let info = info {
          Text(info)
            .font(.notoSans(weight: .bold, size: 16))
            .foregroundStyle(.textGray)
        }
      }
      Spacer()
    }
    .padding(.vertical,.defaultSpacing)
    .padding(.horizontal)
    ScrollView {
      LazyVGrid(columns: columns, spacing: 6) {
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
  OnboardingCollectionView(
    prompt: "고민되시거나 개선하고 싶은 건강 고민을 선택해주세요",
    info: "최대 8개 선택",
    selections: .constant(.init()),
    isSelected: .constant(false)
  )
}
