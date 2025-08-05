//
//  HomeView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/1/25.
//

import SwiftUI


struct HomeView: View {
    @StateObject private var vm = HomeViewModel()

    var body: some View {
        CalendarBackgroundView {
            ScrollView {
                VStack {
                    achiveMentSection
                    TodayHealthView(vm: TodayHealthViewModel())
                }
                .padding()
            }
        }
    }

    private var achiveMentSection: some View {
        VStack {
            Text("오늘 복용 달성률")
                .font(.notoSans(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)

            CircularProgressView(progress: vm.progress)
                .frame(width: 150, height: 150)

            VStack {
                Button {
                    print("페이지 이동 필요")
                } label: {
                    Text("추가")
                        .font(.notoSans(size: 15))
                        .tint(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)

                List {
                    ForEach(vm.items.indices.sorted { vm.items[$0].time < vm.items[$1].time }, id: \.self) { index in
                        Button {
                            vm.items[index].isCompleted.toggle()
                        } label: {
                            HStack {
                                Image(systemName: vm.items[index].isCompleted
                                      ? "checkmark.circle.fill"
                                      : "circle")
                                .font(.notoSans(size: 20))
                                .foregroundStyle(vm.items[index].isCompleted ? .main : .secondary)

                                Text(vm.items[index].name)
                                    .font(.notoSans(size: 20))
                                    .foregroundStyle(.black)
                                Spacer()

                                Text(vm.items[index].time.timeFormatter)
                                    .font(.notoSans(size: 15))
                                    .foregroundStyle(.main)
                            }
                        }
                        .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .listRowSeparator(.hidden)
                    }
                }
                .frame(height: 90)
                .listStyle(.plain)
                .listRowSeparator(.hidden)
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        .padding(.bottom, 16)
    }
}

#Preview {
    HomeView()
}
