//
//  CustomTabView.swift
//  Meditory
//
//  Created by 홍승아 on 8/4/25.
//

import SwiftUI

struct CustomTabView: View {
  
  @Binding var selectedTab: TabItem
  private let secondaryColor: Color = .init(red: 223, green: 223, blue: 223)
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 20)
        .fill(Color.white)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        .padding(.top, 14)
      
      HStack(spacing: 36) {
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
                .frame(width: 22, height: 22)
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
}

#Preview {
  GeometryReader { geometry in
    let viewWidth = geometry.size.width
    
    VStack {
      Spacer()
      
      CustomTabView(selectedTab: .constant(.home))
        .frame(width: viewWidth, height: viewWidth * 0.27)
    }
    .ignoresSafeArea()
  }
}
