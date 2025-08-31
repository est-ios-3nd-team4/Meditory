//
//  IntakeItem.swift
//  Meditory
//
//  Created by 윤혜주 on 8/7/25.
//
import SwiftUI

/// 사용자가 특정 시점에 섭취해야 하는 항목(영양제/약 등)을 표현하는 모델입니다.
/// - `Identifiable` 프로토콜을 채택하여 리스트 뷰 등에서 고유 식별자로 활용됩니다.
struct IntakeItem: Identifiable {
  
  /// 항목 고유 식별자
  let id: UUID
  
  /// 섭취 대상 이름 (예: "오메가3", "비타민C")
  let name: String
  
  /// 섭취 예정 시간
  let time: Date
  
  /// 실제 섭취 완료 여부
  var isCompleted: Bool
  
  /// 해당 항목이 속한 루틴 정보
  var routine: Routine
}
