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
          SupplementHeaderCard(routine: vm.routine)
          
          SchedulePanel(
            times: vm.userTimes,
            cycle: vm.userCycle
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
    
    // Case 1: 비타민C (사용자 지정)
    let vitaminC = Routine(
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
    // 오전 8시, 오후 1시, 오후 8시
    vitaminC.routineTimes = [
      Date.makeTime(hour: 8, minute: 0),
      Date.makeTime(hour: 13, minute: 0),
      Date.makeTime(hour: 20, minute: 0)
    ].map { RoutineTime(time: $0) }
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
      imageData: nil
    )
    // 오전 9시 30분
    omega.routineTimes = [
      Date.makeTime(hour: 9, minute: 30)
    ].map { RoutineTime(time: $0) }
    
    // AI 추천: 오전 8시, 아침 식전 30분
    omega.recommendedRoutineTimes = [
      RoutineTime(time: Date.makeTime(hour: 8, minute: 0)),
      RoutineTime(
        time: Calendar.current.startOfDay(for: Date()),
        intakeTiming: "아침 식전 30분",
        intakeOffsetMinutes: 30
      )
    ]
    omega.usage = ["식사와 함께 충분한 물과 복용하세요."]
    omega.precautions = ["수술 예정인 경우 복용 전에 전문의와 상담하세요."]
    ctx.insert(omega)
    
    // Case 3: 빈 루틴
    let empty = Routine(
      type: 1,
      displayName: "새로운 영양제",
      desc: nil,
      category: "기타",
      cycleType: 0,
      cycleValue: "",
      startDate: Date(),
      memo: nil,
      hasPush: false,
      imageData: nil
    )
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

