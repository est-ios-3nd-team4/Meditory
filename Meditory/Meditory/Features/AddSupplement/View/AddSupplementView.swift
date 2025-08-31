//
//  AddSupplementView.swift
//  Meditory
//
//  Created by 홍승아 on 8/5/25.
//

import SwiftUI
import SwiftData

/// 영양제 추가/수정 화면 뷰.
///
/// 사용자가 영양제 이름을 입력하거나 스캔한 뒤,
/// 생활 패턴(기상·취침/식사 시간)을 기반으로 복용 스케줄을 선택·저장할 수 있다.
///
/// 주요 기능:
/// - 영양제 이름 입력 및 OCR 스캔
/// - 영양제 정보 조회
/// - 생활 패턴(Lifestyle) 입력
/// - 요일/주기/시간 기반 스케줄 선택
/// - AI 추천 스케줄 생성
/// - 루틴 저장 및 수정
struct AddSupplementView: View {
  
  /// AddSupplementView 동작 모드
  enum Mode {
    case add
    case edit
  }
  
  /// 입력 필드 타입
  enum FieldType {
    case name
    case memo
  }
  
  /// ScrollView에서 특정 뷰를 찾기 위한 ID
  enum ViewID: String {
    case confirmButton
  }
  
  // Properties
  var type: Mode
  @Binding private var selectedIntakeItem: AddIntakeItem?
  
  // Environment
  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme
  private let isPad = UIDevice.isPad
  
  // Query
  @Query private var users: [User]
  
  // ViewModels
  @State private var addSupplementVM = AddSupplementViewModel()
  @State private var lifestyleTimeVM: LifestyleTimeViewModel
  
  // Schedule
  @State private var selectedScheduleType: SupplementScheduleType = .weekday
  @State private var selectedPicker: SchedulePickerType?
  @State private var selectedTimeIndex = 0
  @State private var scheduleTypeRectPosition: CGPoint = .zero
  
  // Input
  @State private var supplementName = ""
  @State private var fieldType: FieldType? = nil
  
  // Lifestyle
  @State private var selectedLifestyleCategory: LifestyleTimeType? = nil
  @State private var selectedLifestyleOption: (any LifestyleTime)?
  
  // Supplement
  @State private var alanAPIError: AlanAPIError?
  @State private var routineSaveError: RoutineSaveError?
  private var shouldShowSupplementInfo: Bool {
    addSupplementVM.supplemtSummary != nil || isSearchingSupplementSummary
  }
  
  // Scroll / Navigation
  @State private var isAtTop: Bool = true
  
  // UI Toggles
  @State private var showScanner = false
  @State private var showTimePicker = false
  @State private var isSearchingSupplementSummary = false
  @State private var showAlert = false
  @State private var isSaving = false
  
  // Edit 시 사용하는 루틴
  private let editingRoutine: Routine?
  
  // Task
  @State private var searchTask: Task<Void, Never>? = nil
  
  init(
    type: Mode = .add,
    routine: Routine? = nil,
    selectedIntakeItem: Binding<AddIntakeItem?> = .constant(nil)
  ) {
    self.type = type
    self._selectedIntakeItem = selectedIntakeItem
    self._addSupplementVM = State(initialValue: AddSupplementViewModel(routine: routine))
    self._lifestyleTimeVM = State(initialValue: LifestyleTimeViewModel(lifestyleStore: UserLifeStyleStore.shared))
    self.editingRoutine = routine
  }
  
  var body: some View {
    GeometryReader { scrollView in
      let isLandscape = scrollView.frame(in: .global).width > scrollView.frame(in: .global).height
      
      ZStack {
        ScrollViewReader { proxy in
          ScrollView {
            ScrollTopObserver(isAtTop: $isAtTop)
            if let user = users.first {
              mainContentView(for: user)
            } else {
              ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
          }
          .scrollDismissesKeyboard(.immediately)
          .scrollIndicators(.hidden)
          .frame(maxWidth: isLandscape ? scrollView.size.width * 0.7 : .infinity)
          .navigationBar(
            type == .add ? .addSupplement : .editSupplement,
            isAtTop: isAtTop
          ) {
            dismissOrClearSelection()
          }
          .onChange(of: fieldType) { oldValue, newValue in
            handleKeyboardScroll(for: newValue, with: proxy)
          }
        }
        
        lifestyleTimePickerSheet()
        schedulePickerSheet()
      }
      .background(.customBackground)
      .fullScreenCover(isPresented: $showScanner) {
        cameraPickerSheet()
      }
      .overlay {
        saveErrorAlert()
        requestSupplemntAlert()
        defaultAlert()
      }
      .onDisappear {
        searchTask?.cancel()
        searchTask = nil
      }
      .task {
        guard let user = users.first else { return }
        await lifestyleTimeVM.loadLifestyle(for: user, context: context)
      }
    }
  }
}

// MARK: - Main Content and Subviews
extension AddSupplementView {
  private func mainContentView(for user: User) -> some View {
    VStack(spacing: isPad ? 30 : 20) {
      supplementNameInput()
      
      supplementInfoSection()
      
      lifestyleSection()
      
      scheduleTypeSelector()
      
      scheduleDetailsSection()
      
      timeSelectionSection()
      
      aiRecommendationSection()
      
      memoSection()
      
      ConfirmButton {
        saveRoutine()
      }
      .id(ViewID.confirmButton)
      .padding(.bottom, .bottomInset)
    }
    .padding(.horizontal, .defaultSpacing)
    .dismissKeyboardOnTap()
  }
  
  private func supplementNameInput() -> some View {
    HStack(spacing: .smallSpacing) {
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
  }
  
  @ViewBuilder
  private func supplementInfoSection() -> some View {
    if shouldShowSupplementInfo {
      SupplementInfoView(
        addSupplementVM: addSupplementVM,
        isSearchingSupplementSummary: $isSearchingSupplementSummary
      )
    }
  }
  
  private func lifestyleSection() -> some View {
    Group {
      LifestyleTimeView(
        type: .dailyCycle,
        lifestyleTimeItems: lifestyleTimeVM.lifestyleTimeItems(for: .dailyCycle),
        onTapGesture: { option in
          selectedLifestyleCategory = .dailyCycle
          selectedLifestyleOption = option
          showTimePicker = true
        }
      )
      
      LifestyleTimeView(
        type: .meal,
        lifestyleTimeItems: lifestyleTimeVM.lifestyleTimeItems(for: .meal),
        onTapGesture: { option in
          selectedLifestyleCategory = .meal
          selectedLifestyleOption = option
          showTimePicker = true
        }
      )
    }
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
            scheduleTypeRectPosition.x = rectPosition(
              for: addSupplementVM.selectedScheduleType,
              width: geometry.size.width
            )
            scheduleTypeRectPosition.y = geometry.size.height / 2
          }
        
        HStack {
          ForEach(SupplementScheduleType.allCases, id: \.self) { type in
            Text(type.title)
              .font(.notoSans(size: .defaultFontSize - 3))
              .foregroundStyle(textColor(for: type))
              .frame(width: buttonSize.width, height: buttonSize.height)
              .contentShape(Rectangle())
              .onTapGesture {
                withAnimation(.easeInOut) {
                  scheduleTypeRectPosition.x = rectPosition(for: type, width: geometry.size.width)
                }
                
                if addSupplementVM.selectedScheduleType != type {
                  addSupplementVM.selectedScheduleType = type
                }
              }
          }
        }
      }
      .cardStyle(cornerRadius: 10)
    }
    .frame(height: isPad ? 50 : 40)
  }
  
  private func scheduleDetailsSection() -> some View {
    VStack {
      switch addSupplementVM.selectedScheduleType {
      case .weekday:
        weekdayScheduleView()
      case .interval:
        intervalScheduleView()
      }
      
      supplementCountSelector()
    }
    .modifier(CardStyle(padding: .defaultSpacing))
  }
  
  private func weekdayScheduleView() -> some View {
    HStack {
      Text("복용 요일")
        .font(.notoSans(size: .defaultFontSize))
      
      Spacer()
      
      Text(addSupplementVM.weekdaysString)
        .font(.notoSans(size: .defaultFontSize))
        .padding(.bottom, 2)
        .foregroundStyle(.textGray)
    }
    .contentShape(Rectangle())
    .onTapGesture {
      selectedPicker = .weekday
    }
  }
  
  private func intervalScheduleView() -> some View {
    VStack {
      let rectangleSize = CGSize(
        width: .defaultFontSize + 30,
        height: .defaultFontSize + 18
      )
      
      HStack(spacing: .smallSpacing) {
        Text("시작 날짜")
          .font(.notoSans(size: .defaultFontSize))
        
        Spacer()
        
        Button {
          selectedPicker = .month
        } label: {
          RoundedRectangle(cornerRadius: 10)
            .fill(.backgroundGray)
            .frame(width: rectangleSize.width, height: rectangleSize.height)
            .overlay {
              Text("\(addSupplementVM.startMonth)")
                .font(.notoSans(size: .defaultFontSize))
                .foregroundStyle(.textGray)
            }
        }
        
        Text("월")
          .font(.notoSans(weight: .regular, size: .defaultFontSize))
          .padding(.trailing, .smallSpacing)
        
        Button {
          selectedPicker = .day
        } label: {
          RoundedRectangle(cornerRadius: 10)
            .fill(.backgroundGray)
            .frame(width: rectangleSize.width, height: rectangleSize.height)
            .overlay {
              Text("\(addSupplementVM.startDay)")
                .font(.notoSans(size: .defaultFontSize))
                .foregroundStyle(.textGray)
            }
        }
        
        Text("일")
          .font(.notoSans(weight: .regular, size: .defaultFontSize))
      }
      
      HStack(spacing: .smallSpacing) {
        Text("복용 주기")
          .font(.notoSans(size: .defaultFontSize))
        
        Spacer()
        
        RoundedRectangle(cornerRadius: 10)
          .fill(.backgroundGray)
          .frame(width: rectangleSize.width, height: rectangleSize.height)
          .overlay {
            Text("\(addSupplementVM.duration)")
              .font(.notoSans(size: .defaultFontSize))
              .foregroundStyle(.textGray)
          }
        
        Text("일")
          .font(.notoSans(weight: .regular, size: .defaultFontSize))
      }
      .contentShape(Rectangle())
      .onTapGesture {
        selectedPicker = .duration
      }
    }
  }
  
  private func supplementCountSelector() -> some View {
    HStack {
      let imageWidth: CGFloat = isPad ? 33 : 23
      let iconSize: CGFloat = .defaultFontSize - 2
      let textSize: CGFloat = .defaultFontSize + 2
      
      Text("섭취 횟수")
        .font(.notoSans(size: .defaultFontSize))
      
      Spacer()
      
      HStack(spacing: 25) {
        Button {
          addSupplementVM.removeRoutineTime()
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
        
        Text("\(addSupplementVM.doseSchedules.count)")
          .font(.notoSans(size: textSize))
          .padding(.bottom, 3)
        
        Button {
          addSupplementVM.addRoutineTime()
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
  }
  
  private func timeSelectionSection() -> some View {
    VStack(alignment: .leading){
      let circleWidth: CGFloat = isPad ? 25 : 18
      
      Text("복용 시간")
        .font(.notoSans(size: .defaultFontSize))
      
      ForEach(addSupplementVM.doseSchedules.indices, id: \.self) { index in
        let routine = addSupplementVM.doseSchedules[index]
        
        HStack(spacing: .defaultSpacing) {
          ZStack {
            Circle()
              .fill(.main)
              .frame(width: circleWidth, height: circleWidth)
            
            Text("\(index + 1)")
              .font(.notoSans(weight: .bold, size: .defaultFontSize - 8))
              .foregroundStyle(.white)
              .padding(.bottom, 1)
          }
          
          Text(routine.time.timeFormatter)
            .font(.notoSans(weight: .regular, size: .defaultFontSize))
            .padding(.bottom, 2)
          
          Spacer()
          
          Text(routine.doseString)
            .font(.notoSans(weight: .regular, size: .defaultFontSize))
            .foregroundStyle(.textGray)
            .padding(.bottom, 2)
        }
        .contentShape(Rectangle())
        .onTapGesture {
          selectedTimeIndex = index
          selectedPicker = .time
        }
      }
    }
    .cardStyle(padding: .defaultSpacing)
  }
  
  private func aiRecommendationSection() -> some View {
    AIRecommendedScheduleView(
      supplementSummary: addSupplementVM.supplemtSummary,
      lifestyle: lifestyleTimeVM.userLifestyle,
      supplement: $addSupplementVM.supplement
    )
  }
  
  private func memoSection() -> some View {
    VStack(alignment: .leading) {
      Text("메모")
        .font(.notoSans(size: .defaultFontSize))
      
      InputTextField(
        text: $addSupplementVM.memo,
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
    .frame(height: isPad ? 115 : 95)
  }
}


// MARK: - Sheets and Alerts
extension AddSupplementView {
  @ViewBuilder
  private func lifestyleTimePickerSheet() -> some View {
    if let category = selectedLifestyleCategory,
       let option = selectedLifestyleOption,
       showTimePicker {
      LifestyleTimePickerSheet(
        type: category,
        option: option,
        dates: lifestyleTimeVM.times(for: category),
        mealSelections: lifestyleTimeVM.mealSelections(for: category)
      ) { result in
        if let result, lifestyleTimeVM.setTime(result) {
          NotificationCenter.default.post(name: .didUpdateLifestyle, object: nil)
        }
        showTimePicker = false
      }
    }
  }
  
  private func cameraPickerSheet() -> some View {
    CameraPickerSheet(isPresented: $showScanner) { text in
      searchSupplementSummary(
        productNameInput: text,
        nameSource: .cameraOCR
      )
    }
    .statusBarHidden(true)
    .ignoresSafeArea()
  }
  
  @ViewBuilder
  private func saveErrorAlert() -> some View {
    if showAlert, let routineSaveError {
      AlertView(
        alertType: .confirm,
        title: routineSaveError.title,
        message: routineSaveError.message,
        onConfirm: {
          showAlert = false
          self.routineSaveError = nil
        }
      )
    }
  }
  
  @ViewBuilder
  private func requestSupplemntAlert() -> some View {
    if showAlert, let alanAPIError {
      AlertView(
        alertType: .confirm,
        title: alanAPIError.title,
        message: alanAPIError.message,
        onConfirm: {
          showAlert = false
          self.alanAPIError = nil
        }
      )
    }
  }
  
  @ViewBuilder
  private func defaultAlert() -> some View {
    if showAlert, alanAPIError == nil, alanAPIError == nil {
      AlertView(
        alertType: .confirm,
        title: "알 수 없는 오류",
        message: "예상치 못한 문제가 발생했습니다. 다시 시도해주세요.",
        onConfirm: {
          showAlert = false
          self.alanAPIError = nil
        }
      )
    }
  }
  
  @ViewBuilder
  private func schedulePickerSheet() -> some View {
    if let selectedPicker {
      switch selectedPicker {
      case .month:
        MonthPickerSheet (
          selectedMonth: addSupplementVM.startMonth
        ) { month in
          self.selectedPicker = nil
          guard let month else { return }
          addSupplementVM.setValue(.month(month))
        }
      case .day:
        DayPickerSheet(
          selectedDay: addSupplementVM.startDay,
          days: Date.daysInMonth(month: addSupplementVM.startMonth)
        ) { day in
          self.selectedPicker = nil
          guard let day else { return }
          addSupplementVM.setValue(.day(day))
        }
      case .duration:
        DurationPickerSheet(
          selectedDuration: addSupplementVM.duration
        ) { duration in
          self.selectedPicker = nil
          guard let duration else { return }
          addSupplementVM.setValue(.duration(duration))
        }
      case .weekday:
        WeekdayPickerSheet(
          weekdays: addSupplementVM.weekdays
        ) { weekdays in
          self.selectedPicker = nil
          guard let weekdays else { return }
          addSupplementVM.setValue(.weekday(weekdays))
        }
      case .time:
        TimePickerSheet (
          selectedIndex: selectedTimeIndex,
          doseSchedules: addSupplementVM.doseSchedules
        ) { doseSchedule in
          self.selectedPicker = nil
          guard let doseSchedule else { return }
          addSupplementVM.setValue(.time(doseSchedule), index: selectedTimeIndex)
        }
      }
    }
  }
}


// MARK: - Colors and Positions
extension AddSupplementView {
  func backgroundColor(for type: SupplementScheduleType) -> Color {
    type == addSupplementVM.selectedScheduleType ? .main : .clear
  }
  
  func textColor(for type: SupplementScheduleType) -> Color {
    type == addSupplementVM.selectedScheduleType ? .white : .textGray
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


// MARK: - Actions
extension AddSupplementView {
  private func handleKeyboardScroll(for fieldType: FieldType?, with proxy: ScrollViewProxy) {
    guard fieldType == .memo else { return }
    let keyboardAnimationDuration = 0.3
    
    Task { @MainActor in
      do {
        try await Task.sleep(for: .seconds(keyboardAnimationDuration))
        withAnimation {
          proxy.scrollTo(ViewID.confirmButton, anchor: .bottom)
        }
      } catch {
        print("❌ Error is \(error)")
      }
    }
  }
  
  private func dismissOrClearSelection() {
    if selectedIntakeItem != nil {
      selectedIntakeItem = nil
      NotificationCenter.default.post(name: .didUpdateSupplement, object: nil)
    } else {
      dismiss()
    }
  }
}


// MARK: - Network & DB
extension AddSupplementView {
  private func searchSupplementSummary(productNameInput: String, nameSource: SupplementNameSource) {
    guard !isSearchingSupplementSummary else { return }
    
    // 이전 검색 Task 취소
    searchTask?.cancel()
    
    isSearchingSupplementSummary = true
    supplementName = ""
    
    searchTask = Task {
      defer {
        Task { @MainActor in
          isSearchingSupplementSummary = false
        }
      }
      
      do {
        try await addSupplementVM.request(productNameInput: productNameInput, nameSource: nameSource)
      } catch let error as AlanAPIError {
        switch error {
        case .cancelld: break
        default:
          showAlert(error)
        }
        print("❌ Error is \(error)")
      } catch {
        showDefaultAlert()
        print("❌ Error is \(error)")
      }
    }
  }
  
  @MainActor
  private func saveRoutine() {
    guard !isSaving else { return }
    isSaving = true
    
    Task {
      do {
        try await lifestyleTimeVM.saveLifestyle()
        
        try await addSupplementVM.saveAndEditRoutine(
          modelContext: context,
          editingRoutine: editingRoutine
        )
        
        await MainActor.run {
          dismissOrClearSelection()
        }
      } catch let error as RoutineSaveError {
        showAlert(error)
        print("❌ \(error)")
      } catch {
        showAlert(.saveFailed)
        print("❌ Error is \(error)")
      }
    }
  }
  
  private func showDefaultAlert() {
    showAlert = true
  }
  
  private func showAlert(_ error: AlanAPIError) {
    alanAPIError = error
    showAlert = true
  }

  private func showAlert(_ error: RoutineSaveError) {
    routineSaveError = error
    showAlert = true
    isSaving = false
  }
}
