//
//  DailyMacroSummaryView.swift
//  Meditory
//
//  Created by 이치훈 on 8/6/25.
//

import SwiftUI

/// # DailyMealSummaryCard
///
/// 하루 식단의 영양소 정보를 요약하여 보여주는 카드형 뷰입니다.
/// 탄수화물, 단백질, 지방의 섭취량과 목표치 대비 달성률을 원형 차트와 퍼센트로 시각화합니다.
///
/// ## 주요 기능
/// - **원형 차트**: `MacroChartView`를 통해 3대 영양소 비율을 시각적으로 표시
/// - **퍼센트 표시**: 각 영양소의 목표치 대비 달성률을 퍼센트로 표시
/// - **정보 팝오버**: 권장 영양소 가이드를 확인할 수 있는 정보 아이콘 제공
/// - **일관된 디자인**: `UnifiedSectionCard`를 사용하여 앱 전체 디자인과 통일성 유지
///
/// ## Dependencies
/// - `NutritionMainViewModel`: 영양소 데이터와 계산 로직을 담당하는 뷰모델
/// - `MacroChartView`: 영양소 비율을 원형 차트로 표시하는 컴포넌트
/// - `UnifiedSectionCard`: 카드 스타일의 공통 컨테이너
/// - `RecommendedMacroGuidePopover`: 권장 영양소 가이드 팝오버
///
/// ## 사용 방법
/// ```swift
/// DailyMealSummaryCard()
///     .environmentObject(nutritionMainViewModel)
/// ```
///
/// ## 화면 구성
/// 1. **헤더**: "오늘 하루 식단" 제목 + 정보 아이콘
/// 2. **원형 차트**: 130x130 크기의 영양소 비율 차트
/// 3. **퍼센트 뷰**: 탄수화물, 단백질, 지방의 목표치 대비 달성률 표시
///
/// - Note: 이 뷰는 `@EnvironmentObject`로 `NutritionMainViewModel`을 주입받아야 정상 작동합니다.
struct DailyMealSummaryCard: View {
  
  @EnvironmentObject var viewModel: NutritionMainViewModel
  
  var body: some View {
    UnifiedSectionCard {
      VStack(spacing: .defaultSpacing) {
        // MARK: - 헤더 영역
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
        
        // MARK: - 영양소 원형 차트
        MacroChartView(macros: viewModel.macroRatio)
          .frame(width: 130, height: 130)
          .padding(.bottom, .smallSpacing)
        
        // MARK: - 영양소 퍼센트 표시
        macroPercentageView()
      }
    }
  }
  
  /// 탄수화물, 단백질, 지방의 목표치 대비 달성률을 퍼센트로 표시하는 뷰를 생성합니다.
  ///
  /// 각 영양소마다 컬러 인디케이터, 영양소명 첫 글자, 달성률 퍼센트를 가로로 배열하여 표시합니다.
  /// 무한대값(`isFinite = false`)인 경우 0%로 처리하여 UI 오류를 방지합니다.
  ///
  /// ## 구성 요소
  /// - **Circle**: 각 영양소를 구분하는 컬러 인디케이터 (14x14 크기)
  /// - **영양소명**: 영양소 이름의 첫 글자만 표시 (탄, 단, 지)
  /// - **퍼센트**: 목표치 대비 달성률을 정수로 표시
  ///
  /// - Returns: 영양소별 달성률을 가로로 배열한 뷰
  ///
  /// ## 레이아웃
  /// - 각 항목은 `maxWidth: .infinity`로 동일한 너비를 가짐
  /// - 퍼센트 텍스트는 `minWidth: 50`으로 최소 너비 보장
  /// - 폰트 크기는 기본값에서 5pt 작게 설정
  func macroPercentageView() -> some View {
    HStack {
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
            .frame(minWidth: 50, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(Color.label)
      }
    }
  }
}

#Preview {
  DailyMealSummaryCard()
}
