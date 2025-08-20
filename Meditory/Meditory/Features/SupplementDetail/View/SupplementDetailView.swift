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

  init(routine: Routine) {
    _vm = StateObject(wrappedValue: SupplementDetailViewModel(routine: routine))
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

          if !vm.usage.isEmpty {
            SupplementGuideCard(
              title: "복용법",
              icon: "pills.fill",
              type: .info,
              guide: vm.usage
            )
          }

          if !vm.precautions.isEmpty {
            SupplementGuideCard(
              title: "복용 주의 사항",
              icon: "exclamationmark.triangle.fill",
              type: .warn,
              guide: vm.precautions
            )
          }

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

    // 비타민C (사용자 설정 예시)
    let routine1 = Routine(
      type: 1,
      displayName: "비타민C",
      desc: "면역력 강화",
      category: "비타민C",
      cycleType: 1,
      cycleValue: "0", // 일요일
      startDate: Date(),
      memo: nil,
      hasPush: true,
      imageData: nil
    )
    routine1.routineTimes = [8, 13, 20].compactMap {
      Calendar.current.date(bySettingHour: $0, minute: 0, second: 0, of: Date())
    }.map { RoutineTime(time: $0) }
    ctx.insert(routine1)

    // 오메가-3 (AI 추천 포함 예시)
    let routine2 = Routine(
      type: 1,
      displayName: "오메가-3",
      desc: "혈행 개선",
      category: "Omega-3",
      cycleType: 1,
      cycleValue: "1,3,5", // 월·수·금
      startDate: Date().addingTimeInterval(-86400 * 7),
      memo: "심장 건강",
      hasPush: false,
      imageData: nil
    )
    routine2.routineTimes = [9].compactMap {
      Calendar.current.date(bySettingHour: $0, minute: 30, second: 0, of: Date())
    }.map { RoutineTime(time: $0) }

    let abs = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
    let relBase = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
    routine2.recommendedRoutineTimes = [
      RoutineTime(time: abs),
      RoutineTime(time: relBase, intakeTiming: "아침 식전 30분", intakeOffsetMinutes: 30)
    ]
    routine2.usage = ["식사와 함께 충분한 물과 복용하세요."]
    routine2.precautions = ["수술 예정인 경우 복용 전에 전문의와 상담하세요."]
    ctx.insert(routine2)

    return container
  }()

  static var previews: some View {
    let ctx = container.mainContext

    // 오메가-3를 우선 선택
    let sample = (try? ctx.fetch(
      FetchDescriptor<Routine>(predicate: #Predicate { $0.displayName == "오메가-3" })
    ).first)
    ?? (try? ctx.fetch(FetchDescriptor<Routine>()).first)!

    return NavigationStack {
      SupplementDetailView(routine: sample)
        .environment(\.modelContext, ctx)
    }
    .previewDisplayName("SupplementDetail (오메가-3 / AI 데이터 포함)")
  }
}
