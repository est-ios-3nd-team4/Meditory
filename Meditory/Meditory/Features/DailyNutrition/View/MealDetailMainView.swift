//
//  DetailMainView.swift
//  Meditory
//
//  Created by 이치훈 on 8/26/25.
//

import SwiftUI

struct MealDetailMainView: View {
  @EnvironmentObject var viewModel: NutritionMainViewModel
  
  var body: some View {
    VStack(spacing: 20) {
      MacroChartView(macros: viewModel.selectedMeal?.macros)
        .frame(width: 200,
               height: 200)
      
      HStack {
        Spacer()
        
        Image(systemName: "info.circle")
          .longPressPopover {
            RecommendedMacroGuidePopover()
          }
      }
      .frame(width: 250)
      
      macroCompositionView(viewModel: viewModel)
      
      FoodGridView(foods: viewModel.selectedMeal?.foods)
      
      Spacer()
    }
  }
  
  func macroCompositionView(viewModel: NutritionMainViewModel) -> some View {
    let macro = viewModel.selectedMeal?.macros ?? MacroNutrients(carbohydrate: 0, protein: 0, fat: 0)
    
    return HStack(spacing: 50) {
      ForEach(macro.macroItems) { item in
        VStack {
          Text(item.label.prefix(1))
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
  MealDetailMainView()
}
