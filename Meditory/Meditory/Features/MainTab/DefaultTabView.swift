//
//  DefaultTabView.swift
//  Meditory
//
//  Created by 홍승아 on 8/4/25.
//

import SwiftUI

/// iPad 전용 탭바 뷰
struct DefaultTabView: View {
  
  @Binding var selectedTabItem: TabItem
  
  var body: some View {
    TabView() {
      HomeView()
        .tabItem {
          Text(TabItem.home.title)
        }
        .onAppear {
          selectedTabItem = .home
        }
      
      RecommendView()
        .tabItem {
          Text(TabItem.recommend.title)
        }
        .onAppear {
          selectedTabItem = .recommend
        }
      
      NutritionHomeView()
        .tabItem {
          Text(TabItem.dailyNutrition.title)
        }
        .onAppear {
          selectedTabItem = .dailyNutrition
        }
      
      SettingView()
        .tabItem {
          Text(TabItem.settings.title)
        }
        .onAppear {
          selectedTabItem = .settings
        }
    }
  }
}
