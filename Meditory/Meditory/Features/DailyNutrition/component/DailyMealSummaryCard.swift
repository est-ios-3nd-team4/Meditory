//
//  DailyMacroSummaryView.swift
//  Meditory
//
//  Created by 이치훈 on 8/6/25.
//

import SwiftUI

struct DailyMealSummaryView: View {
  
  let macros = [
    MacroModel(id: 0,
               color: .customCarbohydrate,
               label: "탄",
               gram: 150),
    MacroModel(id: 1,
               color: .customProtein,
               label: "단",
               gram: 120),
    MacroModel(id: 2,
               color: .customFat,
               label: "지",
               gram: 80)
  ]
  
  var body: some View {
    ZStack {
      Rectangle()
        .fill(Color.customContainer)
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .modifier(UnifiedShadow())
      
      HStack {
        Text("오늘 하루 식단")
          .font(.custom("NotoSansKR-Bold", size: 18))
          .foregroundStyle(.black)
          .padding(.leading, 16)
        
        Spacer()
        
        macroPercentageView()
        
        Spacer()
        
        MacroNutrientChartView(carbohydrateProgressTarget: Double(macros[0].gram) / 100,
                               proteinProgressTarget: Double(macros[1].gram) / 100,
                               fatProgressTarget: Double(macros[2].gram) / 100)
        .frame(width: 80, height: 80)
        .padding(.trailing, 16)
      }
    }
  }
  
  /// 탄, 단, 지 오늘 하루 목표치 대비 퍼센트값을 나타냄
  func macroPercentageView() -> some View {
    VStack(alignment: .leading) {
      ForEach(macros) { macro in
        HStack {
          Circle()
            .fill(macro.color)
            .frame(width: 15, height: 15)
          
          Text(macro.label + " \(macro.gram)%")
            .font(.custom("NotoSansCJKkr-Medium", size: 18))
            .foregroundStyle(.black)
        }
      }
    }
  }
}

#Preview {
    DailyMealSummaryView()
}
