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
      if let routine = vm.routine {
        ScrollView(showsIndicators: false) {
          VStack(spacing: .defaultSpacing + 8) {
            SupplementHeaderCard(routine: routine)

            SchedulePanel(
              times: vm.userTimes,
              cycle: vm.userCycle,
              pills: vm.pills
            )

            if !vm.memo.isEmpty {
              SupplementGuideCard(
                type: .memo,
                guide: [vm.memo]
              )
            }

            if !vm.usage.isEmpty {
              SupplementGuideCard(
                type: .info,
                guide: vm.usage
              )
            }

            if !vm.precautions.isEmpty {
              SupplementGuideCard(
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
            .background(
              RoundedRectangle(cornerRadius: .defaultRadius, style: .continuous)
                .fill(
                  colorScheme == .dark
                  ? Color.white.opacity(0.08)
                  : .white
                )
            )
            .foregroundStyle(.red)
            .cornerRadius(.defaultRadius)
            .overlay(
              RoundedRectangle(cornerRadius: .defaultRadius, style: .continuous)
                .stroke(Color.red.opacity(0.2), lineWidth: 1.5)
            )
          }
          .padding(.horizontal, .defaultSpacing)
          .padding(.top, .defaultSpacing)
        }
      } else {
        Color.clear.onAppear {
          dismiss()
        }
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
            vm.confirmDelete(context: context, dismiss: dismiss)
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

    // Case 1: 비타민C (사용자 지정)
    let vitaminC = Routine(
      type: 1,
      displayName: "비타민C",
      desc: "면역력 강화",
      category: "비타민C",
      cycleType: 1,
      cycleValue: "0", // 일요일
      startDate: Date(),
      memo: "면역력 강화",
      hasPush: true,
      imageData: nil,
      usage: ["식사 후 30분 이내 복용 권장"],
      precautions: ["공복에 복용 시 위장 장애가 발생할 수 있습니다."]
    )
    vitaminC.routineTimes = [
      RoutineTime(time: Date.makeTime(hour: 8, minute: 0), pillsPerDose: 1),
      RoutineTime(time: Date.makeTime(hour: 13, minute: 0), pillsPerDose: 1),
      RoutineTime(time: Date.makeTime(hour: 20, minute: 0), pillsPerDose: 2)
    ]
    ctx.insert(vitaminC)

    // Case 2: 오메가-3 (사용자 지정 + AI 추천)
    let omega = Routine(
      type: 1,
      displayName: "오메가-3",
      desc: "혈행 개선",
      category: "Omega-3",
      cycleType: 1,
      cycleValue: "1,3,5", // 월·수·금
      startDate: Date().addingTimeInterval(-86400 * 7),
      memo: "심장 건강",
      hasPush: false,
      imageData: nil,
      usage: ["식사와 함께 충분한 물과 복용하세요."],
      precautions: ["수술 예정인 경우 복용 전에 전문의와 상담하세요."]
    )
    omega.routineTimes = [
      RoutineTime(time: Date.makeTime(hour: 9, minute: 30), pillsPerDose: 1)
    ]
    ctx.insert(omega)

    // Case 3: 빈 루틴 (사용자/추천 데이터 없음)
    let empty = Routine(
      type: 1,
      displayName: "새로운 영양제",
      desc: "아직 루틴을 설정하지 않았어요.",
      category: "기타",
      cycleType: 0,
      cycleValue: "",
      startDate: Date(),
      memo: nil,
      hasPush: false,
      imageData: nil
    )
    // usage/precautions를 추가하여 디테일 화면에서 표시될 수 있도록 함
    empty.usage = ["의사와 상의하여 복용 방법을 정하세요."]
    empty.precautions = ["특이 체질이거나 알레르기가 있는 경우 성분을 확인하세요."]
    ctx.insert(empty)

    return container
  }()

  static var previews: some View {
    let ctx = container.mainContext

    Group {
      NavigationStack {
        SupplementDetailView(
          routine: try! ctx.fetch(FetchDescriptor<Routine>(
            predicate: #Predicate { $0.displayName == "비타민C" }
          )).first!
        )
        .environment(\.modelContext, ctx)
      }
      .previewDisplayName("Detail - 비타민C")

      NavigationStack {
        SupplementDetailView(
          routine: try! ctx.fetch(FetchDescriptor<Routine>(
            predicate: #Predicate { $0.displayName == "오메가-3" }
          )).first!
        )
        .environment(\.modelContext, ctx)
      }
      .previewDisplayName("Detail - 오메가-3")

      NavigationStack {
        SupplementDetailView(
          routine: try! ctx.fetch(FetchDescriptor<Routine>(
            predicate: #Predicate { $0.displayName == "새로운 영양제" }
          )).first!
        )
        .environment(\.modelContext, ctx)
      }
      .previewDisplayName("Detail - Empty Routine")
    }
    .environment(\.locale, Locale(identifier: "ko_KR"))
  }
}
