//
//  DailyMacroSummaryView.swift
//  Meditory
//
//  Created by 이치훈 on 8/6/25.
//

import SwiftUI

struct DailyMealSummaryCard: View {
  
  @EnvironmentObject var viewModel: NutritionMainViewModel

  var body: some View {
    ZStack {
      Rectangle()
        .fill(Color.customContainer)
        .frame(height: 250)
        .clipShape(RoundedRectangle(cornerRadius: .defaultRadius))
        .modifier(UnifiedShadow())
      
      VStack(spacing: .defaultSpacing) {
          HStack {
            Text("오늘 하루 식단")
              .font(.notoSans(weight: .semiBold, size: .defaultFontSize + 2))
              .foregroundStyle(Color.label)
            
            Spacer()
            
            Image(systemName: "info.circle")
              .longPressPopover {
                RecommendedMacroGuidePopover()
              }
          }
          
          MacroChartView(macros: viewModel.macroRatio)
            .frame(width: 130, height: 130)
            .padding(.bottom, .smallSpacing)
          
          macroPercentageView()
        }
      .padding(.horizontal, .defaultSpacing)
    }
  }
  
  /// 탄, 단, 지 오늘 하루 목표치 대비 퍼센트값을 나타냄
  func macroPercentageView() -> some View {
    HStack(spacing: 40) {
      ForEach(viewModel.macroPercent.macroItems) { item in
        let gram = (item.gram.isFinite ? item.gram : 0)
        HStack(spacing: .smallSpacing - 3) {
          Circle()
            .fill(item.color)
            .frame(width: 14, height: 14)
          
            Text(item.label.prefix(1))
              .font(.notoSans(weight: .regular, size: .defaultFontSize - 5))
            
            Text("\(Int(gram))%")
              .font(.notoSans(weight: .semiBold, size: .defaultFontSize - 5))
        }
        .foregroundStyle(Color.label)
      }
    }
  }
}

#Preview {
  DailyMealSummaryCard()
}
