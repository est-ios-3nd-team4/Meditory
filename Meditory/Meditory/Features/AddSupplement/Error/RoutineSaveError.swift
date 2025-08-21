//
//  RoutineSaveError.swift
//  Meditory
//
//  Created by 홍승아 on 8/20/25.
//

import Foundation

enum RoutineSaveError: Error {
  case supplementSummaryNotFound
  case aiScheduleSaveInterrupted
  
  var title: String {
    switch self {
    case .supplementSummaryNotFound:
      return "영양제 정보 없음"
    case .aiScheduleSaveInterrupted:
      return "AI 스케줄 생성 중"
    }
  }
  
  var message: String {
    switch self {
    case .supplementSummaryNotFound:
      return "영양제 정보를 먼저 입력해주세요."
    case .aiScheduleSaveInterrupted:
      return "AI 스케줄이 아직 생성 중입니다.\n잠시 후 다시 시도해주세요."
    }
  }
}
