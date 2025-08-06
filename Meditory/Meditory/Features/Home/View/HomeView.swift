//
//  HomeView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/1/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\u2060\.modelContext) private var context
    @StateObject private var vm = HomeViewModel()
    @Environment(\u2060\.colorScheme) private var colorScheme

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
        .onAppear {
            vm.updateContext(context)
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
                NavigationLink(destination: AddSupplementView()) {
                    Text("추가")
                        .font(.notoSans(size: 15))
                        .tint(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

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

struct HomeView_Previews: PreviewProvider {
    static var container: ModelContainer = {
        let container = try! ModelContainer(
            for: Routine.self, RoutineTime.self, RoutineRecord.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
        let ctx = container.mainContext

        let routine = Routine(
            type: 1,
            name: "비타민C",
            cycleType: 1,
            cycleValue: 0,
            startDate: Date(),
            timesPerDay: 3,
            pillsPerDose: 1,
            memo: nil,
            hasPush: true,
            imageData: nil,
            productName: "Vit C",
            productDescription: "면역력 강화",
            notWith: nil,
            whenToTake: "아침 식후"
        )

        let hours = [8, 13, 20]
        let times = hours.compactMap { h in
            Calendar.current.date(bySettingHour: h, minute: 0, second: 0, of: Date())
        }.map { date in
            RoutineTime(id: UUID(), time: date)
        }
        routine.routineTimes = times

        ctx.insert(routine)

        return container
    }()

    static var previews: some View {
        HomeView()
            .environment(\u2060\.modelContext, container.mainContext)
            .previewDisplayName("HomeView Dummy Preview")
    }
}