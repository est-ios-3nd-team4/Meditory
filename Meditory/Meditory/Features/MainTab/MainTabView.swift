//
//  MainTabView.swift
//  Meditory
//
//  Created by 홍승아 on 8/4/25.
//

import SwiftUI

/// 앱의 메인 탭 컨테이너 뷰
/// - iPad: `DefaultTabView` 사용
/// - iPhone: `CustomTabView` 사용
struct MainTabView: View {
  
  @Environment(\.modelContext) private var context
  @EnvironmentObject var nutritionViewModel: NutritionMainViewModel
  
  @State private var selectedTabItem: TabItem = .home
  @State private var showIntakeSelector = false
  @State private var show11 = false
  @State private var selectedIntakeItem: AddIntakeItem?
  
  private let customTabTopInset: CGFloat = 18
  
  var body: some View {
    NavigationStack {
      ZStack {
        if UIDevice.isPad {
          mainTabPadView()
        } else {
          mainTabPhoneView()
        }
      }
      .fullScreenCover(
        isPresented: Binding(
          get: { selectedIntakeItem != nil && !showIntakeSelector },
          set: { if !$0 { selectedIntakeItem = nil } }
        )
      ) {
        switch selectedIntakeItem {
        case .supplement?:
          AddSupplementView(selectedIntakeItem: $selectedIntakeItem)
        case .meal?:
          NavigationStack {
            FoodInputView()
          }
        case nil:
          EmptyView()
        }
      }
    }
  }
}

// MARK: - Subviews
extension MainTabView {
  private func mainTabPadView() -> some View {
    ZStack {
      DefaultTabView(selectedTabItem: $selectedTabItem)
      
      let insets = UIEdgeInsets(
        top: .zero,
        left: .zero,
        bottom: .defaultSpacing,
        right: .defaultSpacing * 2
      )
      
      if selectedTabItem == .home || selectedTabItem == .dailyNutrition {
        VStack(spacing: .zero) {
          Spacer()
          
          AddIntakeButton()
            .onTapGesture {
              showIntakeSelector = true
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.bottom, insets.bottom)
        .padding(.trailing, insets.right)
        
        if showIntakeSelector {
          AddIntakeSelectorPadView(
            insets: insets,
            showIntakeSelector: $showIntakeSelector,
            selectedIntakeItem: $selectedIntakeItem
          )
        }
      }
    }
  }
  
  private func mainTabPhoneView() -> some View {
    ZStack {
      let tabViewHeight: CGFloat = 104
      
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
    .ignoresSafeArea(edges: .bottom)
  }
}
