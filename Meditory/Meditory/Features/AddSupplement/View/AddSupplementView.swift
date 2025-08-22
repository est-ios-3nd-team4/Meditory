//
//  AddSupplementView.swift
//  Meditory
//
//  Created by 홍승아 on 8/5/25.
//

import SwiftUI
import SwiftData

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
  @Environment(\.userStore) private var userStore

  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme
  
  @Binding private var selectedIntakeItem: AddIntakeItem?
  
  @State private var selectedScheduleType: SupplementScheduleType = .weekday
  @StateObject private var addSupplementVM = AddSupplementViewModel()
  @StateObject private var scheduleVM = SupplementScheduleViewModel()
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
  @State private var isSearchingSupplementSummary = false
  @State private var supplement: SupplementDTO?
  @State private var showAlert = false
  @State private var routineSaveError: RoutineSaveError?
  
  
  @Query private var users: [User] // User 정보를 가져오기 위해 @Query 추가
  @State private var lifestyleTimeVM: LifestyleTimeViewModel // StateObject 대신 State 사용

  
  private var shouldShowSupplementInfo: Bool {
    addSupplementVM.supplemtSummary != nil || isSearchingSupplementSummary
  }
  private let defaultFontSize: CGFloat = 18
  
  init(
    type: Mode = .add,
//    context: ModelContext,
    selectedIntakeItem: Binding<AddIntakeItem?> = .constant(nil)
  ) {
    self.type = type
    self._selectedIntakeItem = selectedIntakeItem
    
    self._lifestyleTimeVM = State(initialValue: LifestyleTimeViewModel(lifestyleStore: UserLifeStyleStore.shared))
    
//    let lifestyleTimeVM = LifestyleTimeViewModel(context: context)
//    self.lifestyleTimeVM = lifestyleTimeVM
//    self.lifestyle = lifestyleTimeVM.userlifeStyle
    
    
  }

  var body: some View {
    GeometryReader { scrollView in
      ZStack {
        ScrollViewReader { proxy in
          ScrollView {
            VStack(spacing: 20) {
              supplementNameInput()
              
              if shouldShowSupplementInfo {
                SupplementInfoView(
                  defaultFontSize: defaultFontSize,
                  addSupplementVM: addSupplementVM,
                  isSearchingSupplementSummary: $isSearchingSupplementSummary
                )
              }
              
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
              
              AIRecommendedScheduleView(
                defaultFontSize: defaultFontSize,
                context: context,
                userStore: userStore,
                supplementSummary: addSupplementVM.supplemtSummary,
                lifestyle: lifestyleTimeVM.userlifeStyle,
                supplement: $supplement
              )
              
              memoSection()
              
              // 컴파일러가 뷰가 너무많다고 뻗어버려서 그룹으로 감싸서 해결했습니다.
              Group {
                Spacer()
                
                Button {
                  saveRoutine()
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
                .padding(.bottom, .bottomInset)
              }
            }
            .padding(.horizontal, .defaultSpacing + 4)
            .navigationTitle("복용약 추가")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
              ToolbarItem(placement: .navigationBarLeading) {
                Button {
                  dismissOrClearSelection()
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
//              lifestyle = lifestyleTimeVM.userlifeStyle
            }
            showTimePicker = false
          }
        }
      }
      .background(
        colorScheme == .dark
        ? Color.white.opacity(0.3)
        : Color.white
      )
      .fullScreenCover(isPresented: $showScanner) {
        CameraPickerSheet(isPresented: $showScanner) { text in
          searchSupplementSummary(
            productNameInput: text,
            nameSource: .cameraOCR
          )
        }
        .statusBarHidden(true)
        .ignoresSafeArea()
      }
      .overlay {
        if showAlert, let routineSaveError {
          AlertView(
            alertType: .confirm,
            title: routineSaveError.title,
            message: routineSaveError.message,
            onConfirm: {
              showAlert = false
            }
          )
        }
      }
      .onAppear {
        // 1. @Query로 가져온 users 배열에서 첫 번째 사용자를 가져옵니다.
        guard let user = users.first else { return }

        // 2. Task를 사용해 비동기 함수들을 호출합니다.
        Task {
            // lifestyleTimeVM의 새로운 비동기 로딩 함수를 호출합니다.
            await lifestyleTimeVM.loadLifestyle(for: user, context: context)
            addSupplementVM.updateContext(context)
        }
      }
    }
  }
}


extension AddSupplementView {
  private func dismissOrClearSelection() {
    if selectedIntakeItem != nil {
      selectedIntakeItem = nil
      
      NotificationCenter.default.post(
        name: .didUpdateSupplement,
        object: nil
      )
    } else {
      dismiss()
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


// MARK: - Network
extension AddSupplementView {
  private func searchSupplementSummary(productNameInput: String, nameSource: SupplementNameSource) {
    guard !isSearchingSupplementSummary else { return }
    
    Task {
      do {
        try await addSupplementVM.request(
          productNameInput: productNameInput,
          nameSource: nameSource
        )
      } catch {
        print("❌ Error is \(error)")
      }
    }
    
    isSearchingSupplementSummary = true
    supplementName = ""
  }
}


// MARK: - DB
extension AddSupplementView {
  private func saveRoutine() {
    Task {
      do {
        try await addSupplementVM.saveRoutine(
          type: selectedScheduleType,
          supplement: supplement,
          memo: memo
        )
        
        await MainActor.run {
          dismissOrClearSelection()
        }
      } catch let error as RoutineSaveError {
        routineSaveError = error
        showAlert = true
        print("❌ \(error)")
      } catch {
        print("❌ Error is \(error)")
      }
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
          
          searchSupplementSummary(
            productNameInput: supplementName,
            nameSource: .manual
          )
        }
      )
      
      if !supplementName.isEmpty {
        Button {
          searchSupplementSummary(
            productNameInput: supplementName,
            nameSource: .manual
          )
        } label: {
          Image(systemName: "magnifyingglass")
            .foregroundColor(.gray)
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
