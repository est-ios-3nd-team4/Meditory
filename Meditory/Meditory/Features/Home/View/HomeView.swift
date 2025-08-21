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
    CalendarBackgroundView(
      selectedDate: $selectedDate,
      completionMap: vm.dayCompletionMap
    ) { _ in
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
      vm.reloadDayCompletions(for: selectedDate)
    }
    .onChange(of: selectedDate) { oldDate, newDate in
      vm.loadIntake(on: newDate)
      let cal = Calendar.current
      let oldComp = cal.dateComponents([.year, .month], from: oldDate)
      let newComp = cal.dateComponents([.year, .month], from: newDate)
      if oldComp != newComp {
        vm.reloadDayCompletions(for: newDate)
      } else {
        vm.refreshTodayCompletion(on: newDate)
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: .didUpdateSupplement)) { _ in
      vm.loadIntake(on: selectedDate)
      vm.reloadDayCompletions(for: selectedDate)
    }
  }

  private var achiveMentSection: some View {
    UnifiedSectionCard(showsStroke: false) {
      Text("오늘 복용 달성률")
        .font(.notoSans(size: 20))
        .frame(maxWidth: .infinity, alignment: .leading)

      HStack {
        Spacer()
        CircularProgressView(progress: vm.progress)
          .frame(width: 200, height: 200)
        Spacer()
      }

      VStack {
        LazyVStack(spacing: .smallSpacing) {
          ForEach(vm.items.sorted { $0.time < $1.time }) { item in
            HStack(alignment: .center, spacing: .defaultSpacing) {
              Button {
                vm.toggleCompleted(item, for: selectedDate)
              } label: {
                CircleCheck(isCompleted: item.isCompleted)
                  .offset(y: 2)
              }
              .buttonStyle(.plain)
              .contentShape(Rectangle())

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
                      colorScheme == .dark ? Color.secondary : Color.main
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
      memo: "아침 식사 후 복용",
      hasPush: true,
      imageData: nil,
      usage: ["물과 함께 삼키세요."],
      precautions: ["공복에 복용 시 위장 장애가 발생할 수 있습니다."]
    )
    let hours1 = [8, 13, 20]
    let pills1 = [1, 2, 1]
    let times1 = hours1.enumerated().compactMap { index, h in
      let date = Calendar.current.date(bySettingHour: h, minute: 0, second: 0, of: Date())
      let pillCount = pills1[index]
      if let validDate = date {
        return RoutineTime(time: validDate, pillsPerDose: pillCount)
      }
      return nil
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
      memo: "심장 건강",
      hasPush: false,
      imageData: nil,
      usage: ["하루 1회, 식후에 복용하세요."],
      precautions: ["출혈성 질환이 있는 경우 의사와 상담하세요."]
    )
    let hours2 = [9]
    let pills2 = [2]
    let times2 = hours2.enumerated().compactMap { index, h in
      let date = Calendar.current.date(bySettingHour: h, minute: 30, second: 0, of: Date())
      let pillCount = pills2[index]
      if let validDate = date {
        return RoutineTime(time: validDate, pillsPerDose: pillCount)
      }
      return nil
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
      memo: "햇빛이 부족할 때",
      hasPush: true,
      imageData: nil,
      usage: ["매일 같은 시간에 복용하는 것이 좋습니다."],
      precautions: ["고칼슘혈증 환자는 복용에 주의하세요."]
    )
    let hours3 = [12]
    let pills3 = [1]
    let times3 = hours3.enumerated().compactMap { index, h in
      let date = Calendar.current.date(bySettingHour: h, minute: 0, second: 0, of: Date())
      let pillCount = pills3[index]
      if let validDate = date {
        return RoutineTime(time: validDate, pillsPerDose: pillCount)
      }
      return nil
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
      memo: "장 건강",
      hasPush: false,
      imageData: nil,
      usage: ["아침 식사 30분 전, 공복에 복용하세요."],
      precautions: ["항생제와 함께 복용하지 마세요."]
    )
    let hours4 = [7, 19]
    let pills4 = [1, 1]
    let times4 = hours4.enumerated().compactMap { index, h in
      let date = Calendar.current.date(bySettingHour: h, minute: 15, second: 0, of: Date())
      let pillCount = pills4[index]
      if let validDate = date {
        return RoutineTime(time: validDate, pillsPerDose: pillCount)
      }
      return nil
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
