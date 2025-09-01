//
//  MacroGuidePopover.swift
//  Meditory
//
//  Created by 이치훈 on 8/19/25.
//

import SwiftUI

/// # RecommendedMacroGuidePopover
///
/// 사용자에게 하루 권장 영양소 섭취량을 표시하는 팝오버 뷰입니다.
/// 말풍선 형태의 흰색 배경에 탄수화물, 단백질, 지방의 권장 섭취량을 그람 단위로 표시합니다.
///
/// ## 주요 특징
/// - **팝오버 디자인**: 비대칭 둥근 모서리로 말풍선 효과 연출
/// - **권장량 표시**: 각 영양소의 일일 권장 섭취량을 컬러 코딩과 함께 표시
/// - **컴팩트한 레이아웃**: 150x100 크기의 작은 공간에 정보를 효율적으로 배치
/// - **기기별 최적화**: iPad와 iPhone에서 다른 패딩 값 적용
/// - **접근성 고려**: 명확한 컬러 대비와 적절한 폰트 크기 사용
///
/// ## 디자인 사양
/// - **배경**: 흰색 사각형, 우측 하단만 직각 처리 (말풍선 효과)
/// - **크기**: 150x100 고정 크기
/// - **텍스트 색상**: 검은색 고정 (흰 배경과의 대비)
/// - **레이아웃**: 제목 + 영양소 목록의 수직 배열
///
/// ## 사용 방법
/// ```swift
/// Image(systemName: "info.circle")
///     .longPressPopover {
///         RecommendedMacroGuidePopover()
///     }
/// ```
///
/// ## 표시 정보
/// - **제목**: "오늘 섭취 권장량"
/// - **영양소**: 탄수화물, 단백질, 지방 각각의 권장 섭취량(g)
/// - **컬러 인디케이터**: 각 영양소를 구분하는 10x10 원형 표시
///
/// ## Dependencies
/// - `NutritionMainViewModel`: 권장 칼로리 정보를 제공하는 뷰모델
/// - `MacroNutrients`: 영양소 데이터 모델
/// - `UIDevice`: 기기 타입 감지를 위한 유틸리티
///
/// ## UI 계층 구조
/// ```
/// ZStack
/// ├── Rectangle (말풍선 배경)
/// └── VStack
///     ├── Text (제목)
///     └── macroPercentageView() (영양소 목록)
/// ```
///
/// - Note: 이 뷰는 `@EnvironmentObject`로 `NutritionMainViewModel`을 주입받아야 정상 작동합니다.
/// - Note: 팝오버의 특성상 작은 화면에서도 가독성을 유지하도록 폰트 크기가 작게 설정되어 있습니다.
struct RecommendedMacroGuidePopover: View {
  
  @EnvironmentObject var viewModel: NutritionMainViewModel
  
  /// 뷰모델에서 권장 칼로리 데이터를 가져오는 계산 속성
  ///
  /// `viewModel.recommendedCalories`에서 사용자의 일일 권장 영양소 섭취량을 반환합니다.
  /// 이 데이터는 사용자의 신체 정보와 활동 수준을 기반으로 계산된 개인 맞춤형 권장량입니다.
  ///
  /// - Returns: 탄수화물, 단백질, 지방의 권장 섭취량이 포함된 `MacroNutrients` 객체
  var meal: MacroNutrients {
    viewModel.recommendedCalories
  }
  
  var body: some View {
    ZStack {
      // MARK: - 말풍선 형태 배경
      Rectangle()
        .fill(.white)
        .clipShape(
          UnevenRoundedRectangle(topLeadingRadius: 20,
                                 bottomLeadingRadius: 20,
                                 bottomTrailingRadius: 0,
                                 topTrailingRadius: 20)
        )
        .frame(width: 150, height: 100)
      
      // MARK: - 콘텐츠 영역
      VStack(alignment: .leading, spacing: .smallSpacing - 3) {
        Text("오늘 섭취 권장량")
          .font(.notoSans(weight: .semiBold, size: .defaultFontSize - 3))
        
        macroPercentageView()
      }
      .foregroundStyle(.black)
      .padding(.vertical, UIDevice.isPad ? .smallSpacing : .zero)
      .padding(.horizontal, .defaultSpacing)
    }
  }
  
  /// 각 영양소의 권장 섭취량을 세로로 나열하여 표시하는 뷰를 생성합니다.
  ///
  /// 탄수화물, 단백질, 지방 순으로 각각의 컬러 인디케이터, 이름, 권장 섭취량을
  /// 한 줄씩 배열하여 표시합니다. 팝오버의 제한된 공간을 효율적으로 활용하기 위해
  /// 세로 배열을 사용합니다.
  ///
  /// - Returns: 영양소별 권장 섭취량이 세로로 배열된 뷰
  ///
  /// ## 각 행 구성 요소
  /// - **컬러 서클**: 영양소를 구분하는 10x10 크기의 원형 인디케이터
  /// - **영양소명**: 영양소의 전체 이름 (탄수화물, 단백질, 지방)
  /// - **권장량**: 해당 영양소의 일일 권장 섭취량 (그람 단위)
  ///
  /// ## 레이아웃 특징
  /// - **정렬**: 좌측 정렬로 일관성 있는 시각적 흐름 제공
  /// - **간격**: 행 간격 0으로 설정하여 공간 효율성 극대화
  /// - **폰트**: 작은 팝오버 공간에 맞춘 축소된 폰트 크기 사용
  /// - **가중치**: 권장량 수치는 세미볼드로 강조 표시
  ///
  /// ## 접근성 고려사항
  /// - 컬러 인디케이터와 텍스트 레이블 병행 사용으로 색맹 사용자 배려
  /// - 충분한 색상 대비로 가독성 확보 (검은 텍스트 + 흰 배경)
  /// - 의미있는 정보 순서 배치 (중요도에 따른 배열)
  func macroPercentageView() -> some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(meal.macroItems) { item in
        HStack {
          Circle()
            .fill(item.color)
            .frame(width: 10, height: 10)
          
          Text(item.label)
            .font(.notoSans(weight: .regular, size: .defaultFontSize - 5))
          
          Spacer()
          
          Text("\(Int(item.gram))g")
            .font(.notoSans(weight: .semiBold, size: .defaultFontSize - 7))
        }
      }
    }
  }
}

#Preview {
  RecommendedMacroGuidePopover()
}
