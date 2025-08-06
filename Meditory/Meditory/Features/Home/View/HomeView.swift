//
//  HomeView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/1/25.
//

import SwiftUI


struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        CalendarBackgroundView {
            ScrollView(showsIndicators: false) {
                VStack {
                    achiveMentSection
                    TodayHealthView(vm: TodayHealthViewModel())
                }
                .padding()
            }
        }
    }

    private var achiveMentSection: some View {
        VStack(spacing: 16) {
            Text("오늘 복용 달성률")
                .font(.notoSans(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)

            CircularProgressView(progress: vm.progress)
                .frame(width: 200, height: 200)

            VStack {
                Button {
                    print("페이지 이동 필요")
                } label: {
                    Text("추가")
                        .font(.notoSans(size: 15))
                        .tint(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)

                LazyVStack(spacing: 8) {
                    ForEach(vm.items.indices.sorted { vm.items[$0].time < vm.items[$1].time }, id: \.self) { index in
                        Button {
                            vm.toggleCompleted(at: index)
                        } label: {
                            HStack(alignment: .center, spacing: 16) {
                                CircleCheck(isCompleted: vm.items[index].isCompleted)
                                    .offset(y: 2)

                                Text(vm.items[index].name)
                                    .font(.notoSans(size: 20))
                                    .foregroundColor(.primary)

                                Spacer()

                                Text(vm.items[index].time.timeFormatter)
                                    .font(.notoSans(size: 15))
                                    .foregroundStyle(
                                        colorScheme == .dark
                                        ? Color.secondary
                                        : Color.main
                                    )
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            colorScheme == .dark
            ? Color.white.opacity(0.3)
            : Color.white
        )
        .cornerRadius(20)
        .shadow(
            color: colorScheme == .dark
            ? .clear
            : Color.black.opacity(0.08),
            radius: 10,
            x: 0,
            y: 4
        )
        .padding(.bottom, 16)
    }
}

#Preview {
    HomeView()
}
