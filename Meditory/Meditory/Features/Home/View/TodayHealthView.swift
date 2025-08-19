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
    VStack(alignment: .leading) {
      Text("오늘의 건강 상식?!")
        .font(.notoSans(size: 18))
        .padding(.bottom, .smallSpacing)
      
      Text(vm.healthContent)
        .font(.notoSans(size: 15))
        .foregroundStyle(.secondary)
    }
    .padding(.defaultSpacing)
    .frame(maxWidth: .infinity, alignment: .leading)
    .frame(maxHeight: .infinity, alignment: .top)
    .background(
      colorScheme == .dark
      ? Color.white.opacity(0.3)
      : Color.white
    )
    .cornerRadius(.defaultRadius)
    .modifier(UnifiedShadow())
    .onAppear {
      //vm.fetchHealthContent()
    }
  }
}
#Preview {
  MainTabView()
}
