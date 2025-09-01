//
//  TimePickerSheet.swift
//  Meditory
//
//  Created by 홍승아 on 8/26/25.
//

import SwiftUI

/// 복용 시간과 1회 섭취량을 선택하는 Picker Sheet.
struct TimePickerSheet: View {
  
  private let isPad = UIDevice.isPad
  
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
      let imageWidth: CGFloat = isPad ? 33 : 23
      let iconSize: CGFloat = .defaultFontSize - 2
      let textSize: CGFloat = .defaultFontSize + 2
      
      Button {
        doseSchedule.pillsPerDose = max(1, doseSchedule.pillsPerDose - 1)
      } label: {
        Circle()
          .frame(width: imageWidth, height: imageWidth)
          .foregroundStyle(.main)
          .overlay {
            Image(systemName: "minus")
              .font(.system(size: iconSize, weight: .semibold))
              .foregroundStyle(.white)
          }
      }
      
      Spacer()
      
      Text("\(doseSchedule.pillsPerDose)")
        .font(.notoSans(weight: .regular, size: textSize))
        .padding(.bottom, 3)
      
      Spacer()
      
      Button {
        doseSchedule.pillsPerDose += 1
      } label: {
        Circle()
          .frame(width: imageWidth, height: imageWidth)
          .foregroundStyle(.main)
          .overlay {
            Image(systemName: "plus")
              .font(.system(size: iconSize, weight: .semibold))
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
          .font(.notoSans(size: isPad ? 20 : 16))
          .padding(.bottom, .smallSpacing)
        
        doseSection
          .padding(.bottom, .defaultSpacing)
      }
    }
  }
}
