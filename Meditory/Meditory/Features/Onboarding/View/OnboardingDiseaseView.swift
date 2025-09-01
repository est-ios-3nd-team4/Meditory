//
//  OnboardingDiseaseView.swift
//  Meditory
//
//  Created by hyunsic on 8/8/25.
//

import SwiftUI

/// 기저질환 설문 뷰
struct OnboardingDiseaseView: View {
  
  // MARK: - 뷰 속성
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
  
  // MARK: - 뷰 바디
  var body: some View {
    /// 전체를 감싸는 스크롤 뷰
    ScrollView {
      /// 상단 타이틀 뷰
      TitleView(prompt: prompt,name:name)
      .padding(.horizontal, .defaultSpacing + 4)
      /// 콜렉션 아이템을 표현하는 V그리드 뷰
      LazyVGrid(columns: columns, spacing: 24) {
        ForEach(items, id: \.title) { item in
          /// 콜렉션 형태의 각 구성 아이템 뷰
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
