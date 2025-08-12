//
//  SupplementDetailView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//


import SwiftUI

struct SupplementDetailView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme
  @StateObject private var vm: SupplementDetailViewModel

  init(
    dto: SupplementDetailDTO = .init(
      name: "오메가",
      subtitle: "혈관 건강 · 시력 유지 · 콜레스테롤 수치 개선에 도움",
      userTimes: ["오전 8시", "오후 8시"],
      userCycle: "매일",
      recTimes: ["오전 7시", "오후 7시"],
      recCycle: "매일"
    ),
    onDelete: @escaping () -> Void = {},
    onEditMine: @escaping () -> Void = {},
    onApplyRec: @escaping () -> Void = {}
  ) {
    _vm = StateObject(wrappedValue: SupplementDetailViewModel(
      dto: dto,
      onDelete: onDelete,
      onEditMine: onEditMine,
      onApplyRec: onApplyRec
    ))
  }

  var body: some View {
    NavigationStack {
      ZStack {
        ScrollView(showsIndicators: false) {
          VStack(spacing: .defaultSpacing + 8) {
            SupplementHeaderCard(title: vm.name, subtitle: vm.subtitle, emoji: "🩸")

            SplitScheduleCard(
              selectedTab: $vm.selectedTab,
              userTimes: vm.userTimes, userCycle: vm.userCycle,
              recTimes: vm.recTimes,   recCycle: vm.recCycle
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
    }
    .overlay {
      if vm.showDeleteAlert {
        DeleteAlertView(
          isPresented: $vm.showDeleteAlert,
          onDelete: vm.confirmDelete
        )
      }
    }
  }
}
#Preview("Default") {
  SupplementDetailView()
}

#Preview("Dark") {
  SupplementDetailView()
    .environment(\.colorScheme, .dark)
}

#Preview("Custom DTO + Callbacks") {
  let dto = SupplementDetailDTO(
    name: "비타민 D",
    subtitle: "면역·뼈 건강에 도움",
    userTimes: ["오전 9시", "오전 10시", "오후 9시", "오후 9시"],
    userCycle: "매일",
    recTimes: ["오전 8시", "오전 9시", "오후 8시", "오후 8시"],
    recCycle: "매일"
  )

  return SupplementDetailView(
    dto: dto,
    onDelete: { print("삭제 실행") },
    onEditMine: { print("내 일정 수정 이동") },
    onApplyRec: { print("AI 추천 적용") }
  )
}
