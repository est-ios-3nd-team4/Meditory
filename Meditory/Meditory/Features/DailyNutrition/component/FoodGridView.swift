//
//  FoodGridView.swift
//  Meditory
//
//  Created by 이치훈 on 8/19/25.
//

import SwiftUI

struct FoodGridView: View {
  
  let foods: [FoodInfo]
  
  let columns = [
    GridItem(.adaptive(minimum: 100, maximum: 300), spacing: 16),
  ]
  
  init(foods: [FoodInfo]?) {
    self.foods = foods ?? []
  }
  
  var body: some View {
    FlowLayout(spacing: 8, lineSpacing: 8) {
      ForEach(foods, id: \.id) { food in
        capsuleTag(food)
      }
    }
  }
  
  func capsuleTag(_ food: FoodInfo) -> some View {
    ZStack {
      Capsule()
        .fill(.white)
        .modifier(UnifiedShadow())
        .frame(height: 40)
      
      HStack {
        Text(food.name)
          .font(.notoSans(weight: .medium, size: .defaultFontSize - 2))
        
        Text("\(Int(food.weight))g")
          .font(.notoSans(weight: .regular, size: .defaultFontSize - 3))
      }
      .padding(.horizontal, 8)
      .lineLimit(1)
      .fixedSize()
    }
  }
}
