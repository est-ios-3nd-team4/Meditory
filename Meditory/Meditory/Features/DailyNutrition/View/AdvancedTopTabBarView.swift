//
//  AdvancedTopTabBarView.swift
//  Meditory
//
//  Created by 이치훈 on 8/26/25.
//

import SwiftUI

struct AdvancedTopTabBarView: View {
  @State private var selectedTab = 0
  @State private var tabFrames: [Int: CGRect] = [:]
  @State private var underlineWidth: CGFloat = 0

  let tabs = ["최근 검색", "즐겨찾기"]
  
  var body: some View {
    VStack(spacing: 0) {
      ZStack(alignment: .bottom) {
        HStack(spacing: 0) {
          ForEach(0..<tabs.count, id: \.self) { index in
            Button {
              withAnimation(.easeInOut(duration: 0.3)) {
                selectedTab = index
                
                if let frame = tabFrames[index] {
                  underlineWidth = frame.width
                }
              }
            } label: {
              Text(tabs[index])
                .font(.notoSans(weight: selectedTab == index ? .semiBold : .regular,
                                size: 16))
                .foregroundStyle(selectedTab == index ? .primary : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background {
                  GeometryReader { geo in
                    Color.clear.preference(key: TabPreferenceKey.self,
                                           value: [index: geo.frame(in: .global)])
                    .onAppear {
                      if index == selectedTab {
                        underlineWidth = geo.size.width
                      }
                    }
                  }
                }
            }
          }
        }
        .onPreferenceChange(TabPreferenceKey.self) { value in
          tabFrames = value
        }
        
      }
      if let frame = tabFrames[selectedTab] {
        GeometryReader { geo in
          Rectangle()
            .fill(.accent)
            .frame(width: underlineWidth, height: 2)
            .offset(x: frame.minX - geo.frame(in: .global).minX)
            .animation(.easeInOut(duration: 0.3), value: underlineWidth)
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
        }
        .frame(height: 2)
      }
      
      Divider()
      
      Spacer()
    }
  }
}

struct TabPreferenceKey: PreferenceKey {
  static var defaultValue: [Int: CGRect] = [:]
  
  static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
    value.merge(nextValue(), uniquingKeysWith: { $1 })
  }
}

#Preview {
    AdvancedTopTabBarView()
}
