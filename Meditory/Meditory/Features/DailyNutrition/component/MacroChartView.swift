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

/// Knob을 원형을 따라 애니메이션을 주기 위해한 Modifier입니다.
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
  
  // MARK: Func
  
  /// 데이터를 표시할 프로그래스바 끝의 position을 계산하는 함수입니다.
  func knobPosition(geo: GeometryProxy, progress: Double) -> CGPoint {
    let centerX = geo.size.width / 2
    let centerY = geo.size.height / 2
    let angle = Angle(degrees: progress * 360 - 90)
    let radians = CGFloat(angle.radians)
    
    let knobX = centerX + cos(radians) * radius
    let knobY = centerY + sin(radians) * radius
    
    return CGPoint(x: knobX, y: knobY)
  }
  
  /// 프로그래스바 끝을 shadow로 표현하고있습니다.
  ///  프로그래스바의 끝의 position를 계산해 반환하는 함수입니다.
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

struct MacroChartView: View {
  
  var macrosPercentage: MacroNutrients?
  
  @State private var carbohydrateProgress: Double = 0
  @State private var proteinProgress: Double = 0
  @State private var fatProgress: Double = 0
  
  /// macros인자 값으로 MacroNutrients gram 데이터를 받아야 합니다.
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
        // carbohydrate
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
        
        // protein
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
        
        // fat
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
