//
//  NutrientDetailSectionView.swift
//  Meditory
//
//  Created by Jaehun Kim on 8/4/25.
//

import SwiftUI

struct NutrientDetailSectionView: View {
  let name: String
  let tags: [String]
  let descriptionTitle: String
  let summary: String
  let detail: String
  @State private var isscrap = false
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(name)
          .font(.notoSans(weight: .bold, size: 30))
          .fontWeight(.bold)
        
        Spacer()
        
        Button {
          isscrap.toggle()
        } label: {
          Image(systemName: isscrap ? "star.fill" : "star")
        }
      }
      .padding(.bottom, 16)
      
      ForEach(tags, id: \.self) { tag in
        Text("# \(tag)")
          .font(.notoSans(weight: .bold, size: 15))
          .fontWeight(.bold)
      }
      
      Text("🧪 \(descriptionTitle)")
        .font(.notoSans(weight: .bold, size: 18))
        .fontWeight(.bold)
        .padding(.vertical, 16)
      
      Text(summary)
        .font(.notoSans(weight: .bold, size: 15))
        .fontWeight(.bold)
        .padding(.bottom, 8)
      
      Text(detail)
        .font(.notoSans(weight: .medium, size: 15))
    }
    .padding(.vertical)
  }
}


