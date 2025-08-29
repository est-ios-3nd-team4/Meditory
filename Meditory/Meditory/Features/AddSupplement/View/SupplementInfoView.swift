//
//  SupplementInfoView.swift
//  Meditory
//
//  Created by 홍승아 on 8/18/25.
//

import SwiftUI

struct SupplementInfoView: View {
  
  let defaultFontSize: CGFloat
  // @ObservedObject를 제거하고 일반 변수로 변경합니다.
  var addSupplementVM: AddSupplementViewModel
  @Binding var isSearchingSupplementSummary: Bool
  
  var body: some View {
    if !isSearchingSupplementSummary, let summary = addSupplementVM.supplemtSummary {
      if summary.isUnidentifiable {
        // 서버에서 해당 이름으로 영양제/약을 특정할 수 없는 경우
        VStack {
          Text("해당 영양제를 확인할 수 없어요.\n이름을 다시 입력해 주세요.")
            .font(.notoSans(size: defaultFontSize - 3))
            .foregroundStyle(.textGray)
            .padding(.vertical, .defaultSpacing)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .onAppear {
              isSearchingSupplementSummary = false
            }
        }
        .cardStyle(padding: .defaultSpacing)
      } else {
        VStack(alignment: .leading, spacing: .smallSpacing) {
          Text(summary.name)
            .font(.notoSans(size: defaultFontSize))
            .frame(maxWidth: .infinity, alignment: .leading)
          
          Text(summary.description)
            .font(.notoSans(size: defaultFontSize - 5))
            .foregroundStyle(.textGray)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .onAppear {
              isSearchingSupplementSummary = false
            }
        }
        .cardStyle(padding: .defaultSpacing)
      }
    }
    
    if isSearchingSupplementSummary {
      VStack(alignment: .leading, spacing: .smallSpacing) {
        ShimmerView(widthRatio: 0.6)
          .frame(height: 20)
        
        VStack(spacing: .smallSpacing / 2) {
          ShimmerView(widthRatio: 0.8)
            .frame(height: 15)
          
          ShimmerView(widthRatio: 0.6)
            .frame(height: 15)
        }
      }
      .frame(maxWidth: .infinity)
      .cardStyle(padding: .defaultSpacing)
    }
  }
}
