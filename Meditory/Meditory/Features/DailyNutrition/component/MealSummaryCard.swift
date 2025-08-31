//
//  MealSummaryCell.swift
//  Meditory
//
//  Created by 이치훈 on 8/7/25.
//

import SwiftUI

struct MealSummaryCard: View {
  
  @EnvironmentObject var viewModel: NutritionMainViewModel
  
  let foodId: UUID
  
  private var food: FoodInfo? {
    viewModel.foodList.first { $0.id == foodId }
  }
  
  var body: some View {
    if let food = food {
      cardContent(for: food)
    } else {
      EmptyView()
    }
  }
  
  @ViewBuilder
  private func cardContent(for food: FoodInfo) -> some View {
    UnifiedSectionCard {
      VStack(alignment: .leading, spacing: .defaultSpacing) {
        Text(food.name)
          .font(.notoSans(weight: .semiBold, size: .defaultFontSize - 3))
        
        HStack {
          ForEach(food.macros.macroItems) { item in
            HStack(spacing: .smallSpacing - 3) {
              Circle()
                .fill(item.color)
                .frame(width: 12, height: 12)
              
              Text(item.label)
                .font(.notoSans(weight: .regular, size: .defaultFontSize - 8))
              
              Text("\(Int(item.gram))g")
                .font(.notoSans(weight: .semiBold, size: .defaultFontSize - 8))
                .frame(minWidth: 35, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
          }
        }
        
      }
      .foregroundStyle(Color.label)
    }
  }
}
