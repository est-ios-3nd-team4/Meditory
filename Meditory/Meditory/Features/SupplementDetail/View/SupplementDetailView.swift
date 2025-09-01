//
//  SupplementDetailView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//

import SwiftUI
import SwiftData

/// 보조제 상세 화면 뷰
/// - 역할:
///   - 특정 `Routine`(영양제/약 루틴)의 상세 정보를 표시합니다.
///   - 복용 스케줄, 사용자가 기록한 메모, 복용법/주의사항 등을 카드 UI로 제공합니다.
/// - 주요 기능:
///   - 상단: 보조제 기본 정보 (`SupplementInfoCard`)
///   - 중단: 복용 스케줄 (`SchedulePanel`)
///   - 하단: 메모 카드, 복용 가이드(복용법/주의사항), 루틴 삭제 버튼
///   - 루틴 삭제 시 확인 알림(`AlertView`) 표시 후 기록까지 제거
/// - 레이아웃 최적화:
///   - iPad 및 가로 모드에 따라 `maxContentWidth`를 조정하여 넓은 화면에서도 가독성을 유지
/// - 데이터 갱신:
///   - `NotificationCenter`의 `.didUpdateSupplement` 이벤트를 구독해 다른 화면에서 루틴 변경 시 자동 갱신
///   - `refreshInfoSnapshot()`을 통해 `Routine`을 최신 상태로 Fetch 후 `SupplementDetailInfo` 스냅샷 생성
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
  
  /// 보조제 상세 정보 스냅샷 (뷰에 표시할 데이터)
  @State private var infoSnapshot: SupplementDetailInfo = .empty
  
  init(routine: Routine) {
    self.routine = routine
  }
  
  private var isPadStyle: Bool { hSize == .regular }
  private var isLandscape: Bool { vSize == .compact }
  
  /// 콘텐츠 최대 너비 (iPad/가로 모드 대응)
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
            // 루틴 기본 정보 카드
            SupplementInfoCard(routine: routine)
              .frame(maxWidth: .infinity, alignment: .leading)
            
            // 복용 스케줄 카드
            SchedulePanel(routine: routine)
              .frame(maxWidth: .infinity, alignment: .leading)
            
            // 사용자 메모 카드
            if !infoSnapshot.memo.isEmpty {
              SupplementInfoCard(type: .memo, guide: [infoSnapshot.memo])
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // 복용 가이드 (복용법 / 주의사항)
            guideGridSection
            
            // 삭제 버튼
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
    // 삭제 확인 알림
    .overlay {
      if showDeleteAlert {
        AlertView(
          alertType: .delete,
          title: "정말 삭제하시겠어요?",
          message: "루틴을 삭제하면 복용 기록도 삭제됩니다.\n삭제하시려면 아래 버튼을 눌러주세요.",
          onCancel: {
            showDeleteAlert = false
          },
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
    // 초기 진입 및 변경 감지 시 데이터 스냅샷 갱신
    .onAppear {
      Task { @MainActor in
        refreshInfoSnapshot()
      }
    }
    .onChange(of: routine.id) {
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
  
  /// 현재 `routine` 기반으로 최신 SupplementDetailInfo 생성
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
  
  /// 복용법/주의사항 카드 섹션
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
  
  /// 루틴 삭제 버튼
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
