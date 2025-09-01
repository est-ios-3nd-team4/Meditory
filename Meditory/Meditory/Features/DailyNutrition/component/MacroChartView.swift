//
//  MacroNutrientChartView.swift
//  Meditory
//
//  Created by 이치훈 on 8/4/25.
//

/// MacroNutrientChartView
/// 사용자의 탄, 단, 지 데이터를 원형 프로그래스바로 표현하기 위해 구현했습니다.
/// 아이폰 피트니스앱의 그래프를 오마주했으며 동작 방식 역시 이와 동일합니다.

import SwiftUI

// MARK: - CircularKnobAnimationModifier

/// # CircularKnobAnimationModifier
///
/// 원형 프로그래스 바의 끝점에 노브(knob) 효과를 주기 위한 커스텀 `AnimatableModifier`입니다.
/// 진행률에 따라 노브가 원형 경로를 따라 움직이며, 그림자 효과도 함께 애니메이션됩니다.
///
/// ## 주요 기능
/// - **원형 경로 계산**: 진행률에 따른 노브의 정확한 위치 계산
/// - **그림자 애니메이션**: 노브 위치에 맞춘 동적 그림자 효과
/// - **다크모드 지원**: 색상 스킴에 따른 그림자 투명도 자동 조정
/// - **부드러운 애니메이션**: `AnimatableModifier` 프로토콜을 통한 연속적인 애니메이션
///
/// ## 계산 방식
/// - 시작점: 12시 방향 (-90도)
/// - 진행 방향: 시계 방향
/// - 그림자 오프셋: 진행 방향 기준 15도 앞쪽
///
/// - Note: 이 Modifier는 `MacroChartView`에서만 사용되도록 설계되었습니다.
struct CircularKnobAnimationModifier: AnimatableModifier {
  var progress: Double
  var radius: CGFloat
  var lineWidth: CGFloat
  var color: Color
  var shadowScale: CGFloat
  
  @Environment(\.colorScheme) var colorScheme
  
  var animatableData: Double {
    get { progress }
    set { progress = newValue }
  }
  
  func body(content: Content) -> some View {
    content
      .overlay(
        GeometryReader { geo in
          let knobPoint = knobPosition(geo: geo, progress: progress)
          let shadowPoint = knobShadowPosition(progress: progress)
          
          Circle()
            .fill(color)
            .frame(width: lineWidth, height: lineWidth)
            .position(x: knobPoint.x, y: knobPoint.y)
            .shadow(color: colorScheme == .dark
                    ? .black.opacity(0.5)
                    : .black.opacity(0.2),
                    radius: shadowScale * 0.02,
                    x: shadowPoint.x,
                    y: shadowPoint.y)
        }
        
      )
  }
  
  // MARK: - Helper Functions
  
  /// 현재 진행률에 따른 노브의 위치를 계산하는 함수입니다.
  ///
  /// 12시 방향(-90도)을 시작점으로 하여 시계 방향으로 진행률만큼 회전한 지점의
  /// 좌표를 반환합니다.
  ///
  /// - Parameters:
  ///   - geo: 컨테이너의 기하학적 정보
  ///   - progress: 현재 진행률 (0.0 ~ 1.0)
  /// - Returns: 노브가 위치할 CGPoint 좌표
  ///
  /// ## 계산 공식
  /// - angle = progress × 360° - 90° (12시 방향 시작)
  /// - x = centerX + cos(angle) × radius
  /// - y = centerY + sin(angle) × radius
  func knobPosition(geo: GeometryProxy, progress: Double) -> CGPoint {
    let centerX = geo.size.width / 2
    let centerY = geo.size.height / 2
    let angle = Angle(degrees: progress * 360 - 90)
    let radians = CGFloat(angle.radians)
    
    let knobX = centerX + cos(radians) * radius
    let knobY = centerY + sin(radians) * radius
    
    return CGPoint(x: knobX, y: knobY)
  }
  
  /// 노브의 그림자 위치를 계산하는 함수입니다.
  ///
  /// 노브의 진행 방향 기준으로 15도 앞쪽에 그림자를 배치하여
  /// 자연스러운 입체감을 연출합니다.
  ///
  /// - Parameter progress: 현재 진행률 (0.0 ~ 1.0)
  /// - Returns: 그림자의 오프셋 좌표 (CGPoint)
  ///
  /// ## 그림자 방향
  /// - 노브 위치에서 15도 앞쪽 방향
  /// - 오프셋 크기는 `shadowScale`의 5%로 설정
  func knobShadowPosition(progress: Double) -> CGPoint {
    let forwardAngle = Angle(degrees: progress * 360 + 15)
    let forwardRadians = CGFloat(forwardAngle.radians)
    
    let shadowOffset: CGFloat = shadowScale * 0.05
    let shadowX = cos(forwardRadians) * shadowOffset
    let shadowY = sin(forwardRadians) * shadowOffset
    
    return CGPoint(x: shadowX, y: shadowY)
  }
}

// - MARK: MacroChartView
/// # MacroChartView
///
/// 사용자의 탄수화물, 단백질, 지방 섭취량을 3중 원형 프로그래스 바로 시각화하는 차트 뷰입니다.
/// 아이폰 피트니스 앱의 Activity Ring을 오마주하여 구현했으며, 동작 방식 역시 이와 동일합니다.
///
/// ## 주요 특징
/// - **3중 원형 구조**: 탄수화물(외곽), 단백질(중간), 지방(내부) 순으로 배치
/// - **애니메이션**: 1초간의 easeInOut 애니메이션으로 부드러운 진행률 표시
/// - **동적 크기 조정**: `GeometryReader`를 사용하여 컨테이너 크기에 맞춰 자동 조정
/// - **Knob 효과**: 각 링의 끝점에 원형 노브와 그림자 효과 적용
/// - **안전한 데이터 처리**: 무한대값(`isFinite`) 체크로 UI 오류 방지
///
/// ## 디자인 사양
/// - **탄수화물**: 가장 큰 원 (100% 크기), `Color.customCarbohydrate`
/// - **단백질**: 중간 원 (75% 크기), `Color.customProtein`
/// - **지방**: 가장 작은 원 (50% 크기), `Color.customFat`
/// - **배경**: 회색 투명도 20%로 전체 링 표시
/// - **선 두께**: 컨테이너 크기의 1/10로 동적 설정
///
/// ## 사용 방법
/// ```swift
/// MacroChartView(macros: nutritionData.macroRatio)
///     .frame(width: 130, height: 130)
/// ```
///
/// ## Dependencies
/// - `CircularKnobAnimationModifier`: 원형 노브 애니메이션을 담당하는 커스텀 Modifier
/// - `MacroNutrients`: 영양소 데이터 모델 (탄수화물, 단백질, 지방 값 포함)
///
/// - Note: 입력값은 0.0 ~ 1.0 범위의 비율값이어야 정상적으로 표시됩니다.
struct MacroChartView: View {
  
  /// 탄수화물, 단백질, 지방의 비율 데이터
  /// nil인 경우 모든 값을 0으로 처리하여 빈 차트 표시
  var macrosPercentage: MacroNutrients?
  
  @State private var carbohydrateProgress: Double = 0
  @State private var proteinProgress: Double = 0
  @State private var fatProgress: Double = 0
  
  /// MacroChartView 초기화
  /// - Parameter macros: 영양소 비율 데이터 (`MacroNutrients` 타입, nil 허용)
  /// - Note: macros 인자 값으로 `MacroNutrients`의 gram 데이터를 받아야 합니다.
  init(macros: MacroNutrients?) {
    macrosPercentage = macros
  }
  
  var body: some View {
    /// MacroNutrientChartView 컴포넌트를 담는 view의 geo(height, width)값을 받아옵니다.
    /// geo값의 최소값을 기준으로 컴포넌트의 사이즈를 정의합니다.
    GeometryReader { geo in
      let side = min(geo.size.width, geo.size.height)
      let lineWidth: CGFloat = side / 10
      
      let carbohydrateSize = side
      let proteinSize = side * 0.75
      let fatSize = side * 0.5
      
      let knobOffset: CGFloat = side / 20
      
      let carbohydrateRadius = carbohydrateSize / 2 - lineWidth / 2 + knobOffset
      let proteinRadius = proteinSize / 2 - lineWidth / 2 + knobOffset
      let fatRadius = fatSize / 2 - lineWidth / 2 + knobOffset
      
      ZStack {
        // MARK: - 탄수화물 링 (가장 외곽)
        Group {
          Circle()
            .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
          
          Circle()
            .trim(from: 0, to: carbohydrateProgress)
            .stroke(Color.customCarbohydrate,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(.degrees(-90))
          
        }
        .frame(width: carbohydrateSize, height: carbohydrateSize)
        .modifier(CircularKnobAnimationModifier(progress: carbohydrateProgress,
                                                radius: carbohydrateRadius,
                                                lineWidth: lineWidth,
                                                color: .customCarbohydrate,
                                                shadowScale: side))
        
        // MARK: - 단백질 링 (중간)
        Group {
          Circle()
            .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
          
          Circle()
            .trim(from: 0, to: proteinProgress)
            .stroke(Color.customProtein,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(.degrees(-90))
          
        }
        .frame(width: proteinSize, height: proteinSize)
        .modifier(CircularKnobAnimationModifier(progress: proteinProgress,
                                                radius: proteinRadius,
                                                lineWidth: lineWidth,
                                                color: .customProtein,
                                                shadowScale: side))
        
        // MARK: - 지방 링 (가장 내부)
        Group {
          Circle()
            .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
          
          Circle()
            .trim(from: 0, to: fatProgress)
            .stroke(Color.customFat,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(.degrees(-90))
          
        }
        .frame(width: fatSize, height: fatSize)
        .modifier(CircularKnobAnimationModifier(progress: fatProgress,
                                                radius: fatRadius,
                                                lineWidth: lineWidth,
                                                color: .customFat,
                                                shadowScale: side))
      }
      
    }
    .aspectRatio(1, contentMode: .fit)
    .onAppear {
      updateProgress()
    }
    .onChange(of: macrosPercentage) { oldValue, newValue in
      updateProgress()
    }
    
  }
  
  /// 영양소 데이터가 변경될 때 각 링의 진행률을 업데이트하는 함수입니다.
  ///
  /// 무한대값이나 NaN 값이 포함된 경우 0으로 처리하여 UI 오류를 방지하고,
  /// 1초간의 easeInOut 애니메이션을 적용하여 부드러운 전환 효과를 제공합니다.
  ///
  /// ## 안전성 처리
  /// - `macrosPercentage`가 nil인 경우 모든 값을 0으로 설정
  /// - 각 영양소 값이 무한대(`isFinite = false`)인 경우 0으로 대체
  /// - 애니메이션 도중 상태 변경으로 인한 UI 깜빡임 방지
  private func updateProgress() {
    let safeMacros = macrosPercentage ?? MacroNutrients(carbohydrate: 0,
                                                        protein: 0,
                                                        fat: 0)
    
    withAnimation(.easeInOut(duration: 1)) {
      carbohydrateProgress = safeMacros.carbohydrate.isFinite ? safeMacros.carbohydrate : 0
      proteinProgress = safeMacros.protein.isFinite ? safeMacros.protein : 0
      fatProgress = safeMacros.fat.isFinite ? safeMacros.fat : 0
    }
  }
}

#Preview {
  MacroChartView(macros: .init(carbohydrate: 180, protein: 25, fat: 30))
}
