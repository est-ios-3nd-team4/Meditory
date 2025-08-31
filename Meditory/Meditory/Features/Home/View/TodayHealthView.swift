//
//  TodayHealthView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//

import SwiftUI

/// “오늘의 건강 상식” 섹션을 표시하는 뷰입니다.
/// - 특징:
///   - AI/외부 API 등을 통해 가져온 건강 팁(`healthContent`)을 표시합니다.
///   - 데이터 로딩 중일 때는 `ShimmerView`를 사용해 로딩 상태를 시각적으로 제공합니다.
///   - `UnifiedSectionCard` 안에 표시되어 앱 전반의 카드 스타일을 따릅니다.
/// - 상호작용:
///   - 뷰가 나타날 때 `.task`를 통해 `TodayHealthViewModel.fetchHealthContent()`를 호출하여 내용을 가져옵니다.
struct TodayHealthView: View {
  /// 오늘의 건강 정보를 관리하는 뷰모델
  @StateObject var vm: TodayHealthViewModel
  
  @Environment(\.colorScheme) private var colorScheme
  
  var body: some View {
    // 로딩 상태에 따른 Shimmer 크기 배열
    let shimmerScales: [CGFloat] = [0.8, 0.7, 0.6]
    
    UnifiedSectionCard(showsStroke: false) {
      VStack(alignment: .leading, spacing: .smallSpacing) {
        // MARK: - 헤더 영역 (타이틀 + 정보 버튼)
        HStack {
          Text("오늘의 건강 상식")
            .font(.notoSans(size: .defaultFontSize))
            .padding(.bottom, .smallSpacing)
          
          Spacer()
          
          // “i” 버튼 (추가 정보 또는 안내)
          InfoButton()
            .offset(y: -3)
        }
        
        // MARK: - 본문 영역
        Group {
          if vm.isLoading {
            // 로딩 상태 → Shimmer 애니메이션 뷰
            VStack(alignment: .leading, spacing: .smallSpacing) {
              ForEach(Array(shimmerScales.enumerated()), id: \.offset) { _, scale in
                ShimmerView(widthRatio: scale)
                  .frame(height: 15)
              }
            }
            .padding(.top, 2)
          } else {
            // 로딩 완료 → 건강 정보 텍스트 표시
            Text(vm.healthContent)
              .font(.notoSans(size: .defaultFontSize - 3))
              .foregroundStyle(.secondary)
              .transition(.opacity)
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(maxHeight: .infinity, alignment: .top)
      // 로딩 전환 시 부드러운 페이드 효과
      .animation(.easeInOut(duration: 0.2), value: vm.isLoading)
    }
    // MARK: - 뷰가 나타날 때 건강 상식 불러오기
    .task {
      await vm.fetchHealthContent()
    }
  }
}

#Preview {
  MainTabView()
}
