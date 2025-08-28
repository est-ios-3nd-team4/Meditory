//
//  DailyMacroSummaryView.swift
//  Meditory
//
//  Created by 이치훈 on 8/6/25.
//

import SwiftUI

struct DailyMealSummaryCard: View {
  
  @EnvironmentObject var viewModel: NutritionMainViewModel
  var meal: MacroNutrients {
    viewModel.todayTotalMacros
  }
  
  var body: some View {
    ZStack {
      Rectangle()
        .fill(Color.customContainer)
        .frame(height: 250)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .modifier(UnifiedShadow())
      
        VStack(spacing: 16) {
          HStack {
            Text("오늘 하루 식단")
              .font(.notoSans(weight: .bold, size: 15))
              .foregroundStyle(.black)
            
            Spacer()
            
            Image(systemName: "info.circle")
              .longPressPopover {
                RecommendedMacroGuidePopover()
              }
          }
          
          MacroChartView(macros: viewModel.macroPercent)
            .frame(width: 130, height: 130)
          
          macroPercentageView()
        }
        .padding(.horizontal, 16)
    }
  }
  
  /// 탄, 단, 지 오늘 하루 목표치 대비 퍼센트값을 나타냄
  func macroPercentageView() -> some View {
    HStack(spacing: 40) {
      ForEach(viewModel.macroPercent.macroItems) { item in
        HStack(spacing: 5) {
          Circle()
            .fill(item.color)
            .frame(width: 14, height: 14)
          
            Text(item.label.prefix(1))
              .font(.notoSans(weight: .regular, size: 13))
              .foregroundStyle(.black)
            
            Text("\(Int(item.gram * 100))%")
              .font(.notoSans(weight: .semiBold, size: 13))
        }
      }
    }
  }
}

#Preview {
  DailyMealSummaryCard()
}
