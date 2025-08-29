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
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .modifier(UnifiedShadow())
      
      HStack {
        VStack(alignment: .leading, spacing: 16) {
          Text(food.name)
            .font(.notoSans(weight: .bold, size: 15))
          
          HStack(spacing: 40) {
            ForEach(food.macros.macroItems) { item in
              HStack(spacing: 5) {
                Circle()
                  .fill(item.color)
                  .frame(width: 12, height: 12)
                
                
                Text(item.label)
                  .font(.notoSans(weight: .regular, size: 12))
                
                Text("\(Int(item.gram))g")
                  .font(.notoSans(weight: .semiBold, size: 12))
              }
              .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
        }
        
        Spacer()
      }
      .foregroundStyle(Color.label)
      .padding(.leading, 16)
    }
  }
}
