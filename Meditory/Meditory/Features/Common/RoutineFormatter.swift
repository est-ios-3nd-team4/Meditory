enum RoutineFormatter {
  static func renderCycle(cycleType: Int, cycleValue: String) -> String {
    switch cycleType {
    case 1:
      // 월=0, 화=1, 수=2, 목=3, 금=4, 토=5, 일=6
      let map = ["월","화","수","목","금","토","일"]
      let days = cycleValue
        .split(whereSeparator: { ", ".contains($0) })
        .compactMap { Int($0) }
        .compactMap { (0...6).contains($0) ? map[$0] : nil }

      if days.count == 7 { return "매일" }
      return days.isEmpty ? "설정 없음" : days.joined(separator: "·")

    case 2:
      if let intervalDays = Int(cycleValue.trimmingCharacters(in: .whitespacesAndNewlines)) {
        return "\(intervalDays)일 간격"
      }
      return "주기별"

    default:
      return "설정 없음"
    }
  }
}