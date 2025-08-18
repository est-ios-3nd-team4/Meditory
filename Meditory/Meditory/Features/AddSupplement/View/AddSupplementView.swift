//
//  AddSupplementView.swift
//  Meditory
//
//  Created by 홍승아 on 8/5/25.
//

import SwiftUI

struct AddSupplementView: View {
  
  enum Mode {
    case add
    case edit
  }
  
  enum FieldType {
    case name
    case memo
  }
  
  var type: Mode = .add
  
  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme
  
  @State private var selectedScheduleType: SupplementScheduleType = .weekday
  @StateObject private var addSupplementVM = AddSupplementViewModel()
  @StateObject private var scheduleVM = SupplementScheduleViewModel()
  @State private var lifestyleTimeVM = LifestyleTimeViewModel()
  @State private var selectedPicker: SchedulePickerType? {
    didSet {
      showSchedulePicker()
    }
  }
  @State private var supplementName = ""
  @State private var memo = ""
  @State private var fieldType: FieldType? = nil
  @State private var selectedTimeIndex = 0
  @State private var showScanner = false
  @State private var scheduleTypeRectPosition: CGPoint = .zero
  @State private var showTimePicker = false
  @State private var selectedLifestyleCategory: LifestyleTimeType? = nil
  @State private var selectedLifestyleOption: (any LifestyleTime)?
  
  private let defaultFontSize: CGFloat = 18
  
  var body: some View {
    GeometryReader { scrollView in
      ZStack {
        ScrollViewReader { proxy in
          ScrollView {
            VStack(spacing: 20) {
              supplementNameInput()
              
              LifestyleTimeView(
                type: .dailyCycle,
                defaultFontSize: defaultFontSize,
                lifestyleTimeVM: lifestyleTimeVM,
              ) { option in
                selectedLifestyleCategory = .dailyCycle
                selectedLifestyleOption = option
                showTimePicker = true
              }
              
              LifestyleTimeView(
                type: .meal,
                defaultFontSize: defaultFontSize,
                lifestyleTimeVM: lifestyleTimeVM
              ) { option in
                selectedLifestyleCategory = .meal
                selectedLifestyleOption = option
                showTimePicker = true
              }
              
              scheduleTypeSelector()
              
              VStack {
                switch selectedScheduleType {
                case .weekday:
                  weekdayScheduleView()
                case .interval:
                  intervalScheduleView()
                }
                supplementCountSelector()
              }
              .modifier(CardStyle(padding: .defaultSpacing))
              
              timeSelectionSection()
              
              AIRecommendedScheduleView(defaultFontSize: defaultFontSize)
              
              memoSection()
              
              Spacer()
              
              Button {
                dismiss()
              } label: {
                RoundedRectangle(cornerRadius: 10)
                  .fill(.main)
                  .frame(height: 50)
                  .overlay {
                    Text("완료")
                      .font(.notoSans(weight: .semiBold, size: defaultFontSize))
                      .foregroundStyle(.white)
                  }
              }
              .id("confirmButton")
              .padding(.bottom, fieldType == .memo ? 20 : 0)
            }
            .padding(.horizontal, .defaultSpacing + 4)
            .navigationTitle("복용약 추가")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
              ToolbarItem(placement: .navigationBarLeading) {
                Button {
                  dismiss()
                } label: {
                  Image(systemName: "chevron.left")
                    .foregroundStyle(Color.label)
                }
              }
            }
          }
          .scrollIndicators(.hidden)
          .onChange(of: fieldType) { oldValue, newValue in
            switch fieldType {
            case .memo:
              let keyboardAnimationDuration = 0.3
              
              Task { @MainActor in
                do {
                  try await Task.sleep(for: .seconds(keyboardAnimationDuration))
                  withAnimation {
                    proxy.scrollTo("confirmButton", anchor: .bottom)
                  }
                } catch {
                  print("❌ Error is \(error)")
                }
              }
              
            default:
              break
            }
          }
          .onAppear {
            addSupplementVM.updateContext(context)
          }
        }
        
        if let category = selectedLifestyleCategory,
           let option = selectedLifestyleOption,
            showTimePicker {
          LifestyleTimePickerSheet(
            type: category,
            option: option,
            dates: lifestyleTimeVM.times(for: category),
            mealSelections: lifestyleTimeVM.mealSelections(for: category)
          ) { result in
            if let result {
              lifestyleTimeVM.setTime(result)
            }
            showTimePicker = false
          }
        }
      }
      .fullScreenCover(isPresented: $showScanner) {
        CameraPickerSheet(isPresented: $showScanner) { text in
          print(text)
        }
        .statusBarHidden(true)
        .ignoresSafeArea()
      }
    }
  }
}


// MARK: - Colors
extension AddSupplementView {
  func backgroundColor(for type: SupplementScheduleType) -> Color {
    type == selectedScheduleType ? .main : .clear
  }
  
  func textColor(for type: SupplementScheduleType) -> Color {
    type == selectedScheduleType ? .white : .textGray
  }
  
  func rectPosition(for type: SupplementScheduleType, width: CGFloat) -> CGFloat {
    switch type {
    case .weekday:
      return width * 0.25
    case .interval:
      return width * 0.75
    }
  }
}


// MARK: - Subviews
extension AddSupplementView {
  private func supplementNameInput() -> some View {
    HStack(spacing: 8) {
      if supplementName.isEmpty {
        Button {
          showScanner = true
        } label: {
          Circle()
            .frame(width: 25, height: 25)
            .foregroundStyle(.main)
            .overlay {
              Image(systemName: "camera.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundStyle(.white)
            }
        }
      }
      
      InputTextField(
        text: $supplementName,
        placeHolder: "사진 촬영 및 텍스트로 검색",
        didBeginEditing: {
          fieldType = .name
        },
        shouldReturn: {
          fieldType = nil
        }
      )
      
      if !supplementName.isEmpty {
        Button {
          print("검색")
        } label: {
          Image(systemName: "magnifyingglass")
            .foregroundColor(.gray)
            .padding(.trailing, 24)
        }
      }
    }
    .cardStyle(padding: .defaultSpacing)
    .frame(height: 55)
    .padding(.top, .defaultSpacing)
  }
  
  private func scheduleTypeSelector() -> some View {
    GeometryReader { geometry in
      ZStack {
        let buttonSize = CGSize(
          width: (geometry.size.width / 2) - 6,
          height: geometry.size.height - 6
        )
        RoundedRectangle(cornerRadius: 10)
          .fill(.main)
          .frame(width: buttonSize.width, height: buttonSize.height)
          .position(
            x: scheduleTypeRectPosition.x,
            y: scheduleTypeRectPosition.y
          )
          .onAppear {
            scheduleTypeRectPosition.x = geometry.size.width * 0.25
            scheduleTypeRectPosition.y = geometry.size.height / 2
          }
        
        HStack {
          ForEach(SupplementScheduleType.allCases, id: \.self) { type in
            Text(type.title)
              .font(.notoSans(size: 15))
              .foregroundStyle(textColor(for: type))
              .frame(width: buttonSize.width, height: buttonSize.height)
              .contentShape(Rectangle())
              .onTapGesture {
                withAnimation(.easeInOut) {
                  scheduleTypeRectPosition.x = rectPosition(for: type, width: geometry.size.width)
                }
                
                if selectedScheduleType != type {
                  selectedScheduleType = type
                }
              }
          }
        }
      }
      .cardStyle(cornerRadius: 10)
    }
    .frame(height: 40)
  }
  
  private func weekdayScheduleView() -> some View {
    HStack {
      Text("복용 요일")
        .font(.notoSans(size: defaultFontSize))
      
      Spacer()
      
      Button {
        selectedPicker = .weekday
      } label: {
        Text(addSupplementVM.weekdaysString)
          .font(.notoSans(size: defaultFontSize))
          .padding(.bottom, 2)
      }
      .foregroundStyle(.textGray)
    }
  }
  
  private func intervalScheduleView() -> some View {
    VStack {
      HStack(spacing: 8) {
        Text("시작 날짜")
          .font(.notoSans(size: defaultFontSize))
        
        Spacer()
        
        Button {
          selectedPicker = .month
        } label: {
          RoundedRectangle(cornerRadius: 10)
            .fill(.backgroundGray)
            .frame(width: 48, height: 36)
            .overlay {
              Text("\(addSupplementVM.startMonth)")
                .font(.notoSans(size: defaultFontSize))
                .foregroundStyle(.textGray)
            }
        }
        
        Text("월")
          .font(.notoSans(weight: .regular, size: defaultFontSize))
          .padding(.trailing, 8)
        
        Button {
          selectedPicker = .day
        } label: {
          RoundedRectangle(cornerRadius: 10)
            .fill(.backgroundGray)
            .frame(width: 48, height: 36)
            .overlay {
              Text("\(addSupplementVM.startDay)")
                .font(.notoSans(size: defaultFontSize))
                .foregroundStyle(.textGray)
            }
        }
        
        Text("일")
          .font(.notoSans(weight: .regular, size: defaultFontSize))
      }
      
      HStack(spacing: 8) {
        Text("복용 주기")
          .font(.notoSans(size: defaultFontSize))
        
        Spacer()
        
        Button {
          selectedPicker = .duration
        } label: {
          RoundedRectangle(cornerRadius: 10)
            .fill(.backgroundGray)
            .frame(width: 48, height: 36)
            .overlay {
              Text("\(addSupplementVM.duration)")
                .font(.notoSans(size: defaultFontSize))
                .foregroundStyle(.textGray)
            }
        }
        
        Text("일")
          .font(.notoSans(weight: .regular, size: defaultFontSize))
      }
    }
  }
  
  private func supplementCountSelector() -> some View {
    HStack {
      Text("섭취 횟수")
        .font(.notoSans(size: defaultFontSize))
      
      Spacer()
      
      HStack(spacing: 25) {
        Button {
          addSupplementVM.removeRoutineTime()
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
        
        Text("\(addSupplementVM.doseSchedules.count)")
          .font(.notoSans(size: defaultFontSize))
          .padding(.bottom, 3)
        
        Button {
          addSupplementVM.addRoutineTime()
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
  }
  
  private func timeSelectionSection() -> some View {
    VStack(alignment: .leading){
      Text("복용 시간")
        .font(.notoSans(size: defaultFontSize))
      
      ForEach(addSupplementVM.doseSchedules.indices, id: \.self) { index in
        let routine = addSupplementVM.doseSchedules[index]
        
        HStack(spacing: .defaultSpacing) {
          ZStack {
            Circle()
              .fill(.main)
              .frame(width: 18, height: 18)
            
            Text("\(index + 1)")
              .font(.notoSans(weight: .bold, size: 10))
              .foregroundStyle(.white)
              .padding(.bottom, 1)
          }
          
          Text(routine.time.timeFormatter)
            .font(.notoSans(weight: .regular, size: defaultFontSize))
            .padding(.bottom, 2)
          
          Spacer()
          
          Text(routine.doseString)
            .font(.notoSans(weight: .regular, size: defaultFontSize))
            .foregroundStyle(.textGray)
            .padding(.bottom, 2)
        }
        .onTapGesture {
          selectedTimeIndex = index
          scheduleVM.time = routine.time
          selectedPicker = .time
        }
      }
    }
    .cardStyle(padding: .defaultSpacing)
  }
  
  private func memoSection() -> some View {
    VStack(alignment: .leading) {
      Text("메모")
        .font(.notoSans(size: defaultFontSize))
      
      InputTextField(
        text: $memo,
        placeHolder: "ex) 따듯한 물과 함께 먹기",
        didBeginEditing: {
          fieldType = .memo
        },
        shouldReturn: {
          fieldType = nil
        }
      )
      .padding(.horizontal, 4)
    }
    .cardStyle(padding: .defaultSpacing)
    .frame(height: 95)
  }
  
  func showSchedulePicker() {
    guard let selectedPicker else { return }
    let vc = SchedulePickerViewController(type: selectedPicker, scheduleVM: scheduleVM)
    vc.modalPresentationStyle = .overFullScreen
    vc.onDismiss = {
      switch selectedPicker {
      case .month:
        addSupplementVM.setValue(.month(scheduleVM.month))
      case .day:
        addSupplementVM.setValue(.day(scheduleVM.day))
      case .duration:
        addSupplementVM.setValue(.duration(scheduleVM.duration))
      case .weekday:
        addSupplementVM.setValue(.weekday(scheduleVM.days))
      case .time:
        addSupplementVM.setValue(.time(scheduleVM.time, scheduleVM.pillsPerDose), index: selectedTimeIndex)
      }
    }
    
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootVC = windowScene.windows.first?.rootViewController {
      rootVC.present(vc, animated: false)
    }
  }
}

#Preview {
  AddSupplementView()
}
