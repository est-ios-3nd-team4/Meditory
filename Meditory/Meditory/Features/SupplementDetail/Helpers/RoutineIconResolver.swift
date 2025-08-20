//
//  RoutineIconResolver.swift
//  Meditory
//
//  Created by 윤혜주 on 8/19/25.
//


import SwiftUI

struct RoutineIconResolver {
  private static let palette: [Color] = [.blue, .teal, .indigo, .orange, .purple, .green]

  private static func normalize(_ s: String) -> String {
    s.lowercased()
      .replacingOccurrences(of: " ", with: "")
      .replacingOccurrences(of: "-", with: "")
      .replacingOccurrences(of: "_", with: "")
  }

  private static func colorForKey(_ key: String) -> Color {
    let v = key.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
    return palette[abs(v) % palette.count]
  }

  private static let rawCategoryToSymbol: [String: String] = [
    "오메가": "fish.fill",
    "오메가3": "fish.fill",
    "omega": "fish.fill",
    "omega3": "fish.fill",
    "krill": "fish.fill",
    "크릴": "fish.fill",
    "비타민": "sun.max.fill",
    "종합비타민": "capsule.portrait.fill",
    "멀티비타민": "capsule.portrait.fill",
    "multivitamin": "capsule.portrait.fill",
    "vitamin d": "sun.max.fill",
    "비타민d": "sun.max.fill",
    "루테인": "eye.fill",
    "lutein": "eye.fill",
    "유산균": "face.smiling",
    "프로바이오틱스": "face.smiling", "probiotics": "face.smiling",
    "마그네슘": "bolt.fill",
    "magnesium": "bolt.fill",
    "철분": "drop.fill",
    "iron": "drop.fill",
    "칼슘": "bone.fill",
    "calcium": "bone.fill",
    "아연": "shield.lefthalf.filled",
    "zinc": "shield.lefthalf.filled",
    "밀크씨슬": "leaf.fill",
    "milk thistle": "leaf.fill",
    "실리마린": "leaf.fill",
    "홍삼": "leaf.fill",
    "red ginseng": "leaf.fill",
    "프로틴": "dumbbell.fill",
    "단백질": "dumbbell.fill",
    "protein": "dumbbell.fill",
    "약": "cross.case.fill",
    "의약품": "cross.case.fill"
  ]

  private static let categoryToSymbol: [String: String] = {
    var dict: [String: String] = [:]
    for (k, v) in rawCategoryToSymbol {
      dict[normalize(k)] = v
    }
    return dict
  }()

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

  static func style(category: String?, displayName: String) -> (symbol: String, color: Color) {
    if let cat = category?.trimmingCharacters(in: .whitespacesAndNewlines), !cat.isEmpty {
      let ncat = normalize(cat)
      if let symbol = categoryToSymbol[ncat] {
        return (symbol, colorForKey(displayName))
      }
      if let (_, symbol) = categoryToSymbol.first(where: { ncat.contains($0.key) }) {
        return (symbol, colorForKey(displayName))
      }
    }

    let nameLower = displayName.lowercased()
    if let matched = nameKeywordToSymbol.first(where: { nameLower.contains($0.keyword.lowercased()) }) {
      return (matched.symbol, colorForKey(displayName))
    }

    return ("capsule.portrait.fill", colorForKey(displayName))
  }
}
