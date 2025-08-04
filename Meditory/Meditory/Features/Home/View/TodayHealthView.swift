//
//  TodayHealthView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//
import SwiftUI


struct TodayHealthView: View {
    @StateObject var vm: TodayHealthViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("오늘의 건강 상식")
                .font(.custom("NotoSansKR-Medium", size: 18))
                .padding()

            Text(vm.healthContent)
                .font(.custom("NotoSansKR-Medium", size: 15))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 130, alignment: .top)
        .background(.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        .onAppear {
            vm.fetchHealthContent()
        }
    }
}
