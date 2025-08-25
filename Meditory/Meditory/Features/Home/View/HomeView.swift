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
  // @StateObject 대신 @State를 사용합니다.
  @State private var vm = HomeViewModel()
  @Environment(\.colorScheme) private var colorScheme
  @State private var selectedDate: Date = Date()

  var body: some View {
    CalendarBackgroundView(
      selectedDate: $selectedDate,
      completionMap: vm.dayCompletionMap
    ) { _ in
      ScrollView(showsIndicators: false) {
        VStack {
          AchievementSection(vm: vm, selectedDate: $selectedDate)
          TodayHealthView(vm: TodayHealthViewModel())
        }
        .padding(.defaultSpacing)
      }
    }
    // .onAppear와 .onChange를 .task(id:)로 통합하여 코드를 더 깔끔하게 만듭니다.
    // selectedDate가 변경될 때마다 이 task가 자동으로 다시 실행됩니다.
    .task(id: selectedDate) {
      await vm.loadIntake(on: selectedDate)
      await vm.reloadDayCompletions(for: selectedDate)
    }
    // 다른 화면에서 루틴이 업데이트되었을 때의 알림을 처리합니다.
    .onReceive(NotificationCenter.default.publisher(for: .didUpdateSupplement)) { _ in
      Task {
        await vm.loadIntake(on: selectedDate)
        await vm.reloadDayCompletions(for: selectedDate)
      }
    }
  }
}

private struct AchievementSection: View {
  @Bindable var vm: HomeViewModel
  @Binding var selectedDate: Date
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.horizontalSizeClass) private var hSize

  private var isPadStyle: Bool { hSize == .regular }

  private var progressSize: CGFloat { isPadStyle ? 300 : 200 }
  private var emptyFontSize: CGFloat { isPadStyle ? 18 : 16 }

  var body: some View {
    UnifiedSectionCard(showsStroke: false) {
      Text("오늘 복용 달성률")
        .font(.notoSans(size: 20))
        .frame(maxWidth: .infinity, alignment: .leading)
      if isPadStyle {
        VStack(spacing: 24) {
          ProgressBlock(size: progressSize, progress: vm.progress)
            .frame(maxWidth: .infinity, alignment: .center)

          Group {
            if vm.intakeItems.isEmpty {
              EmptyState(fontSize: emptyFontSize)
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
              ScrollView(showsIndicators: false) {
                intakeColumn()
                  .frame(maxWidth: .infinity, alignment: .leading)
              }
              .frame(maxHeight: progressSize)
            }
          }
        }
        .frame(maxWidth: .infinity, alignment: .top)

      } else {
        HStack {
          Spacer()
          ProgressBlock(size: progressSize, progress: vm.progress)
          Spacer()
        }

        Group {
          if vm.intakeItems.isEmpty {
            EmptyState(fontSize: emptyFontSize)
              .frame(maxWidth: .infinity, alignment: .center)
              .padding(.vertical, .defaultSpacing)
          } else {
            intakeColumn()
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
      }
    }
    .padding(.bottom, .defaultSpacing + 8)
  }

  private func ProgressBlock(size: CGFloat, progress: Double) -> some View {
    CircularProgressView(progress: progress)
      .frame(width: size, height: size)
  }

  private struct EmptyState: View {
    let fontSize: CGFloat
    
    var body: some View {
      VStack(spacing: .smallSpacing) {
        Text("오늘은 등록된 복용 루틴이 없어요.")
          .font(.notoSans(size: fontSize))
          .foregroundStyle(.secondary)

        Text("복용 루틴을 추가해 보세요!")
          .font(.notoSans(size: fontSize))
          .fontWeight(.semibold)
          .foregroundStyle(Color.main)
      }
      .frame(maxWidth: .infinity, alignment: .center)
    }
  }

  // ViewModel에서 이미 정렬되었으므로, items를 직접 사용합니다.
 private func intakeColumn() -> some View {
    VStack(alignment: .leading, spacing: .smallSpacing) {
      ForEach(vm.intakeItems) { item in
        HStack(alignment: .center, spacing: .defaultSpacing) {
          Button {
            // toggleCompleted 호출을 Task로 감싸고, item을 직접 전달합니다. (develop 기준)
            Task {
              await vm.toggleCompleted(item, for: selectedDate)
            }
          } label: {
            CircleCheck(isCompleted: item.isCompleted)
              .offset(y: 2)
          }
          .buttonStyle(.plain)
          .contentShape(Rectangle())

          NavigationLink(destination: SupplementDetailView(routine: item.routine)) {
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
#Preview {
  MainTabView()
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
struct HomeView_Previews2: PreviewProvider {
  static var container: ModelContainer = {
    let container = try! ModelContainer(
      for: Routine.self, RoutineTime.self, RoutineRecord.self,
      configurations: .init(isStoredInMemoryOnly: true)
    )
    let ctx = container.mainContext
    
    // 비타민 C 루틴 (08:00, 13:00, 20:00)
    let routine1 = Routine(
      type: 1,
      displayName: "비타민C",
      desc: "면역력 강화",
      category: "비타민C",
      cycleType: 1,
      cycleValue: "0",
      startDate: Date(),
      memo: "아침 식사 후 복용",
      hasPush: true
    )
    routine1.routineTimes = [
      RoutineTime(time: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!, pillsPerDose: 1),
      RoutineTime(time: Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: Date())!, pillsPerDose: 2),
      RoutineTime(time: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!, pillsPerDose: 1)
    ]
    ctx.insert(routine1)
    
    // 오메가-3 루틴 (⚠️ 08:00으로 겹치게 설정)
    let routine2 = Routine(
      type: 1,
      displayName: "오메가-3",
      desc: "혈행 개선",
      category: "Omega-3",
      cycleType: 1,
      cycleValue: "1,3,5",
      startDate: Date().addingTimeInterval(-86400 * 7),
      memo: "심장 건강",
      hasPush: false
    )
    routine2.routineTimes = [
      RoutineTime(time: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!, pillsPerDose: 2)
    ]
    ctx.insert(routine2)
    
    // 비타민 D 루틴 (12:00)
    let routine3 = Routine(
      type: 1,
      displayName: "비타민D",
      desc: "뼈 건강",
      category: "비타민D",
      cycleType: 2,
      cycleValue: "2",
      startDate: Date().addingTimeInterval(-86400 * 14),
      memo: "햇빛이 부족할 때",
      hasPush: true
    )
    routine3.routineTimes = [
      RoutineTime(time: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!, pillsPerDose: 1)
    ]
    ctx.insert(routine3)
    
    // 프로바이오틱스 루틴 (07:15, 19:15)
    let routine4 = Routine(
      type: 1,
      displayName: "프로바이오틱스",
      desc: "소화 개선",
      category: "프로바이오틱스",
      cycleType: 1,
      cycleValue: "2,4,6",
      startDate: Date().addingTimeInterval(-86400 * 3),
      memo: "장 건강",
      hasPush: false
    )
    routine4.routineTimes = [
      RoutineTime(time: Calendar.current.date(bySettingHour: 7, minute: 15, second: 0, of: Date())!, pillsPerDose: 1),
      RoutineTime(time: Calendar.current.date(bySettingHour: 19, minute: 15, second: 0, of: Date())!, pillsPerDose: 1)
    ]
    ctx.insert(routine4)
    
    return container
  }()
  
  static var previews: some View {
    NavigationStack {
      HomeView()
        .environment(\.modelContext, container.mainContext)
    }
    .previewDisplayName("HomeView (시간 겹치는 더미 데이터)")
  }
}
