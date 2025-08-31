//
//  RoutineSaveError.swift
//  Meditory
//
//  Created by 홍승아 on 8/20/25.
//

import Foundation

/// 루틴 저장 과정에서 발생할 수 있는 에러
enum RoutineSaveError: Error {
  /// 영양제 요약 정보가 존재하지 않는 경우
  case supplementSummaryNotFound
  /// AI 스케줄 생성이 완료되지 않았는데 저장을 시도한 경우
  case aiScheduleSaveInterrupted
  /// 일반 저장 실패 (DB 오류 등)
  case saveFailed
  /// 루틴을 찾을 수 없는 경우
  case notFound
  
  var title: String {
    switch self {
    case .supplementSummaryNotFound:
      return "영양제 정보 없음"
    case .aiScheduleSaveInterrupted:
      return "AI 스케줄 생성 중"
    case .saveFailed, .notFound:
      return "저장 실패"
    }
  }
  
  var message: String {
    switch self {
    case .supplementSummaryNotFound:
      return "영양제 정보를 먼저 입력해주세요."
    case .aiScheduleSaveInterrupted:
      return "AI 스케줄이 아직 생성 중입니다.\n잠시 후 다시 시도해주세요."
    case .saveFailed, .notFound:
      return "예기치 못한 오류로 저장할 수 없습니다."
    }
  }
}
