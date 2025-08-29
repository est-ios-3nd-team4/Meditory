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
  @Environment(\.horizontalSizeClass) private var hSize
  @Environment(\.verticalSizeClass) private var vSize
  @State private var vm = SupplementDetailViewModel()
  @Bindable var routine: Routine

  @State private var isAtTop: Bool = true
  @State private var showDeleteAlert: Bool = false
  @State private var isDeleting: Bool = false

  @State private var infoSnapshot: SupplementDetailInfo = .empty

  init(routine: Routine) {
    self.routine = routine
  }

  private var isPadStyle: Bool { hSize == .regular }
  private var isLandscape: Bool { vSize == .compact }

  private var maxContentWidth: CGFloat {
    if isPadStyle {
      return isLandscape ? 1040 : 820
    } else {
      return .infinity
    }
  }

  var body: some View {
    ZStack {
      if !isDeleting {
        ScrollView(showsIndicators: false) {
          ScrollTopObserver(isAtTop: $isAtTop)

          VStack(spacing: .defaultSpacing + 8) {
            SupplementInfoCard(routine: routine)
              .frame(maxWidth: .infinity, alignment: .leading)

            SchedulePanel(routine: routine)
              .frame(maxWidth: .infinity, alignment: .leading)

            if !infoSnapshot.memo.isEmpty {
              SupplementInfoCard(type: .memo, guide: [infoSnapshot.memo])
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            guideGridSection
            deleteButton
          }
          .frame(maxWidth: maxContentWidth, alignment: .top)
          .padding(.horizontal, .defaultSpacing)
          .frame(maxWidth: .infinity, alignment: .top)
        }
      }
    }
    .background(.customBackground)
    .navigationBar(.supplementDetail, isAtTop: isAtTop)
    .overlay {
      if showDeleteAlert {
        DeleteAlertView(
          isPresented: $showDeleteAlert,
          onDelete: {
            let pid  = routine.persistentModelID
            let uuid = routine.id

            isDeleting = true
            dismiss()

            Task { @MainActor in
              await vm.deleteByIDs(pid: pid, uuid: uuid, viewContext: context)
            }
          }
        )
      }
    }
    .onAppear {
      Task { @MainActor in
        refreshInfoSnapshot()
      }
    }
    .onChange(of: routine.id) { _ in
      Task { @MainActor in
        refreshInfoSnapshot()
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: .didUpdateSupplement)) { _ in
      guard !isDeleting else { return }
      Task { @MainActor in
        refreshInfoSnapshot()
      }
    }
  }

  @MainActor
  private func refreshInfoSnapshot() {
    guard !isDeleting else { return }

    let targetID: UUID = routine.id

    let fetchDescriptor = FetchDescriptor<Routine>(
      predicate: #Predicate<Routine> { $0.id == targetID }
    )

    if let fresh = try? context.fetch(fetchDescriptor).first {
      infoSnapshot = vm.makeSupplementDetailInfo(from: fresh)
    } else {
      dismiss()
    }
  }

  @ViewBuilder
  private var guideGridSection: some View {
    let hasUsage = infoSnapshot.usage.first != nil
    let hasPrecaution = infoSnapshot.precautions.first != nil

    if hasUsage || hasPrecaution {
      VStack(alignment: .leading, spacing: .defaultSpacing) {
        if let usage = infoSnapshot.usage.first {
          SupplementInfoCard(type: .info, guide: [usage])
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        if let precautions = infoSnapshot.precautions.first {
          SupplementInfoCard(type: .warn, guide: [precautions])
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private var deleteButton: some View {
    Button(role: .destructive) {
      showDeleteAlert = true
    } label: {
      Label("루틴 삭제", systemImage: "trash.fill")
        .font(.notoSans(weight: .bold, size: .defaultFontSize - 1))
        .frame(maxWidth: .infinity)
        .padding(.vertical, .defaultSpacing)
    }
    .buttonStyle(.plain)
    .background(
      RoundedRectangle(cornerRadius: .defaultRadius, style: .continuous)
        .fill(colorScheme == .dark ? Color.white.opacity(0.08) : .white)
    )
    .foregroundStyle(.red)
    .cornerRadius(.defaultRadius)
    .overlay(
      RoundedRectangle(cornerRadius: .defaultRadius, style: .continuous)
        .stroke(Color.red.opacity(0.2), lineWidth: 1.5)
    )
  }
}

extension SupplementDetailView {
  private struct DeleteAlertView: View {
    @Binding var isPresented: Bool
    var onDelete: () -> Void

    @Environment(\.horizontalSizeClass) private var hSize

    private var isPadStyle: Bool { hSize == .regular }
    private var maxCardWidth: CGFloat { isPadStyle ? 520 : .infinity }

    var body: some View {
      ZStack {
        Color.black.opacity(0.35)
          .ignoresSafeArea()
          .contentShape(Rectangle())
          .onTapGesture { isPresented = false }

        VStack(spacing: .defaultSpacing * 2) {
          Text("정말 삭제하시겠어요?")
            .font(.notoSans(size: .defaultFontSize + 6))
            .fontWeight(.bold)
            .multilineTextAlignment(.center)

          VStack(spacing: .smallSpacing) {
            Text("루틴을 삭제하면 복용 기록도 삭제됩니다.")
            Text("삭제하시려면 아래 버튼을 눌러주세요.")
          }
          .font(.notoSans(weight: .regular, size: .defaultFontSize))
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)

          HStack(spacing: .defaultSpacing) {
            Button {
              isPresented = false
            } label: {
              Text("아니요")
                .font(.notoSans(size: .defaultFontSize))
                .frame(maxWidth: .infinity)
                .padding(.vertical, .smallSpacing)
            }
            .buttonStyle(.plain)
            .background(Color.secondary.opacity(0.16))
            .overlay(
              RoundedRectangle(cornerRadius: .smallRadius, style: .continuous)
                .stroke(Color(.systemGray4), lineWidth: 1)
            )
            .cornerRadius(.smallRadius)

            Button {
              onDelete()
              isPresented = false
            } label: {
              Text("삭제")
                .font(.notoSans(size: .defaultFontSize))
                .frame(maxWidth: .infinity)
                .padding(.vertical, .smallSpacing)
            }
            .foregroundStyle(.white)
            .background(Color.red)
            .cornerRadius(.smallRadius)
          }
        }
        .padding(.defaultSpacing + 8)
        .frame(maxWidth: maxCardWidth, alignment: .center)
        .background(
          RoundedRectangle(cornerRadius: .defaultRadius, style: .continuous)
            .fill(.regularMaterial)
        )
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        .padding(.horizontal, .defaultSpacing)
        .zIndex(1000)
      }
      .transition(.opacity)
      .zIndex(1000)
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
