//
//  WeekdayPickerSheet.swift
//  Meditory
//
//  Created by 홍승아 on 8/26/25.
//

import SwiftUI

struct WeekdayPickerSheet: View {
  
  @State var weekdays: [Weekday: Bool]
  var onDismiss: ([Weekday: Bool]?) -> Void
  
  var body: some View {
    SchedulePickerSheet(
      title: SchedulePickerType.weekday.title
    ) { didConfirm in
      onDismiss(didConfirm ? weekdays : nil)
    } content: {
      VStack(alignment: .leading, spacing: .defaultSpacing) {
        ForEach(Weekday.allCases, id:\.self) { weekday in
          HStack {
            Text(weekday.title)
              .font(.notoSans(size: 18))
            
            Spacer()
            
            CircleCheck(
              isCompleted: weekdays[weekday] ?? false,
              size: 25
            )
          }
          .padding(.horizontal, 2)
          .contentShape(Rectangle())
          .onTapGesture {
            weekdays[weekday]?.toggle()
          }
        }
      }
      .padding(.horizontal, .smallSpacing)
      .padding(.vertical, .defaultSpacing)
    }
  }
}
