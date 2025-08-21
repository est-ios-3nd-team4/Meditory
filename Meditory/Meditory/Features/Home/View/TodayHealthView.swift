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
    UnifiedSectionCard(showsStroke: false) {
      VStack(alignment: .leading, spacing: .smallSpacing) {
        Text("오늘의 건강 상식?!")
          .font(.notoSans(size: 18))
          .padding(.bottom, .smallSpacing)

        Text(vm.healthContent)
          .font(.notoSans(size: 15))
          .foregroundStyle(.secondary)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(maxHeight: .infinity, alignment: .top)
    }
    .onAppear {
      //vm.fetchHealthContent()
    }
  }
}
#Preview {
  MainTabView()
}
