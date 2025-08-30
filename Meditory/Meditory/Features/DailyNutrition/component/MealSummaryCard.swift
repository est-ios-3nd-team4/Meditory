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
    ZStack {
      Rectangle()
        .fill(.customContainer)
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: .defaultRadius))
        .modifier(UnifiedShadow())
      
      HStack {
        VStack(alignment: .leading, spacing: .defaultSpacing) {
          Text(food.name)
            .font(.notoSans(weight: .semiBold, size: .defaultFontSize - 3))
          
          HStack(spacing: 40) {
            ForEach(food.macros.macroItems) { item in
              HStack(spacing: .smallSpacing - 3) {
                Circle()
                  .fill(item.color)
                  .frame(width: 12, height: 12)
                
                
                Text(item.label)
                  .font(.notoSans(weight: .regular, size: .defaultFontSize - 7))
                
                Text("\(Int(item.gram))g")
                  .font(.notoSans(weight: .semiBold, size: .defaultFontSize - 6))
              }
              .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
        }
        
        Spacer()
      }
      .foregroundStyle(Color.label)
      .padding(.leading, .defaultSpacing)
    }
  }
}
