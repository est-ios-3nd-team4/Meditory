//
//  DailyMacroSummaryView.swift
//  Meditory
//
//  Created by 이치훈 on 8/6/25.
//

import SwiftUI

struct DailyMealSummaryView: View {
  
  let macros = [
    MacroModel(macroType: .carbohydrate,
               gram: 180),
    MacroModel(macroType: .protein,
               gram: 30),
    MacroModel(macroType: .fat,
               gram: 10)
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
            
            HStack {
              Text(macro.label)
                .font(.custom("NotoSansKR-Bold", size: 17))
                .foregroundStyle(.black)
              
              Text("\(Int(macro.gram))%")
                .font(.custom("NotoSansCJKkr-Medium", size: 18))
            }
          }
        }
    }
  }
}

#Preview {
    DailyMealSummaryView()
}
