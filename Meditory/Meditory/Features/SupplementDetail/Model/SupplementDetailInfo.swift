//
//  SupplementDetailInfo.swift
//  Meditory
//
//  Created by 윤혜주 on 8/27/25.
//

import Foundation

/// 보조제 상세 정보 데이터 모델
/// - 역할:
///   - `SupplementDetailView` 등 상세 화면에 표시할 **사용자 친화적인 보조제 정보**를 담습니다.
///   - DB 모델(`Routine`)에서 바로 가져온 원시 데이터가 아닌,
///     뷰에 표시하기 적합한 **문자열/리스트 형태**로 가공된 데이터입니다.
/// - 주요 항목:
///   - `userTimes`: 복용 시간 목록 (예: ["오전 8:00", "오후 9:00"])
///   - `userCycle`: 복용 주기 설명 (예: "매일", "2일 간격")
///   - `pills`: 1회 복용량 텍스트 배열 (예: ["2정", "1정"])
///   - `memo`: 메모 또는 개인 기록
///   - `usage`: 복용 방법/가이드라인 목록
///   - `precautions`: 복용 주의사항 목록
struct SupplementDetailInfo {
  /// 복용 시간 목록 (사용자 표시용 문자열)
  let userTimes: [String]
  /// 복용 주기 (예: "매일", "매주 월요일")
  let userCycle: String
  /// 1회 복용량 배열 (예: ["2정", "1정"])
  let pills: [String]
  /// 사용자 메모
  let memo: String
  /// 복용법 안내 리스트
  let usage: [String]
  /// 주의사항 리스트
  let precautions: [String]
}

extension SupplementDetailInfo {
  /// 빈 상태 기본값
  /// - 뷰 초기화 또는 데이터가 없을 때 안전하게 사용하기 위한 기본값
  static let empty = SupplementDetailInfo(
    userTimes: [],
    userCycle: "",
    pills: [],
    memo: "",
    usage: [],
    precautions: []
  )
}
