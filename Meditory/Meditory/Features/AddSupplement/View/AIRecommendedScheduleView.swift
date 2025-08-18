//
//  AIRecommendedScheduleView.swift
//  Meditory
//
//  Created by 홍승아 on 8/17/25.
//

import SwiftUI

struct AIRecommendedScheduleView: View {
  
  @Environment(\.colorScheme) private var colorScheme
  
  @State private var isAIPlanCreated = false
  @State private var isAIResponseReceived = false
  private var isSkeletonVisible: Bool {
    isAIPlanCreated && !isAIResponseReceived
  }
  
  let defaultFontSize: CGFloat
  
  var body: some View {
    VStack {
      let verticalPadding: CGFloat = 15
      
      Spacer()
        .frame(height: isAIPlanCreated ? 0 : verticalPadding)
      
      HStack {
        if !isAIPlanCreated {
          Spacer()
        }
        
        Image("icon_ai_recommend")
          .resizable()
          .frame(width: 20, height: 20)
        
        Text("AI 추천 복용 스케줄")
          .font(.notoSans(size: defaultFontSize))
        
        Spacer()
      }
      
      if !isAIPlanCreated {
        Button {
          withAnimation {
            isAIPlanCreated = true
          }
        } label: {
          Text("생성하기")
            .font(.notoSans(size: defaultFontSize))
            .foregroundStyle(.main)
        }
      }
      
      if isSkeletonVisible {
        let rectangleHeight: CGFloat = 15
        let scales: [CGFloat] = [0.4, 0.6, 0.5]
        let saclesCount = CGFloat(scales.count)
        let spacing: CGFloat = 8
        
        GeometryReader { geometry in
          let width = geometry.size.width
          
          VStack(alignment: .leading, spacing: spacing) {
            ForEach(Array(scales.enumerated()), id: \.offset) { idx, scale in
              ShimmerView(scale: scale)
                .frame(height: 15)
            }
          }
        }
        .frame(height: rectangleHeight * saclesCount + spacing * (saclesCount - 1))
      }
      
      Spacer()
        .frame(height: isAIPlanCreated ? 0 : verticalPadding)
    }
    .padding(.defaultSpacing)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(colorScheme == .dark ? Color.white.opacity(0.3) : Color.white)
        .stroke(
          LinearGradient(
            gradient: Gradient(stops: [
              .init(color: .init(red: 0, green: 122, blue: 255), location: 0.0),
              .init(color: .init(red: 229, green: 114, blue: 255), location: 0.44),
              .init(color: .init(red: 155, green: 139, blue: 255), location: 0.51),
              .init(color: .init(red: 68, green: 112, blue: 247), location: 0.54),
              .init(color: .init(red: 35, green: 138, blue: 249), location: 1.0),
            ]),
            startPoint: .leading,
            endPoint: .trailing
          )
          ,
          lineWidth: 2
        )
        .modifier(UnifiedShadow())
    )
  }
}
