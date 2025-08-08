//
//  MainTabView.swift
//  Meditory
//
//  Created by 홍승아 on 8/4/25.
//

import SwiftUI

struct MainTabView: View {

  @State var selectedTab: TabItem = .home

  private let customTabTopInset: CGFloat = 14

  var body: some View {
    NavigationStack {
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
                SettingView()
              }
            }
            .padding(.bottom, tabViewHeight - customTabTopInset)

            VStack {
              Spacer()

              CustomTabView(selectedTab: $selectedTab, topInset: customTabTopInset)
                .frame(height: tabViewHeight)
            }
          }
        }
        .ignoresSafeArea(edges: .bottom)
      }
    }
  }
}

#Preview {
  MainTabView()
}
