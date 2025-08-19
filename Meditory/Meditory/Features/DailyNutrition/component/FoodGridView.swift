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
    GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 16)
  ]
  
  init(foods: [FoodInfo]?) {
    self.foods = foods ?? []
  }
  
  var body: some View {
    LazyVGrid(columns: columns, spacing: 16) {
      ForEach(foods) { food in
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
          .font(.notoSans(weight: .medium, size: 16))
        
        Text("\(Int(food.weight))g")
          .font(.notoSans(weight: .regular, size: 15))
      }
      .padding(.horizontal, 8)
      .lineLimit(1)
      .fixedSize()
    }
  }
}

#Preview {
  FoodGridView(foods: [FoodInfo(name: "짜장면",
                                weight: 200,
                                macros: .init(carbohydrate: 40,
                                                                        protein: 20,
                                                                        fat: 30)),
                       FoodInfo(name: "스파게티맛 짜장면",
                                                     weight: 200,
                                                     macros: .init(carbohydrate: 40,
                                                                                             protein: 20,
                                                                                             fat: 30)),
                       FoodInfo(name: "짜장면",
                                                     weight: 200,
                                                     macros: .init(carbohydrate: 40,
                                                                                             protein: 20,
                                                                                             fat: 30)),
                       FoodInfo(name: "짜장면",
                                                     weight: 200,
                                                     macros: .init(carbohydrate: 40,
                                                                                             protein: 20,
                                                                                             fat: 30)),
                       FoodInfo(name: "짜장면",
                                                     weight: 200,
                                                     macros: .init(carbohydrate: 40,
                                                                                             protein: 20,
                                                                                             fat: 30)),
                       FoodInfo(name: "짜장면",
                                                     weight: 200,
                                                     macros: .init(carbohydrate: 40,
                                                                                             protein: 20,
                                                                                             fat: 30)),
                       FoodInfo(name: "짜장면",
                                                     weight: 200,
                                                     macros: .init(carbohydrate: 40,
                                                                                             protein: 20,
                                                                                             fat: 30)),
                       FoodInfo(name: "짜장면",
                                                     weight: 200,
                                                     macros: .init(carbohydrate: 40,
                                                                                             protein: 20,
                                                                                             fat: 30)),
                       FoodInfo(name: "짜장면",
                                                     weight: 200,
                                                     macros: .init(carbohydrate: 40,
                                                                                             protein: 20,
                                                                                             fat: 30)),
                       FoodInfo(name: "짜장면",
                                                     weight: 200,
                                                     macros: .init(carbohydrate: 40,
                                                                                             protein: 20,
                                                                                             fat: 30)),
  ])
}
