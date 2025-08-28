//
//  TimePickerSheet.swift
//  Meditory
//
//  Created by 홍승아 on 8/26/25.
//

import SwiftUI

struct TimePickerSheet: View {
  
  @State var doseSchedule: SupplementDoseSchedule
  let selectedIndex: Int
  let doseSchedules: [SupplementDoseSchedule]
  var onDismiss: ((SupplementDoseSchedule?)) -> Void
  
  @State private var showAlert: Bool = false
  private var isUniqueTime: Bool {
    !doseSchedules.enumerated().contains { index, item in
      item.time == doseSchedule.time && index != selectedIndex
    }
  }
    
  init(
    selectedIndex: Int,
    doseSchedules: [SupplementDoseSchedule],
    onDismiss: @escaping ((SupplementDoseSchedule?)) -> Void
  ){
    self._doseSchedule = State(initialValue: doseSchedules[selectedIndex])
    self.selectedIndex = selectedIndex
    self.doseSchedules = doseSchedules
    self.onDismiss = onDismiss
  }
  
  private var doseSection: some View {
    HStack {
      Button {
        doseSchedule.pillsPerDose = max(1, doseSchedule.pillsPerDose - 1)
      } label: {
        Circle()
          .frame(width: 23, height: 23)
          .foregroundStyle(.main)
          .overlay {
            Image(systemName: "minus")
              .font(.system(size: 16, weight: .semibold))
              .foregroundStyle(.white)
          }
      }
      
      Spacer()
      
      Text("\(doseSchedule.pillsPerDose)")
        .font(.notoSans(weight: .regular, size: 20))
        .padding(.bottom, 3)
      
      Spacer()
      
      Button {
        doseSchedule.pillsPerDose += 1
      } label: {
        Circle()
          .frame(width: 23, height: 23)
          .foregroundStyle(.main)
          .overlay {
            Image(systemName: "plus")
              .font(.system(size: 14, weight: .semibold))
              .foregroundStyle(.white)
          }
      }
    }
  }
  
  private var alert: AlertView {
    AlertView(
      alertType: .confirm,
      title: "중복된 복용 시간",
      message: "동일한 시간에 이미 복용 스케줄이 설정되어 있습니다.\n다른 시간을 선택해주세요.",
      onConfirm: {
        showAlert = false
      }
    )
  }
  
  var body: some View {
    SchedulePickerSheet(
      title: SchedulePickerType.time.title,
      needsAlert: !isUniqueTime,
      showAlert: $showAlert,
      alert: alert,
    ) { didConfirm in
      onDismiss(didConfirm ? doseSchedule : nil)
    } content: {
      VStack(alignment: .leading) {
        FullWidthDatePicker(
          selection: $doseSchedule.time
        )
        .frame(height: 216)
        
        Text("섭취 량")
          .font(.notoSans(weight: .medium, size: 16))
          .padding(.bottom, .smallSpacing)
        
        doseSection
          .padding(.bottom, .defaultSpacing)
      }
    }
  }
}
