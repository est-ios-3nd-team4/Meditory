//
//  ScheduleDisplayRow.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//
import SwiftUI

struct ScheduleDisplayRow: View {
  let icon: String
  let text: String

  var body: some View {
    HStack(spacing: .smallSpacing) {
      Image(systemName: icon)
        .imageScale(.medium)

      Text(text)
        .font(.notoSans(weight: .medium, size: 15))
        .foregroundStyle(.secondary)

      Spacer(minLength: 0)
    }
    .padding(.vertical, .smallSpacing)
  }
}
#Preview {
  ScheduleDisplayRow(icon: "checkmark", text: "check")
}
