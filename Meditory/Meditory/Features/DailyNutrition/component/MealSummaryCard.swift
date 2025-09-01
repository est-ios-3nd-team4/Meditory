//
//  MealSummaryCell.swift
//  Meditory
//
//  Created by 이치훈 on 8/7/25.
//

import SwiftUI

/// # MealSummaryCard
///
/// 개별 음식의 영양소 정보를 요약하여 보여주는 카드형 뷰입니다.
/// 음식명과 함께 탄수화물, 단백질, 지방의 섭취량을 컬러 인디케이터와 함께 가로로 배열하여 표시합니다.
///
/// ## 주요 기능
/// - **음식 정보 표시**: 선택된 음식의 이름과 영양소 정보 표시
/// - **컬러 인디케이터**: 각 영양소를 구분하는 색상 코드 제공
/// - **그람 단위 표시**: 각 영양소의 실제 섭취량을 g 단위로 표시
/// - **안전한 데이터 처리**: 존재하지 않는 음식 ID에 대해 EmptyView 반환
/// - **일관된 디자인**: `UnifiedSectionCard`를 사용한 통일된 카드 스타일
///
/// ## 데이터 흐름
/// 1. `foodId`로 `viewModel.foodList`에서 해당 음식 검색
/// 2. 음식이 존재하면 `cardContent(for:)` 함수로 카드 렌더링
/// 3. 음식이 없으면 `EmptyView()` 반환하여 빈 공간 처리
///
/// ## UI 구성
/// - **상단**: 음식명 (세미볼드, 기본 폰트 크기 -3pt)
/// - **하단**: 영양소 정보 가로 배열
///   - 컬러 서클 (12x12)
///   - 영양소명 (일반체, 기본 폰트 크기 -8pt)
///   - 그람 수 (세미볼드, 기본 폰트 크기 -8pt, 최소 너비 35pt)
///
/// ## 사용 방법
/// ```swift
/// MealSummaryCard(foodId: selectedFood.id)
///     .environmentObject(nutritionMainViewModel)
/// ```
///
/// ## Dependencies
/// - `NutritionMainViewModel`: 음식 목록과 영양소 데이터를 제공하는 뷰모델
/// - `FoodInfo`: 음식 정보를 담고 있는 데이터 모델
/// - `UnifiedSectionCard`: 일관된 카드 스타일을 제공하는 공통 컴포넌트
///
/// - Note: 이 뷰는 `@EnvironmentObject`로 `NutritionMainViewModel`을 주입받아야 정상 작동합니다.
/// - Warning: 유효하지 않은 `foodId`가 전달되면 뷰가 렌더링되지 않습니다.
struct MealSummaryCard: View {
  
  @EnvironmentObject var viewModel: NutritionMainViewModel
  
  /// 표시할 음식의 고유 식별자
  /// 이 ID를 기반으로 `viewModel.foodList`에서 해당 음식 정보를 검색합니다.
  let foodId: UUID
  
  /// `foodId`에 해당하는 음식 정보를 `viewModel.foodList`에서 검색하는 계산 속성
  ///
  /// `viewModel.foodList` 배열에서 `id`가 `foodId`와 일치하는 첫 번째 `FoodInfo` 객체를 반환합니다.
  /// 해당하는 음식이 없으면 `nil`을 반환하여 안전하게 처리됩니다.
  ///
  /// - Returns: 일치하는 `FoodInfo` 객체 또는 `nil`
  /// - Note: 이 속성은 `viewModel.foodList`가 변경될 때마다 자동으로 재계산됩니다.
  private var food: FoodInfo? {
    viewModel.foodList.first { $0.id == foodId }
  }
  
  var body: some View {
    if let food = food {
      cardContent(for: food)
    } else {
      // 음식 정보가 없는 경우 빈 뷰 반환
      EmptyView()
    }
  }
  
  /// 주어진 음식 정보를 기반으로 카드 콘텐츠를 생성하는 함수입니다.
  ///
  /// 음식명과 영양소 정보(탄수화물, 단백질, 지방)를 카드 형태로 배열하여 표시합니다.
  /// 각 영양소는 컬러 인디케이터, 이름, 그람 수 순으로 가로 배열됩니다.
  ///
  /// - Parameter food: 표시할 음식의 정보가 담긴 `FoodInfo` 객체
  /// - Returns: 음식 정보가 포함된 카드 뷰
  ///
  /// ## 레이아웃 구성
  /// ### 상단 영역
  /// - **음식명**: 세미볼드 폰트, 기본 크기에서 3pt 작게
  ///
  /// ### 하단 영역 (영양소 정보)
  /// - **컬러 서클**: 각 영양소를 구분하는 12x12 크기의 원형 인디케이터
  /// - **영양소명**: 일반체 폰트, 기본 크기에서 8pt 작게
  /// - **그람 수**: 세미볼드 폰트, 기본 크기에서 8pt 작게, 최소 너비 35pt 보장
  /// - **간격**: 각 영양소 간 `smallSpacing - 3` 만큼의 간격 유지
  ///
  /// ## 접근성 고려사항
  /// - 모든 텍스트에 `Color.label` 적용으로 다크모드 호환성 보장
  /// - 최소 너비 설정으로 텍스트 겹침 방지
  /// - 의미있는 컬러 코딩으로 시각적 구분 용이
  @ViewBuilder
  private func cardContent(for food: FoodInfo) -> some View {
    UnifiedSectionCard {
      VStack(alignment: .leading, spacing: .defaultSpacing) {
        // MARK: - 음식명 표시
        Text(food.name)
          .font(.notoSans(weight: .semiBold, size: .defaultFontSize - 3))
        
        // MARK: - 영양소 정보 가로 배열
        HStack {
          ForEach(food.macros.macroItems) { item in
            HStack(spacing: .smallSpacing - 3) {
              Circle()
                .fill(item.color)
                .frame(width: 12, height: 12)
              
              Text(item.label)
                .font(.notoSans(weight: .regular, size: .defaultFontSize - 8))
              
              Text("\(Int(item.gram))g")
                .font(.notoSans(weight: .semiBold, size: .defaultFontSize - 8))
                .frame(minWidth: 35, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
          }
        }
        
      }
      .foregroundStyle(Color.label)
    }
  }
}
