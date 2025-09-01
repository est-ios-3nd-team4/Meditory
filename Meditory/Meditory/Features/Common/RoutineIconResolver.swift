//
//  RoutineIconResolver.swift
//  Meditory
//
//  Created by 윤혜주 on 8/19/25.
//

import SwiftUI

/// **루틴 아이콘 & 색상 매핑 유틸리티**
/// - 역할:
///   - 루틴 카테고리(`category`) 및 표시 이름(`displayName`)을 기반으로
///     적절한 SF Symbol 아이콘과 색상을 매칭합니다.
///   - 앱 내 루틴 리스트, 상세 화면, 캘린더 등에서 일관된 아이콘 스타일을 제공하는 데 사용됩니다.
struct RoutineIconResolver {
  // MARK: - 내부 팔레트
  /// 카테고리에 따라 해시된 색상을 뽑아내기 위한 팔레트
  private static let palette: [Color] = [.blue, .teal, .indigo, .orange, .purple, .green]
  
  // MARK: - 문자열 정규화
  /// 문자열을 정규화 (소문자 변환 + 공백/특수문자 제거)
  private static func normalize(_ s: String) -> String {
    s.lowercased()
      .replacingOccurrences(of: " ", with: "")
      .replacingOccurrences(of: "-", with: "")
      .replacingOccurrences(of: "_", with: "")
  }
  
  // MARK: - 색상 매핑
  /// 문자열 키를 기반으로 팔레트에서 색상 선택
  private static func colorForKey(_ key: String) -> Color {
    let v = key.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
    return palette[abs(v) % palette.count]
  }
  
  // MARK: - 카테고리 → 아이콘 매핑 (원본)
  /// 루틴 카테고리/키워드와 SF Symbol 매핑
  private static let rawCategoryToSymbol: [String: String] = [
    "오메가": "fish.fill", "오메가3": "fish.fill", "omega": "fish.fill", "omega3": "fish.fill",
    "krill": "fish.fill", "크릴": "fish.fill",
    "비타민": "sun.max.fill",
    "종합비타민": "capsule.portrait.fill", "멀티비타민": "capsule.portrait.fill", "multivitamin": "capsule.portrait.fill",
    "vitamin d": "sun.max.fill", "비타민d": "sun.max.fill",
    "루테인": "eye.fill", "lutein": "eye.fill",
    "유산균": "face.smiling", "프로바이오틱스": "face.smiling", "probiotics": "face.smiling",
    "마그네슘": "bolt.fill", "magnesium": "bolt.fill",
    "철분": "drop.fill", "iron": "drop.fill",
    "칼슘": "dumbbell.fill", "calcium": "dumbbell.fill",
    "아연": "shield.lefthalf.filled", "zinc": "shield.lefthalf.filled",
    "밀크씨슬": "leaf.fill", "milk thistle": "leaf.fill", "실리마린": "leaf.fill",
    "홍삼": "leaf.fill", "red ginseng": "leaf.fill",
    "프로틴": "dumbbell.fill", "단백질": "dumbbell.fill", "protein": "dumbbell.fill",
    "약": "cross.case.fill", "의약품": "cross.case.fill"
  ]
  
  // MARK: - 정규화된 카테고리 → 아이콘 매핑
  private static let categoryToSymbol: [String: String] = {
    var dict: [String: String] = [:]
    for (k, v) in rawCategoryToSymbol {
      dict[normalize(k)] = v
    }
    return dict
  }()
  
  // MARK: - 이름 키워드 → 아이콘 매핑
  private static let nameKeywordToSymbol: [(keyword: String, symbol: String)] = [
    ("오메가", "fish.fill"), ("크릴", "fish.fill"),
    ("비타민", "sun.max.fill"),
    ("종합비타민", "capsule.portrait.fill"),
    ("멀티비타민", "capsule.portrait.fill"),
    ("루테인", "eye.fill"),
    ("유산균", "face.smiling"), ("프로바이오틱", "face.smiling"),
    ("마그네슘", "bolt.fill"), ("철분", "drop.fill"),
    ("칼슘", "bone.fill"), ("아연", "shield.lefthalf.filled"),
    ("밀크씨슬", "leaf.fill"), ("홍삼", "leaf.fill"),
    ("프로틴", "dumbbell.fill")
  ]
  
  // MARK: - Public API
  /// 카테고리와 표시 이름을 기반으로 아이콘 심볼과 색상을 반환합니다.
  /// - Parameters:
  ///   - category: 루틴 카테고리 (옵션)
  ///   - displayName: 루틴 표시 이름
  /// - Returns: `(symbol: String, color: Color)` 튜플
  static func style(category: String?, displayName: String) -> (symbol: String, color: Color) {
    // 1. 카테고리 기반 매핑
    if let cat = category?.trimmingCharacters(in: .whitespacesAndNewlines), !cat.isEmpty {
      let ncat = normalize(cat)
      if let symbol = categoryToSymbol[ncat] {
        return (symbol, colorForKey(displayName))
      }
      if let (_, symbol) = categoryToSymbol.first(where: { ncat.contains($0.key) }) {
        return (symbol, colorForKey(displayName))
      }
    }
    
    // 2. 이름 키워드 기반 매핑
    let nameLower = displayName.lowercased()
    if let matched = nameKeywordToSymbol.first(where: { nameLower.contains($0.keyword.lowercased()) }) {
      return (matched.symbol, colorForKey(displayName))
    }
    
    // 3. 기본값: 캡슐 아이콘
    return ("capsule.portrait.fill", colorForKey(displayName))
  }
}
