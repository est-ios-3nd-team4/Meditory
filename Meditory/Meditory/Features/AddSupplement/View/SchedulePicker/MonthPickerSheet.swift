//
//  MonthPicker.swift
//  Meditory
//
//  Created by 홍승아 on 8/28/25.
//

import SwiftUI

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
            .font(.notoSans(size: 25))
        }
      }
      .pickerStyle(.wheel)
      .frame(height: 216)
    }
  }
}
