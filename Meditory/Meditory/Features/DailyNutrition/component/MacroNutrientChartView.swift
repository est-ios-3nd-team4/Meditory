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

struct MacroNutrientChartView: View {
  
  var carbohydrateProgressTarget: Double
  var proteinProgressTarget: Double
  var fatProgressTarget: Double
  
  @State private var carbohydrateProgress: Double = 0
  @State private var proteinProgress: Double = 0
  @State private var fatProgress: Double = 0
  
  
  var lineWidth: CGFloat = 40
  
  var body: some View {
    /// MacroNutrientChartView 컴포넌트를 담는 view의 geo(height, width)값을 받아옵니다.
    /// geo값의 최소값을 기준으로 컴포넌트의 사이즈를 정의합니다.
    GeometryReader { geo in
      let side = min(geo.size.width, geo.size.height)
      
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
          
          GeometryReader { innerGeo in
            let knobPoint = knobPosition(geo: innerGeo, progress: carbohydrateProgress)
            let shadowPoint = knobShadowPosition(progress: carbohydrateProgress)
            
            Circle()
              .fill(Color.customCarbohydrate)
              .frame(width: lineWidth,
                     height: lineWidth)
              .position(x: knobPoint.x,
                        y: knobPoint.y)
              .shadow(color: .black.opacity(0.3),
                      radius: 5,
                      x: shadowPoint.x,
                      y: shadowPoint.y)
          }
        }
        
        // protein
        Group {
          Circle()
            .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
          
          Circle()
            .trim(from: 0, to: proteinProgress)
            .stroke(Color.customProtein,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(.degrees(-90))
          
          GeometryReader { innerGeo in
            let knobPoint = knobPosition(geo: innerGeo, progress: proteinProgress)
            let shadowPoint = knobShadowPosition(progress: proteinProgress)
            
            Circle()
              .fill(Color.customProtein)
              .frame(width: lineWidth,
                     height: lineWidth)
              .position(x: knobPoint.x,
                        y: knobPoint.y)
              .shadow(color: .black.opacity(0.3),
                      radius: 5,
                      x: shadowPoint.x,
                      y: shadowPoint.y)
          }
        }
        .frame(width: side - 90, height: side - 90)
        
        // fat
        Group {
          Circle()
            .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
          
          Circle()
            .trim(from: 0, to: fatProgress)
            .stroke(Color.customFat,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(.degrees(-90))
          
          GeometryReader { innerGeo in
            let knobPoint = knobPosition(geo: innerGeo, progress: fatProgress)
            let shadowPoint = knobShadowPosition(progress: fatProgress)
            
            Circle()
              .fill(Color.customFat)
              .frame(width: lineWidth,
                     height: lineWidth)
              .position(x: knobPoint.x,
                        y: knobPoint.y)
              .shadow(color: .black.opacity(0.3),
                      radius: 5,
                      x: shadowPoint.x,
                      y: shadowPoint.y)
          }
        }
        .frame(width: side - 180, height: side - 180)
      }
      .frame(width: side, height: side)
      
    }
    .aspectRatio(1, contentMode: .fit)
    .onAppear {
      withAnimation(.easeInOut(duration: 1.0)) {
        carbohydrateProgress = carbohydrateProgressTarget
        proteinProgress = proteinProgressTarget
        fatProgress = fatProgressTarget
      }
    }
    
  }

  // MARK: Func
  
  /// 데이터를 표시할 프로그래스바 끝의 position을 계산하는 함수입니다.
  func knobPosition(geo: GeometryProxy, progress: Double) -> CGPoint {
    let radius = min(geo.size.width, geo.size.height) / 2 - lineWidth/2 + 20
    let angle = Angle(degrees: progress * 360 - 90)
    let radians = CGFloat(angle.radians)
    
    let knobX = geo.size.width/2 + cos(radians) * radius
    let knobY = geo.size.height/2 + sin(radians) * radius
    
    return CGPoint(x: knobX, y: knobY)
  }
  
  /// 프로그래스바 끝을 shadow로 표현하고있습니다.
  ///  프로그래스바의 끝의 position를 계산해 반환하는 함수입니다.
  func knobShadowPosition(progress: Double) -> CGPoint {
    let forwardAngle = Angle(degrees: progress * 360 + 15)
    let forwardRadians = CGFloat(forwardAngle.radians)
    
    let shadowOffset: CGFloat = 10
    let shadowX = cos(forwardRadians) * shadowOffset
    let shadowY = sin(forwardRadians) * shadowOffset
    
    return CGPoint(x: shadowX, y: shadowY)
  }
}

#Preview {
  MacroNutrientChartView(carbohydrateProgressTarget: 0.9,
                         proteinProgressTarget: 1.2,
                         fatProgressTarget: 1.1)
}
