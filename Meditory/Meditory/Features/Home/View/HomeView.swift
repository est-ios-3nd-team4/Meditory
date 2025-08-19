//
//  HomeView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/1/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
  @Environment(\.modelContext) private var context
  @StateObject private var vm = HomeViewModel()
  @Environment(\.colorScheme) private var colorScheme
  @State private var selectedDate: Date = Date()

  var body: some View {
    CalendarBackgroundView(selectedDate: $selectedDate) { _ in
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
      vm.loadIntake(on: selectedDate)
    }
    .onChange(of: selectedDate) { newDate in
      vm.loadIntake(on: newDate)
    }
  }

  private var achiveMentSection: some View {
    VStack(spacing: .defaultSpacing) {
      Text("오늘 복용 달성률")
        .font(.notoSans(size: 20))
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

        LazyVStack(spacing: .smallSpacing) {
          ForEach(vm.items.indices.sorted { vm.items[$0].time < vm.items[$1].time }, id: \.self) { index in
            let item = vm.items[index]

            HStack(alignment: .center, spacing: .defaultSpacing) {
              Button {
                vm.toggleCompleted(at: index, for: selectedDate)
              } label: {
                CircleCheck(isCompleted: item.isCompleted)
                  .offset(y: 2)
              }
              .buttonStyle(.plain)

              NavigationLink(
                destination: SupplementDetailView(routine: item.routine)
              ) {
                HStack(spacing: .defaultSpacing) {
                  Text(item.name)
                    .font(.notoSans(size: 18))
                    .foregroundColor(.primary)

                  Spacer()

                  Text(item.time.timeFormatter)
                    .font(.notoSans(size: 15))
                    .foregroundStyle(
                      colorScheme == .dark
                      ? Color.secondary
                      : Color.main
                    )
                }
              }
              .buttonStyle(.plain)
            }
            .padding(.vertical, .smallSpacing)
          }
        }
      }
    }
    .padding(.defaultSpacing)
    .background(
      colorScheme == .dark
      ? Color.white.opacity(0.3)
      : Color.white
    )
    .cornerRadius(20)
    .modifier(UnifiedShadow())
    .padding(.bottom, .defaultSpacing)
  }
}

struct HomeView_Previews: PreviewProvider {
  static var container: ModelContainer = {
    let container = try! ModelContainer(
      for: Routine.self, RoutineTime.self, RoutineRecord.self,
      configurations: .init(isStoredInMemoryOnly: true)
    )
    let ctx = container.mainContext

    // 비타민 C 루틴
    let routine1 = Routine(
      type: 1,
      displayName: "비타민C",
      desc: "면역력 강화",
      category: "비타민C",
      cycleType: 1,
      cycleValue: "0", // 월=0
      startDate: Date(),
      pillsPerDose: 1,
      memo: nil,
      hasPush: true,
      imageData: nil
    )
    let hours1 = [8, 13, 20]
    let times1 = hours1.compactMap { h in
      Calendar.current.date(bySettingHour: h, minute: 0, second: 0, of: Date())
    }.map { date in
      RoutineTime(id: UUID(), time: date)
    }
    routine1.routineTimes = times1
    ctx.insert(routine1)

    // 오메가-3 루틴
    let routine2 = Routine(
      type: 1,
      displayName: "오메가-3",
      desc: "혈행 개선",
      category: "Omega-3",
      cycleType: 1,
      cycleValue: "1, 3, 5", // 월·수·금
      startDate: Date().addingTimeInterval(-86400 * 7),
      pillsPerDose: 2,
      memo: "심장 건강",
      hasPush: false,
      imageData: nil
    )
    let hours2 = [9]
    let times2 = hours2.compactMap { h in
      Calendar.current.date(bySettingHour: h, minute: 30, second: 0, of: Date())
    }.map { date in
      RoutineTime(id: UUID(), time: date)
    }
    routine2.routineTimes = times2
    ctx.insert(routine2)

    // 비타민 D 루틴
    let routine3 = Routine(
      type: 1,
      displayName: "비타민D",
      desc: "뼈 건강",
      category: "비타민D",
      cycleType: 2,
      cycleValue: "2", // 2일 간격
      startDate: Date().addingTimeInterval(-86400 * 14),
      pillsPerDose: 1,
      memo: nil,
      hasPush: true,
      imageData: nil
    )
    let hours3 = [12]
    let times3 = hours3.compactMap { h in
      Calendar.current.date(bySettingHour: h, minute: 0, second: 0, of: Date())
    }.map { date in
      RoutineTime(id: UUID(), time: date)
    }
    routine3.routineTimes = times3
    ctx.insert(routine3)

    // 프로바이오틱스 루틴
    let routine4 = Routine(
      type: 1,
      displayName: "프로바이오틱스",
      desc: "소화 개선",
      category: "프로바이오틱스",
      cycleType: 1,
      cycleValue: "2, 4, 6", // 화·목·토
      startDate: Date().addingTimeInterval(-86400 * 3),
      pillsPerDose: 1,
      memo: "장 건강",
      hasPush: false,
      imageData: nil
    )
    let hours4 = [7, 19]
    let times4 = hours4.compactMap { h in
      Calendar.current.date(bySettingHour: h, minute: 15, second: 0, of: Date())
    }.map { date in
      RoutineTime(id: UUID(), time: date)
    }
    routine4.routineTimes = times4
    ctx.insert(routine4)

    return container
  }()

  static var previews: some View {
    NavigationStack {
      HomeView()
        .environment(\.modelContext, container.mainContext)
    }
    .previewDisplayName("HomeView Dummy Preview")
  }
}
