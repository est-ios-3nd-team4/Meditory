//
//  CustomTabView.swift
//  Meditory
//
//  Created by 홍승아 on 8/4/25.
//

import SwiftUI

struct CustomTabView: View {
  @Environment(\.colorScheme) private var colorScheme
  
  @Binding var selectedTab: TabItem
  var topInset: CGFloat
  
  private let iconSize = CGSize(width: 22, height: 22)
  private let addButtonSize = CGSize(width: 65, height: 65)
  private let cornerRadius: CGFloat = 15
  
  private var backgroundRectangle: some View {
    Rectangle()
      .fill(.background)
      .clipShape(
        RoundedCorner(radius: cornerRadius, corners: [.topLeft, .topRight])
      )
  }
  
  var body: some View {
    let secondaryColor: Color = .init(red: 223, green: 223, blue: 223)
    
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
      
      HStack(spacing: itemSpacing()) {
        ForEach(TabItem.allCases, id: \.self) { tab in
          if tab.isAdd {
            VStack {
              Circle()
                .frame(width: 65, height: 65)
                .foregroundStyle(.main)
                .overlay {
                  Image(systemName: tab.iconImage)
                    .font(.system(size: 35, weight: .semibold))
                    .foregroundStyle(.white)
                }
              
              Spacer()
            }
            .onTapGesture {
              selectedTab = tab
            }
          } else {
            VStack(spacing: 8) {
              let tintColor: Color = selectedTab == tab ? .main : secondaryColor
              
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
      }
    }
  }
  
  /// 탭 아이템 사이의 가로 간격을 계산합니다.
  private func itemSpacing() -> CGFloat {
    let viewWidth = UIScreen.main.bounds.width
    let horizontalPadding: CGFloat = 18
    let itemCount = CGFloat(TabItem.allCases.count)
    
    return (viewWidth - (iconSize.width * itemCount - 1) - addButtonSize.width - horizontalPadding) / itemCount
  }
}

#Preview {
  GeometryReader { geometry in
    let viewWidth = geometry.size.width
    
    VStack {
      Spacer()
      
      CustomTabView(selectedTab: .constant(.home), topInset: 14)
        .frame(width: viewWidth, height: viewWidth * 0.27)
    }
    .ignoresSafeArea()
  }
}
