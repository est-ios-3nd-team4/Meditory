//
//  TodayHealthView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//
import SwiftUI


struct TodayHealthView: View {
  @StateObject var vm: TodayHealthViewModel
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    let shimmerScales: [CGFloat] = [0.8, 0.7, 0.6]

    UnifiedSectionCard(showsStroke: false) {
      VStack(alignment: .leading, spacing: .smallSpacing) {
        Text("오늘의 건강 상식")
          .font(.notoSans(size: 18))
          .padding(.bottom, .smallSpacing)

        Group {
          if vm.isLoading {
            VStack(alignment: .leading, spacing: .smallSpacing) {
              ForEach(Array(shimmerScales.enumerated()), id: \.offset) { _, scale in
                ShimmerView(widthRatio: scale)
                  .frame(height: 15)
              }
            }
            .padding(.top, 2)
          } else {
            Text(vm.healthContent)
              .font(.notoSans(size: 15))
              .foregroundStyle(.secondary)
              .transition(.opacity)
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(maxHeight: .infinity, alignment: .top)
      .animation(.easeInOut(duration: 0.2), value: vm.isLoading)
    }
    .task {
      await vm.fetchHealthContent()
    }
  }
}

#Preview {
  MainTabView()
}
