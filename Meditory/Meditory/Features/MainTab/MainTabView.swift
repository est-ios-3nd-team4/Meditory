//
//  MainTabView.swift
//  Meditory
//
//  Created by 홍승아 on 8/4/25.
//

import SwiftUI

struct MainTabView: View {

  @Environment(\.modelContext) private var context
  
  @State private var selectedTabItem: TabItem = .home
  @State private var showIntakeSelector = false
  @State private var selectedIntakeItem: AddIntakeItem?

  private let customTabTopInset: CGFloat = 18

  var body: some View {
    NavigationStack {
      if UIDevice.isPad {
        DefaultTabView()
      } else {
        GeometryReader { geometry in
          let tabViewHeight = geometry.size.width * 0.26

          ZStack {
            Group {
              switch selectedTabItem {
              case .home:
                HomeView()
              case .recommend:
                RecommendView()
              case .dailyNutrition:
                NutritionHomeView()
              case .settings:
                SettingView()
              default:
                Color.clear
              }
            }
            .padding(.bottom, tabViewHeight - customTabTopInset)

            VStack {
              Spacer()

              CustomTabView(
                selectedTab: $selectedTabItem,
                topInset: customTabTopInset,
                didTapAddButton: {
                  showIntakeSelector = true
                }
              )
              .frame(height: tabViewHeight)
            }
            
            if showIntakeSelector {
              AddIntakeSelectorView(
                tabHeight: tabViewHeight,
                showIntakeSelector: $showIntakeSelector,
                selectedIntakeItem: $selectedIntakeItem
              )
            }
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
