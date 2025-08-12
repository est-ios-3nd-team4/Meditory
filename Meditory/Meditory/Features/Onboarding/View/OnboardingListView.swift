//
//  OnboardingListSelectionView.swift
//  Meditory
//
//  Created by hyunsic on 8/5/25.
//

import SwiftUI

struct OnboardingListView: View {
  let prompt:String
  var info:String?
  var questions = QuestionModel.allergyModel
  @Binding var selections:Set<QuestionModel>
  @Binding var isSelected:Bool
  var onAction:((QuestionModel)->Void)?
  var body: some View {
    ScrollView {
      HStack{
        VStack(alignment: .leading,) {
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
      ForEach(questions,id:\.self) { item in
        RowItemCell(model: item,isSelected: selections.contains(item))
          .onTapGesture {
            onAction?(item)
          }
      }
      .padding(.horizontal)
    }
    .scrollIndicators(.never)
  }
}
