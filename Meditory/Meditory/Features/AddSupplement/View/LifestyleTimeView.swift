//
//  LifestyleTimeView.swift
//  Meditory
//
//  Created by 홍승아 on 8/16/25.
//

import SwiftUI

struct LifestyleTimeView: View {
  
  let type: LifestyleTimeType
  let defaultFontSize: CGFloat
  @State var lifestyleTimeVM: LifestyleTimeViewModel
  
  @State private var isExpanded: Bool = false
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text(type.title)
          .font(.notoSans(size: defaultFontSize))
        
        Spacer()
        
        Button {
          isExpanded.toggle()
        } label: {
          Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
            .foregroundStyle(.textGray)
            .font(.system(size: defaultFontSize, weight: .medium))
        }
      }
      
      if isExpanded {
        VStack {
          switch type {
          case .dailyCycle:
            ForEach(DailyCycleType.allCases, id:\.self) { type in
              row(
                title: type.title,
                imageName: type.imageName,
                time: lifestyleTimeVM.time(for: type)
              )
            }
          case .meal:
            ForEach(MealType.allCases, id:\.self) { type in
              row(
                title: type.title,
                imageName: type.imageName,
                time: lifestyleTimeVM.time(for: type)
              )
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
  private func row(title: String, imageName: String, time: String) -> some View {
    HStack {
      Image(imageName)
        .resizable()
        .frame(width: 25, height: 25)
      
      Text(title)
        .font(.notoSans(weight: .regular, size: defaultFontSize))
        .foregroundStyle(.textGray)
      
      Spacer()
      
      Text(time)
        .font(.notoSans(weight: .regular, size: defaultFontSize))
    }
  }
}
