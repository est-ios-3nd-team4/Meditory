//
//  OnboardingCollectionItemsView.swift
//  Meditory
//
//  Created by hyunsic on 8/8/25.
//

import SwiftUI

struct OnboardingCollectionItemsView: View {
  let items = Array(1...12)
  
  let columns = [
    GridItem(.flexible(),spacing: 8),
    GridItem(.flexible(),spacing: 8),
    GridItem(.flexible(),spacing: 8)
  ]
  let prompt: String
  var info:String?
  var body: some View {
    HStack{
      VStack(alignment: .leading) {
        Text(prompt)
          .font(.notoSans(weight: .bold, size: 24))
          .padding(.bottom,10)
        if let info = info {
          Text(info)
            .font(.notoSans(weight: .medium, size: 12))
            .foregroundStyle(.textGray)
        }
      }
      Spacer()
    }
    .padding(.horizontal)
    ScrollView {
      LazyVGrid(columns: columns, spacing: 16) {
        ForEach(items, id: \.self) { item in
          ItemCell()
        }
      }
      .padding(.top,10)
    }
    .scrollIndicators(.never)
  }
}

#Preview {
    OnboardingCollectionItemsView(prompt: "고민되시거나 개선하고 싶은 건강 고민을 선택해주세요", info: "최대 8개 선택")
}
