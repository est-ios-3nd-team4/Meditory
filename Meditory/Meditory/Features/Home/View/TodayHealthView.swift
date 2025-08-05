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
                .padding(.bottom, 8)

            Text(vm.healthContent)
                .font(.notoSans(size: 15))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(
            colorScheme == .dark
            ? Color.white.opacity(0.3)
            : Color.white
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        .onAppear {
            //vm.fetchHealthContent()
        }
    }
}
#Preview {
    MainTabView()
}
