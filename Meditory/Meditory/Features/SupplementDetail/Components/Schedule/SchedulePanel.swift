//
//  SchedulePanel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//

import SwiftUI
import SwiftData

/// 보조제 루틴의 복용 스케줄 카드 뷰
/// - 역할:
///   - 특정 `Routine`에 설정된 **복용 시간, 주기, 수정 버튼**을 통합하여 보여줍니다.
///   - `UnifiedSectionCard`를 기반으로 일관된 카드 레이아웃을 유지합니다.
/// - 구성 요소:
///   - **헤더**: 캘린더+시계 아이콘과 "복용 스케줄" 텍스트
///   - **시간 섹션**: 루틴에 설정된 `RoutineTime` 목록을 표시
///   - **주기 섹션**: 요일/간격 주기를 표시 (`RoutineFormatter.renderCycle` 변환값 사용)
///   - **수정 버튼**: `AddSupplementView(type: .edit, routine:)`으로 이동하는 NavigationLink
struct SchedulePanel: View {
  /// 표시할 루틴
  let routine: Routine
  @Environment(\.colorScheme) private var colorScheme
  
  var body: some View {
    UnifiedSectionCard() {
      // 헤더
      HStack(spacing: .smallSpacing) {
        Image(systemName: "calendar.badge.clock")
          .imageScale(.medium)
          .padding(.smallSpacing)
          .background(Circle().fill(Color.orange.opacity(0.15)))
          .foregroundStyle(.orange)
        
        Text("복용 스케줄")
          .font(.notoSans(size: .defaultFontSize))
          .fontWeight(.bold)
        
        Spacer()
      }
      
      // 시간 목록
      VStack(alignment: .leading, spacing: .smallSpacing) {
        SectionHeader(title: "시간", systemImage: "clock")
        
        VStack(spacing: 0) {
          ForEach(routine.routineTimes.sorted(by: { $0.time < $1.time })) { time in
            TimeRow(
              timeText: time.time.timeFormatter,
              pointColor: .orange,
              pills: "\(time.pillsPerDose)정"
            )
          }
        }
      }
      
      Divider()
      
      // 주기
      HStack(spacing: .smallSpacing) {
        SectionHeader(title: "주기", systemImage: "arrow.triangle.2.circlepath")
        
        WeekdayChips(
          weekdays: normalizedWeekdays(
            from: RoutineFormatter.renderCycle(
              cycleType: routine.cycleType,
              cycleValue: routine.cycleValue
            )
          )
        )
        .frame(maxWidth: .infinity, alignment: .trailing)
      }
      .padding(.bottom, .defaultSpacing)
      
      // 수정 버튼
      NavigationLink {
        AddSupplementView(type: .edit, routine: routine)
      } label: {
        HStack(spacing: .smallSpacing) {
          Image(systemName: "square.and.pencil")
          Text("내 일정 수정 하러 가기")
            .font(.notoSans(weight: .bold, size: .defaultFontSize - 3))
          Spacer()
          Image(systemName: "chevron.right")
            .font(.notoSans(weight: .semiBold, size: .defaultFontSize - 3))
        }
        .padding(.vertical, .defaultSpacing)
        .padding(.horizontal, .defaultSpacing)
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? Color.orange.opacity(0.7) : Color.orange)
        .foregroundStyle(.white)
        .cornerRadius(.defaultRadius)
      }
      .buttonStyle(.plain)
    }
  }
  
  /// 주기 문자열을 요일 배열로 변환하여 정렬된 요일 칩 리스트를 반환합니다.
  /// - Parameter cycle: `RoutineFormatter.renderCycle`의 결과 문자열
  /// - Returns: ["월","화","수"...] 형태의 요일 배열
  private func normalizedWeekdays(from cycle: String) -> [String] {
    let order = ["월","화","수","목","금","토","일"]
    
    if cycle.trimmingCharacters(in: .whitespacesAndNewlines) == "매일" {
      return order
    }
    
    if cycle.contains("매주") {
      return cycle
        .split(separator: "·")
        .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
    }
    
    let mapping: [String: String] = [
      "월요일": "월", "화요일": "화", "수요일": "수",
      "목요일": "목", "금요일": "금", "토요일": "토", "일요일": "일"
    ]
    
    let raw = cycle
      .split(separator: "·")
      .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
      .map { mapping[$0] ?? $0 }
      .filter { !$0.isEmpty }
    
    let unique = Array(NSOrderedSet(array: raw)) as? [String] ?? raw
    return unique.sorted { (a, b) -> Bool in
      (order.firstIndex(of: a) ?? .max) < (order.firstIndex(of: b) ?? .max)
    }
  }
}
