//
//  HomeView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/1/25.
//

import SwiftUI
import SwiftData

/// 메인 홈 화면입니다.
/// - 역할:
///   - 날짜별 복용 달성률과 당일 섭취 예정 목록을 표시합니다.
///   - 상단에는 `CalendarBackgroundView`로 주간 캘린더/완료 현황을 제공하고,
///     콘텐츠 영역에 달성률 섹션(`AchievementSection`)과 오늘의 건강 정보(`TodayHealthView`)를 배치합니다.
/// - 데이터 흐름:
///   - `selectedDate`가 변경되면 `.task(id:)`가 재실행되어 해당 날짜의 섭취 목록/완료 현황을 갱신합니다.
///   - 외부 화면에서 루틴이 수정되면 `.didUpdateSupplement` 알림을 받아 동일하게 갱신합니다.
struct HomeView: View {
  @Environment(\.modelContext) private var context
  // @StateObject 대신 @State를 사용합니다. (ViewModel이 외부 주입이 아닌 단순 소유 시)
  @State private var vm = HomeViewModel()
  @Environment(\.colorScheme) private var colorScheme
  /// 캘린더·목록의 기준 날짜
  @State private var selectedDate: Date = Date()
  
  var body: some View {
    // MARK: - 주간 캘린더 & 배경 컨테이너
    CalendarBackgroundView(
      selectedDate: $selectedDate,
      completionMap: vm.dayCompletionMap
    ) { _ in
      // MARK: - 스크롤 가능한 메인 콘텐츠
      ScrollView(showsIndicators: false) {
        VStack {
          // 달성률(원형 그래프) + 오늘의 섭취 목록
          AchievementSection(vm: vm, selectedDate: $selectedDate)
          // 오늘의 건강 정보(외부 ViewModel)
          TodayHealthView(vm: TodayHealthViewModel())
        }
        .padding(.defaultSpacing)
      }
    }
    // MARK: - 데이터 로딩: selectedDate 변동 시 자동 갱신
    // .onAppear / .onChange를 통합하여 코드 간결화
    .task(id: selectedDate) {
      await vm.loadIntake(on: selectedDate)
      await vm.reloadDayCompletions(for: selectedDate)
    }
    // MARK: - 알림 기반 갱신: 다른 화면에서 루틴 업데이트 시 반영
    .onReceive(NotificationCenter.default.publisher(for: .didUpdateSupplement)) { _ in
      Task {
        await vm.loadIntake(on: selectedDate)
        await vm.reloadDayCompletions(for: selectedDate)
      }
    }
  }
}

/// 홈 상단의 “오늘 복용 달성률” 카드 섹션입니다.
/// - 구성:
///   - 좌/우(또는 상/하) 배치로 원형 진행률 그래프와 섭취 목록을 보여줍니다.
///   - 아이패드와 아이폰 사이즈 클래스 차이에 따라 레이아웃이 달라집니다.
private struct AchievementSection: View {
  /// 홈 뷰모델 (진행률, 섭취 아이템, 토글 액션 등)
  @Bindable var vm: HomeViewModel
  /// 현재 선택 날짜 (토글/상세 진입 등에 사용)
  @Binding var selectedDate: Date
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.horizontalSizeClass) private var hSize
  
  /// iPad 스타일 여부
  private var isPadStyle: Bool { hSize == .regular }
  /// 진행률 원형 사이즈
  private var progressSize: CGFloat { isPadStyle ? 300 : 200 }
  /// 빈 상태 문구 폰트 사이즈
  private var emptyFontSize: CGFloat { isPadStyle ? .defaultFontSize : .defaultFontSize-2 }
  
  var body: some View {
    // 외곽 카드 컨테이너 (테두리 옵션 비활성화)
    UnifiedSectionCard(showsStroke: false) {
      Text("오늘 복용 달성률")
        .font(.notoSans(size: .defaultFontSize + 2))
        .frame(maxWidth: .infinity, alignment: .leading)
      
      // MARK: - iPad 레이아웃
      if isPadStyle {
        VStack(spacing: 24) {
          // 원형 진행률
          ProgressBlock(size: progressSize, progress: vm.progress)
            .frame(maxWidth: .infinity, alignment: .center)
          
          Group {
            // 섭취 아이템이 없는 경우
            if vm.intakeItems.isEmpty {
              EmptyState(fontSize: emptyFontSize)
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
              // 섭취 아이템 목록(스크롤 가능)
              ScrollView(showsIndicators: false) {
                intakeColumn()
                  .frame(maxWidth: .infinity, alignment: .leading)
              }
              .frame(maxHeight: progressSize)
            }
          }
        }
        .frame(maxWidth: .infinity, alignment: .top)
        
        // MARK: - iPhone 레이아웃
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
  
  /// 원형 진행률 블록
  /// - Parameters:
  ///   - size: 뷰의 한 변 길이
  ///   - progress: 0.0~1.0 진행률
  private func ProgressBlock(size: CGFloat, progress: Double) -> some View {
    CircularProgressView(progress: progress)
      .frame(width: size, height: size)
  }
  
  /// 빈 상태(오늘 루틴 없음) 안내 컴포넌트
  private struct EmptyState: View {
    /// 본문 폰트 크기
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
  
  /// 섭취 항목 목록 컬럼
  /// - 주의: ViewModel에서 정렬이 끝났다는 가정이지만,
  ///   안전하게 스냅샷을 떠서 재정렬(시간 기준)하여 표시합니다.
  /// - 토글 시 현재 셀의 스냅샷을 넘겨 인덱스 무효화 문제를 회피합니다.
  private func intakeColumn() -> some View {
    // 현재 상태의 스냅샷
    let snapshot = vm.intakeItems
    let sortedPairs = Array(snapshot.enumerated())
      .sorted { $0.element.time < $1.element.time }
    
    return VStack(alignment: .leading, spacing: .smallSpacing) {
      ForEach(sortedPairs.indices, id: \.self) { i in
        let pair = sortedPairs[i]
        let item = pair.element // 스냅샷의 item
        
        HStack(alignment: .center, spacing: .defaultSpacing) {
          // 완료 토글 버튼
          Button {
            // 토글 작업을 비동기로 실행하고, 아이템 스냅샷을 넘깁니다.
            let currentItem = item
            Task {
              await vm.toggleCompleted(currentItem, for: selectedDate)
            }
          } label: {
            CircleCheck(isCompleted: item.isCompleted)
              .offset(y: 2)
          }
          .buttonStyle(.plain)
          .contentShape(Rectangle())
          
          // 상세 화면 진입 링크
          NavigationLink(destination: SupplementDetailView(routine: item.routine)) {
            HStack(spacing: .defaultSpacing) {
              Text(item.name)
                .font(.notoSans(size: .defaultFontSize))
                .foregroundColor(.primary)
              
              Spacer()
              
              Text(item.time.timeFormatter)
                .font(.notoSans(size: .defaultFontSize - 3))
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
