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
        Text("오늘 하루 식단")
          .font(.notoSans(weight: .bold, size: 18))
          .foregroundStyle(.black)
          .padding(.leading, 16)
        
        Spacer()
        
        macroPercentageView()
        
        Spacer()
        
        MacroChartView(macros: meal)
        .frame(width: 80, height: 80)
        .padding(.trailing, 16)
      }
    }
  }
  
  /// 탄, 단, 지 오늘 하루 목표치 대비 퍼센트값을 나타냄
  func macroPercentageView() -> some View {
    VStack(alignment: .leading) {
      ForEach(meal.macroItems) { item in
          HStack {
            Circle()
              .fill(item.color)
              .frame(width: 15, height: 15)
            
            HStack {
              Text(item.label)
                .font(.notoSans(weight: .bold, size: 17))
                .foregroundStyle(.black)
              
              Text("\(Int(item.gram))%")
                .font(.notoSans(weight: .medium, size: 18))
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
