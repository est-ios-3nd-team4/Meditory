//
//  DefaultTabView.swift
//  Meditory
//
//  Created by 홍승아 on 8/4/25.
//

import SwiftUI

struct DefaultTabView: View {
  
  var body: some View {
    TabView() {
      HomeView()
        .tabItem {
          Text(TabItem.home.title)
        }
      
      RecommendView()
        .tabItem {
          Text(TabItem.recommend.title)
        }
      
      NutritionHomeView()
        .tabItem {
          Text(TabItem.dailyNutrition.title)
        }
      
      SettingView()
        .tabItem {
          Text(TabItem.settings.title)
        }
    }
  }
}

#Preview {
  DefaultTabView()
}
