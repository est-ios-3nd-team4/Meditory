//
//  OnboardingListSelectionView.swift
//  Meditory
//
//  Created by hyunsic on 8/5/25.
//

import SwiftUI

struct OnboardingListSelectionView: View {
  let prompt:String
  var info:String?
  var questions:[String]
  @Binding var selections:Set<String>
  var onAction:((String)->Void)?
  var body: some View {
    ScrollView {
      HStack{
        VStack(alignment: .leading,) {
          Text(prompt)
            .font(.notoSans(weight: .bold, size: 24))
            .padding(.vertical, 10)
          if let info = info {
            Text(info)
              .font(.notoSans(weight: .medium, size: 12))
              .foregroundStyle(.gray)
          }
        }
        Spacer()
      }
      .padding(.horizontal)
      ForEach(questions,id:\.self) { item in
        RowItemView(isSelected: selections.contains(item), context: item)
          .onTapGesture {
            onAction?(item)
          }
      }
    }
    .scrollIndicators(.never)
  }
}

#Preview {
  OnboardingListSelectionView(prompt: "앓고 계신 질환을 선택해주세요", info: "알레르기", questions: ["a","b","c"], selections: .constant(["Set<String>"]))
}
