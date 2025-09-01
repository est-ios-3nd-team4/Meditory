//
//  OnboardingAllergyView.swift
//  Meditory
//
//  Created by hyunsic on 8/5/25.
//

import SwiftUI

/// 알러지 설문 뷰
struct OnboardingAllergyView: View {
  
  // MARK: - 뷰 속성
  let prompt:Prompt
  let name:String
  var questions = QuestionModel.allergyModel
  @Binding var selections: Set<QuestionModel>
  @Binding var isSelected: Bool
  var onAction: ((QuestionModel) -> Void)?
  
  // MARK: - 뷰 바디
  var body: some View {
    /// 전체를 감싸는 스크롤 뷰
    ScrollView {
      /// 상단 타이틀 뷰
      TitleView(prompt: prompt,name: name)
        .padding(.horizontal,.defaultSpacing + 4)
      /// 알러지 리스트 아이템 뷰
      ForEach(questions, id: \.self) { item in
        RowItemCell(model: item, isSelected: selections.contains(item))
          .onTapGesture {
            onAction?(item)
          }
          .padding(.horizontal, .defaultSpacing + 4)
      }
    }
    .scrollIndicators(.never)
  }
}
