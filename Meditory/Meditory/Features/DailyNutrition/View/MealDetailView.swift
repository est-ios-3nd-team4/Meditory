//
//  MealDetailView.swift
//  Meditory
//
//  Created by 이치훈 on 8/8/25.
//

import SwiftUI

struct MealDetailView: View {
  
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var viewModel: NutritionMainViewModel
  
  var body: some View {
    VStack(spacing: 50) {
      FoodSearchTextFieldView()
        .padding(.horizontal, 16)
      
      MacroChartView(macros: viewModel.selectedMeal?.macros)
      .frame(width: 200, height: 200)
      
      HStack {
        Spacer()
        
        Image(systemName: "info.circle")
          .longPressPopover {
            MacroGuidePopover()
          }
      }
      .frame(width: 250)
      
      macroCompositionView()
      
      FoodGridView(foods: viewModel.selectedMeal?.foods)
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
    let macro = viewModel.selectedMeal?.macros ?? MacroNutrients(carbohydrate: 0, protein: 0, fat: 0)
    
    return HStack(spacing: 50) {
      ForEach(macro.macroItems) { item in
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
  MealDetailView()
}
