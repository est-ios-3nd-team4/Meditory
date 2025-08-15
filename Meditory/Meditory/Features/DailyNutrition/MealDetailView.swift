//
//  MealDetailView.swift
//  Meditory
//
//  Created by 이치훈 on 8/8/25.
//

import SwiftUI

struct MealDetailView: View {
  @Environment(\.dismiss) var dismiss
  
  let meal: MealInfo
//    MacroItem(macroType: .carbohydrate,
//               gram: 180),
//    MacroItem(macroType: .protein,
//               gram: 30),
//    MacroItem(macroType: .fat,
//               gram: 10)
  
  
  var body: some View {
    VStack(spacing: 50) {
      FoodSearchTextFieldView()
        .padding(.horizontal, 16)
      
      MacroChartView(macros: meal.macros)
      .frame(width: 200, height: 200)
      
      macroCompositionView()
      
      Spacer()
    }
    .navigationBarBackButtonHidden(true)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.left")
            .foregroundStyle(.black)
        }
      }
      
      ToolbarItem(placement: .principal) {
        Text("아침 식단 요약")
          .font(.notoSans(weight: .bold, size: 20))
          .foregroundStyle(.black)
      }
    }
  }
  
  // MARK: Disposable Components
  
  func macroCompositionView() -> some View {
    HStack(spacing: 50) {
      ForEach(meal.macroItems) { item in
        VStack {
          Text(item.label)
            .font(.notoSans(weight: .bold, size: 18))
          
          Circle()
            .fill(item.color)
            .frame(width: 20, height: 20)
          
          Text("\(Int(item.gram))%")
            .font(.notoSans(weight: .medium, size: 17))
        }
      }
    }
  }
  
}

#Preview {
  MealDetailView(meal: MealInfo(name: "아침",
                                foods: [FoodInfo(name: "짜장면",
                                                 weight: 120,
                                                 macros: .init(carbohydrate: 30,
                                                               protein: 10,
                                                               fat: 5)),
                                        FoodInfo(name: "스파게티",
                                                 weight: 150,
                                                 macros: .init(carbohydrate: 40,
                                                               protein: 50,
                                                               fat: 10))
                                ]))
}
