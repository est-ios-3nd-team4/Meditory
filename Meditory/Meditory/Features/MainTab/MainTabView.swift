//
//  MainTabView.swift
//  Meditory
//
//  Created by 홍승아 on 8/4/25.
//

import SwiftUI

struct MainTabView: View {
  
  @State var selectedTab: TabItem = .home
  
  var body: some View {
    if UIDevice.isPad {
      DefaultTabView()
    } else {
      GeometryReader { geometry in
        let tabViewHeight = geometry.size.width * 0.27
        
        ZStack {
          Group {
            switch selectedTab {
            case .home:
              HomeView()
            case .recommend:
              RecommendView()
            case .add:
              Color.red
            case .dailyNutrition:
              Color.green
            case .settings:
              Color.white
            }
          }
          
          VStack {
            Spacer()
            
            CustomTabView(selectedTab: $selectedTab)
              .frame(height: tabViewHeight)
          }
        }
      }
      .ignoresSafeArea(edges: .bottom)
    }
  }
}

#Preview {
  MainTabView()
}
