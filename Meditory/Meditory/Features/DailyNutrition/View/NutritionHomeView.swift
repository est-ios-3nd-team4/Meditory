//
//  DailyNutritionView.swift
//  Meditory
//
//  Created by 이치훈 on 8/4/25.
//

import SwiftUI
import SwiftData

/// `NutritionHomeView`
/// - 영양 관리 앱의 메인 홈 화면을 담당하는 SwiftUI View입니다.
/// - 캘린더 기반 날짜 선택과 함께 선택된 날짜의 식단 정보를 표시합니다.
/// - 일일 식단 요약, 개별 음식 카드 목록, HealthKit 연동 기능을 제공합니다.
///
/// ## 주요 기능
/// - **캘린더 뷰**: `CalendarBackgroundView`를 통한 날짜 선택
/// - **일일 요약**: `DailyMealSummaryCard`로 하루 영양 정보 요약 표시
/// - **식단 목록**: 선택된 날짜의 음식들을 `MealSummaryCard`로 표시
/// - **HealthKit 연동**: 앱 시작시 자동으로 HealthKit 권한 요청 및 데이터 로드
/// - **실시간 업데이트**: 날짜 변경시 해당 날짜 데이터 자동 로드
struct NutritionHomeView: View {
  
  /// 영양 데이터 및 비즈니스 로직을 담당하는 메인 ViewModel
  /// - 식단 데이터, 사용자 정보, HealthKit 데이터 관리
  @EnvironmentObject var viewModel: NutritionMainViewModel
  
  /// SwiftData ModelContext - 데이터베이스 작업용
  @Environment(\.modelContext) private var context
  
  /// HealthKit 권한 요청 중복 방지를 위한 플래그
  @State private var hasRequestedHealthKit = false
  
  /// HealthKit 권한 관련 알림 표시 상태
  @State private var showHealthKitAlert = false
  
  var body: some View {
    
    /// 캘린더 배경과 함께 날짜별 식단 정보를 표시하는 메인 컨테이너
    /// - Parameter selectedDate: viewModel의 선택된 날짜와 바인딩
    /// - Returns: 선택된 날짜에 따른 동적 컨텐츠 표시
    
    CalendarBackgroundView(selectedDate: $viewModel.selectedDate) { _ in
      ScrollView {
        VStack {
          /// 하루 전체 영양 정보 요약 카드
          /// - 총 칼로리, 매크로 영양소 비율, 목표 대비 달성률 표시
          DailyMealSummaryCard()
            .padding(.bottom, .defaultSpacing)
          
          /// 개별 음식 항목들을 카드 형태로 표시
          /// - 각 음식을 탭하면 상세 편집 화면으로 이동
          /// - NavigationLink를 통한 화면 전환
          ForEach(viewModel.foodList, id: \.id) { food in
            if let parentMeal = viewModel.findMeal(for: food.id) {
              NavigationLink(destination: FoodInputView(food: food,
                                                        meal: parentMeal)) {
                MealSummaryCard(foodId: food.id)
              }
                                                        .buttonStyle(.plain)
            }
          }
          
          Spacer()
        }
        .padding(.defaultSpacing)
      }
    }
    /// 화면 첫 로드시 필수 데이터 초기화
    /// - 사용자 기본 정보, HealthKit 권한, 당일 식단 데이터 순차 로드
    .onAppear {
      Task {
        await viewModel.loadUserData()
        await viewModel.requestHealthKitPermission()
        await viewModel.loadMealForSelectedDate()
      }
    }
    /// 날짜 변경 감지하여 해당 날짜의 식단 데이터 로드
    /// - Parameter newDate: 새롭게 선택된 날짜
    /// - 날짜가 바뀔 때마다 해당 날짜의 식단 정보를 데이터베이스에서 가져옴
    .onChange(of: viewModel.selectedDate) { _, newDate in
      Task {
        await viewModel.loadMealsForDate(newDate)
      }
    }
  }
}
