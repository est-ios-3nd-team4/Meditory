//
//  CalendarMonthHeader.swift
//  Meditory
//
//  Created by 윤혜주 on 8/15/25.
//

import SwiftUI

/// 달력 화면 상단의 월 이동 헤더 뷰입니다.
/// - 역할:
///   - 현재 월(`title`)을 중앙에 표시.
///   - 좌우 화살표 버튼으로 이전/다음 달 이동 가능.
///   - 오른쪽 상단에 “오늘” 버튼을 제공하여 즉시 오늘 날짜로 이동 가능.
/// - 커스터마이즈:
///   - `onPrev`, `onNext`, `onToday` 클로저를 통해 외부에서 동작을 주입할 수 있습니다.
/// - UI 반응형:
///   - 아이패드 여부(`isPadStyle`)에 따라 아이콘, 타이틀, “오늘” 버튼 폰트 크기를 조정합니다.
struct CalendarMonthHeader: View {
  /// 중앙에 표시할 월 타이틀 (예: "2025년 8월")
  let title: String
  /// 이전 달 이동 동작
  var onPrev: () -> Void
  /// 다음 달 이동 동작
  var onNext: () -> Void
  /// 오늘 날짜로 이동 동작
  var onToday: () -> Void

  @Environment(\.horizontalSizeClass) private var hSize
  @Environment(\.verticalSizeClass) private var vSize

  /// iPad 스타일 여부
  private var isPadStyle: Bool { hSize == .regular }

  /// 좌우 이동 아이콘 크기
  private var iconFontSize: CGFloat { isPadStyle ? 20 : 18 }
  /// 월 타이틀 폰트 크기
  private var titleFontSize: CGFloat { isPadStyle ? 22 : 20 }
  /// “오늘” 버튼 폰트 크기
  private var todayFontSize: CGFloat { isPadStyle ? 15 : 13 }

  var body: some View {
    ZStack {
      // MARK: - 좌측 화살표 + 월 타이틀 + 우측 화살표
      HStack(spacing: .defaultSpacing) {
        Button(action: onPrev) {
          Image(systemName: "chevron.left")
            .font(.notoSans(size: iconFontSize))
            .foregroundStyle(Color.primary.opacity(0.5))
            .frame(width: 40, height: 40)
            .contentShape(Rectangle())
        }

        Text(title)
          .font(.notoSans(size: titleFontSize))
          .foregroundStyle(.primary)
          .fontWeight(.bold)
          .lineLimit(1)
          .minimumScaleFactor(0.9)

        Button(action: onNext) {
          Image(systemName: "chevron.right")
            .font(.notoSans(size: iconFontSize))
            .foregroundStyle(Color.primary.opacity(0.5))
            .frame(width: 40, height: 40)
            .contentShape(Rectangle())
        }
      }

      // MARK: - 오른쪽 상단 “오늘” 버튼
      HStack {
        Spacer()
        Button(action: onToday) {
          Text("오늘")
            .foregroundStyle(.secondary)
            .font(.notoSans(size: todayFontSize))
            .fontWeight(.semibold)
            .padding(.horizontal, .defaultSpacing)
            .padding(.vertical, .smallSpacing/2)
            .background(Color.secondary.opacity(0.1), in: Capsule())
        }
        .buttonStyle(.plain)
      }
    }
    .padding(.horizontal)
  }
}

#Preview {
  struct CalendarMonthHeaderPreview: View {
    @State private var month: Date = Date()
    private let cal = Calendar.current
    private let model = CalendarDateModel()

    var body: some View {
      VStack(spacing: .defaultSpacing) {
        CalendarMonthHeader(
          title: month.yearMonth,
          onPrev: {
            if let new = cal.date(byAdding: .month, value: -1, to: month) {
              month = new
            }
          },
          onNext: {
            if let new = cal.date(byAdding: .month, value: 1, to: month) {
              month = new
            }
          },
          onToday: {
            month = cal.startOfDay(for: Date())
          }
        )
        .padding(.vertical, .defaultSpacing)

        Text("현재: \(month.yearMonth)")
          .font(.footnote)
          .foregroundStyle(.secondary)
      }
      .padding()
    }
  }

  return CalendarMonthHeaderPreview()
}
