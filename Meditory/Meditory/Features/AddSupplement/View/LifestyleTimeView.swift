//
//  LifestyleTimeView.swift
//  Meditory
//
//  Created by 홍승아 on 8/16/25.
//

import SwiftUI

/// 라이프스타일 시간(기상/취침, 식사 시간 등)을 표시하는 카드 뷰
struct LifestyleTimeView: View {
  
  let type: LifestyleTimeType
  let lifestyleTimeItems: [LifestyleTimeItem]
  let onTapGesture: ((any LifestyleTime) -> Void)?
  
  @State private var isExpanded: Bool = false
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text(type.title)
          .font(.notoSans(size: .defaultFontSize))
        
        Spacer()
        
        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
          .foregroundStyle(.textGray)
          .font(.system(size: .defaultFontSize, weight: .medium))
      }
      .contentShape(Rectangle())
      .onTapGesture {
        isExpanded.toggle()
      }
      
      if isExpanded {
        VStack {
          ForEach(lifestyleTimeItems.indices, id:\.self) { index in
            let item = lifestyleTimeItems[index]
            
            lifestyleTimeRow(
              title: item.type.title,
              imageName: item.type.imageName,
              time: item.time
            )
            .contentShape(Rectangle())
            .onTapGesture {
              onTapGesture?(item.type)
            }
          }
        }
      }
    }
    .cardStyle(padding: .defaultSpacing)
  }
}


// MARK: - Subviews
extension LifestyleTimeView {
  private func lifestyleTimeRow(title: String, imageName: String, time: String) -> some View {
    HStack {
      Image(imageName)
        .resizable()
        .frame(width: 25, height: 25)
      
      Text(title)
        .font(.notoSans(weight: .regular, size: .defaultFontSize))
        .foregroundStyle(.textGray)
      
      Spacer()
      
      Text(time)
        .font(.notoSans(weight: .regular, size: .defaultFontSize))
    }
  }
}
