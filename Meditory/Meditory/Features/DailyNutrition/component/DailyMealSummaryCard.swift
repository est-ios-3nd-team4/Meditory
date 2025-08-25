//
//  DailyMacroSummaryView.swift
//  Meditory
//
//  Created by 이치훈 on 8/6/25.
//

import SwiftUI

struct DailyMealSummaryCard: View {
  
  let meal: MacroNutrients
  
  var body: some View {
    ZStack {
      Rectangle()
        .fill(Color.customContainer)
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .modifier(UnifiedShadow())
      
      HStack {
        VStack {
          Text("오늘 하루 식단")
            .font(.notoSans(weight: .bold, size: 15))
            .foregroundStyle(.black)
          
          macroPercentageView()
        }
        
        Spacer()
        
        MacroChartView(macros: meal)
          .frame(width: 80, height: 80)
        
        HStack {
          VStack {
            Image(systemName: "info.circle")
              .longPressPopover {
                RecommendedMacroGuidePopover()
              }
            
            Spacer()
          }
        }
      }
      .padding(16)
      
    }
  }
  
  /// 탄, 단, 지 오늘 하루 목표치 대비 퍼센트값을 나타냄
  func macroPercentageView() -> some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(meal.macroItems) { item in
          HStack {
            Circle()
              .fill(item.color)
              .frame(width: 15, height: 15)
            
            HStack {
              Text(item.label)
                .font(.notoSans(weight: .regular, size: 15))
                .foregroundStyle(.black)
              
              Text("\(Int(item.gram))%")
                .font(.notoSans(weight: .semiBold, size: 17))
            }
          }
        }
    }
  }
}

#Preview {
  DailyMealSummaryCard(meal: MacroNutrients(carbohydrate: 180,
                                            protein: 40,
                                            fat: 30))
}
