//
//  CustomTabView.swift
//  Meditory
//
//  Created by 홍승아 on 8/4/25.
//

import SwiftUI

/// iPhone 전용 커스텀 탭바 뷰
struct CustomTabView: View {
  @Environment(\.colorScheme) private var colorScheme
  
  @Binding var selectedTab: TabItem
  var topInset: CGFloat
  var didTapAddButton: () -> Void
  
  private let iconSize = CGSize(width: 22, height: 22)
  private let cornerRadius: CGFloat = 15
  
  private var backgroundRectangle: some View {
    Rectangle()
      .fill(.background)
      .clipShape(
        RoundedCorner(radius: cornerRadius, corners: [.topLeft, .topRight])
      )
  }
  
  var body: some View {
    ZStack {
      if colorScheme == .light {
        backgroundRectangle
          .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
          .padding(.top, topInset)
      } else {
        backgroundRectangle
          .overlay(
            RoundedCorner(radius: cornerRadius, corners: [.topLeft, .topRight])
              .stroke(.white.opacity(0.3), lineWidth: 1)
          )
          .padding(.top, topInset)
      }
      
      let spacing = itemSpacing()
      let adjustedSpacing = spacing - spacing * 0.13
      
      HStack(spacing: adjustedSpacing) {
        HStack(spacing: spacing) {
          tabItemRow(for: .home)
          tabItemRow(for: .recommend)
        }
        .padding(.top, 4)
        .frame(maxWidth: .infinity, alignment: .trailing)
        
        addTabItem(for: .add)
        
        HStack(spacing: spacing) {
          tabItemRow(for: .dailyNutrition)
          tabItemRow(for: .settings)
        }
        .padding(.top, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
  
  /// 탭 아이템 사이의 가로 간격을 계산합니다.
  private func itemSpacing() -> CGFloat {
    let viewWidth = UIScreen.main.bounds.width
    let horizontalPadding: CGFloat = 20
    let itemCount = CGFloat(TabItem.allCases.count)
    let addButtonSize = AddIntakeButton.size
    
    return (viewWidth - (iconSize.width * itemCount - 1) - addButtonSize.width - horizontalPadding) / itemCount
  }
}


// MARK: - TabItem 관련 View
extension CustomTabView {
  private func addTabItem(for tab: TabItem) -> some View {
    VStack {
      AddIntakeButton()
      
      Spacer()
    }
    .onTapGesture {
      didTapAddButton()
    }
  }
  
  private func tabItemRow(for tab: TabItem) -> some View {
    let secondaryColor: Color = .init(red: 223, green: 223, blue: 223)
    let tintColor: Color = selectedTab == tab ? .main : secondaryColor
    
    return VStack(spacing: .smallSpacing) {
      (tab.isHome ? Image(tab.iconImage) : Image(systemName: tab.iconImage))
        .resizable()
        .scaledToFit()
        .frame(width: iconSize.width, height: iconSize.height)
        .foregroundStyle(tintColor)
      
      Text(tab.title)
        .font(.notoSans(size: 11))
        .foregroundStyle(tintColor)
    }
    .onTapGesture {
      selectedTab = tab
    }
  }
}
