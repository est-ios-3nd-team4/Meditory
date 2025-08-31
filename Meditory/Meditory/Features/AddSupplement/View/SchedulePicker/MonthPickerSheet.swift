//
//  MonthPicker.swift
//  Meditory
//
//  Created by 홍승아 on 8/28/25.
//

import SwiftUI

/// 특정 달의 월(month)을 선택하는 Picker Sheet.
struct MonthPickerSheet: View {
  
  @State var selectedMonth: Int
  var onDismiss: (Int?) -> Void
  
  var body: some View {
    SchedulePickerSheet(
      title: SchedulePickerType.month.title
    ) { didConfirm in
      onDismiss(didConfirm ? selectedMonth : nil)
    } content: {
      Picker("Month", selection: $selectedMonth) {
        ForEach(1...12, id: \.self) { month in
          Text("\(month)")
            .font(.notoSans(size: UIDevice.isPad ? 27 : 25))
        }
      }
      .pickerStyle(.wheel)
      .frame(height: 216)
    }
  }
}
