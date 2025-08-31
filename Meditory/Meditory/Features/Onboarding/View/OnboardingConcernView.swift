//
//  OnboardingDiseaseView.swift
//  Meditory
//
//  Created by hyunsic on 8/8/25.
//

import SwiftUI

///기저질환 설문 뷰
struct OnboardingConcernView: View {
  
  //MARK: - 뷰 속성
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
  
  // MARK: - 뷰 바디
  var body: some View {
    /// 전체를 감싸는 스크롤 뷰
    ScrollView {
      /// 상단 타이틀 뷰
      TitleView(prompt: prompt,extra: itemCount)
        .padding(.horizontal, .defaultSpacing + 4)
      /// 캡슐 형태의 텍스트를 표현하는 플로우
      OnboardingFlowLayoutLineLimit(items: items, content: { item in
        /// 캡슐형태로 텍스트를 감싼 아이템 뷰
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

