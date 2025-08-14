//
//  SupplementDetailView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//


import SwiftUI
import SwiftData

struct SupplementDetailView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.modelContext) private var context
  @StateObject private var vm: SupplementDetailViewModel

  init(
    dto: SupplementDetailDTO = .init(
      name: "오메가",
      subtitle: "혈관 건강 · 시력 유지 · 콜레스테롤 수치 개선에 도움",
      userTimes: ["오전 8시", "오후 8시"],
      userCycle: "매일",
      recTimes: ["오전 7시", "오후 7시"],
      recCycle: "매일"
    ), routine: Routine
  ) {
    _vm = StateObject(
      wrappedValue: SupplementDetailViewModel(
        dto: dto,
        routine: routine,
      )
    )
  }

  var body: some View {
    ZStack {
      ScrollView(showsIndicators: false) {
        VStack(spacing: .defaultSpacing + 8) {
          SupplementHeaderCard(title: vm.name, subtitle: vm.subtitle, emoji: "🩸")

          SplitScheduleCard(
            selectedTab: $vm.selectedTab,
            userTimes: vm.userTimes,
            userCycle: vm.userCycle,
            recTimes: vm.recTimes,
            recCycle: vm.recCycle
          )

          SupplementGuideCard(
            title: "복용법",
            icon: "pills.fill",
            type: .info,
            guide: [
              "식사와 함께 충분한 물과 복용하세요.",
              "위장 부담을 줄이려면 식후 복용이 좋아요.",
              "정해진 시간에 꾸준히 복용하면 효과가 더 높습니다."
            ]
          )

          SupplementGuideCard(
            title: "복용 주의 사항",
            icon: "exclamationmark.triangle.fill",
            type: .warn,
            guide: [
              "불포화지방과 함께 복용 시 흡수가 향상될 수 있어요.",
              "혈전 위험이 있는 경우, 전문의 상담 후 복용하세요.",
              "과다 섭취 시 소화불량·출혈 위험 — 권장량 준수."
            ]
          )

          Button(role: .destructive) {
            vm.requestDelete()
          } label: {
            Label("루틴 삭제", systemImage: "trash.fill")
              .font(.notoSans(weight: .bold, size: 17))
              .frame(maxWidth: .infinity)
              .padding(.vertical, .defaultSpacing)
          }
          .buttonStyle(.plain)
          .background(Color.white)
          .foregroundStyle(.red)
          .cornerRadius(.defaultRadius)
          .overlay(
            RoundedRectangle(cornerRadius: .defaultRadius, style: .continuous)
              .stroke(Color.red.opacity(0.2), lineWidth: 1.5)
          )
        }
        .padding(.horizontal, .smallSpacing)
        .padding(.top, .defaultSpacing)
      }
    }
    .background(.customBackground)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text("내 영양제").font(.notoSans(size: 25))
      }
      ToolbarItem(placement: .topBarLeading) {
        Button { dismiss() } label: {
          Image(systemName: "chevron.left").foregroundStyle(Color(.label))
        }
      }
    }
    .navigationBarBackButtonHidden(true)
    .overlay {
      if vm.showDeleteAlert {
        DeleteAlertView(
          isPresented: $vm.showDeleteAlert,
          onDelete: {
            vm.confirmDelete(context: context)
            dismiss()
          }
        )
      }
    }
  }
}

struct SupplementDetailView_Previews: PreviewProvider {
  static var container: ModelContainer = {
    let container = try! ModelContainer(
      for: Routine.self, RoutineTime.self, RoutineRecord.self,
      configurations: .init(isStoredInMemoryOnly: true)
    )
    let ctx = container.mainContext

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
    routine1.routineTimes = [8, 13, 20].compactMap {
      Calendar.current.date(bySettingHour: $0, minute: 0, second: 0, of: Date())
    }.map { RoutineTime(id: UUID(), time: $0) }
    ctx.insert(routine1)

    // 오메가-3
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
    routine2.routineTimes = [9].compactMap {
      Calendar.current.date(bySettingHour: $0, minute: 30, second: 0, of: Date())
    }.map { RoutineTime(id: UUID(), time: $0) }
    ctx.insert(routine2)

    // 비타민 D
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
    routine3.routineTimes = [12].compactMap {
      Calendar.current.date(bySettingHour: $0, minute: 0, second: 0, of: Date())
    }.map { RoutineTime(id: UUID(), time: $0) }
    ctx.insert(routine3)

    // 프로바이오틱스
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
    routine4.routineTimes = [7, 19].compactMap {
      Calendar.current.date(bySettingHour: $0, minute: 15, second: 0, of: Date())
    }.map { RoutineTime(id: UUID(), time: $0) }
    ctx.insert(routine4)

    return container
  }()

  // DTO 생성 헬퍼
  static func makeDTO(from r: Routine) -> SupplementDetailDTO {
    SupplementDetailDTO(
      name: r.category ?? "",
      subtitle: r.desc ?? "",
      userTimes: r.routineTimes.map { $0.time.timeFormatter },
      userCycle: RoutineFormatter.renderCycle(
        cycleType: r.cycleType,
        cycleValue: r.cycleValue
      ),
      recTimes: ["오전 7시", "오후 7시"],  // 샘플
      recCycle: "매일"
    )
  }

  static var previews: some View {
    let ctx = container.mainContext
    let omega = (try? ctx.fetch(
      FetchDescriptor<Routine>(predicate: #Predicate { $0.category == "오메가-3" })
    ).first) ?? (try! ctx.fetch(FetchDescriptor<Routine>())).first!

    let dto = makeDTO(from: omega)

    return NavigationStack {
      SupplementDetailView(dto: dto, routine: omega)
        .environment(\.modelContext, ctx)
    }
    .previewDisplayName("SupplementDetail (오메가-3)")
  }
}
