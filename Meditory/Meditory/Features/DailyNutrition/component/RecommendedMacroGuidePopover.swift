//
//  MacroGuidePopover.swift
//  Meditory
//
//  Created by 이치훈 on 8/19/25.
//

import SwiftUI

struct RecommendedMacroGuidePopover: View {
  @EnvironmentObject var viewModel: NutritionMainViewModel
  var meal: MacroNutrients {
    viewModel.recommendedCalories
  }
  
  var body: some View {
    ZStack {
      Rectangle()
        .fill(.white)
        .clipShape(
          UnevenRoundedRectangle(topLeadingRadius: 20,
                                 bottomLeadingRadius: 20,
                                 bottomTrailingRadius: 0,
                                 topTrailingRadius: 20)
        )
        .frame(width: 150, height: 100)
      
      VStack(alignment: .leading, spacing: 5) {
        Text("오늘 섭취 권장량")
          .font(.notoSans(weight: .semiBold, size: 15))
        
        macroPercentageView()
      }
      .foregroundStyle(.black)
      .padding(.horizontal, 16)
    }
  }
  
  func macroPercentageView() -> some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(meal.macroItems) { item in
        HStack {
          Circle()
            .fill(item.color)
            .frame(width: 10, height: 10)
          
            Text(item.label)
              .font(.notoSans(weight: .regular, size: 13))
            
            Spacer()
            
            Text("\(Int(item.gram))g")
              .font(.notoSans(weight: .semiBold, size: 11))
        }
      }
    }
  }
  
}

#Preview {
  RecommendedMacroGuidePopover()
}
