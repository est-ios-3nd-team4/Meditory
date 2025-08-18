//
//  SchedulePickerViewController.swift
//  Meditory
//
//  Created by 홍승아 on 8/6/25.
//

import UIKit

final class SchedulePickerViewController: UIViewController {
  
  @objc enum DismissType: Int {
    case confirm
    case cancel
  }
  
  let type: SchedulePickerType
  let scheduleVM: SupplementScheduleViewModel
  
  var onDismiss: (() -> Void)?
  
  private let backgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.3)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  private let containerView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = .defaultRadius
    view.clipsToBounds = true
    view.backgroundColor = .systemBackground
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  private let indicatorView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 2.5
    view.backgroundColor = .textGray
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .notoSans(size: 16)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  private let doseLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .notoSans(size: 20)
    return label
  }()
  private let confirmButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .main
    config.baseForegroundColor = .white
    
    let font = UIFont.notoSans(weight: .semiBold, size: 18)
    let attributes: [NSAttributedString.Key: Any] = [
      .font: font ?? .systemFont(ofSize: 18)
    ]
    config.attributedTitle = AttributedString("완료", attributes: AttributeContainer(attributes))
    
    let button = UIButton(configuration: config)
    button.layer.cornerRadius = .smallRadius
    button.clipsToBounds = true
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  private let tableView = UITableView()
  private var tableViewHeightConstraint: NSLayoutConstraint?
  
  private let horizontalPadding: CGFloat = 20
  private var titleHorizontalPadding: CGFloat {
    horizontalPadding + 4
  }
  
  init(type: SchedulePickerType, scheduleVM: SupplementScheduleViewModel) {
    self.type = type
    self.scheduleVM = scheduleVM
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    tableViewHeightConstraint?.constant = tableView.contentSize.height
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    
    containerView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
    containerView.alpha = 0
    backgroundView.alpha = 0
    
    UIView.animate(withDuration: 0.2) {
      self.backgroundView.alpha = 1
      self.containerView.alpha = 1
      self.containerView.transform = .identity
    }
  }
}


// MARK: - Setup UI
extension SchedulePickerViewController {
  private func setup() {
    view.addSubview(backgroundView)
    view.addSubview(containerView)
    
    containerView.addSubview(indicatorView)
    containerView.addSubview(titleLabel)
    containerView.addSubview(confirmButton)
        
    NSLayoutConstraint.activate([
      backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
      backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      indicatorView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: .smallSpacing),
      indicatorView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
      indicatorView.widthAnchor.constraint(equalToConstant: 40),
      indicatorView.heightAnchor.constraint(equalToConstant: 5),
      
      titleLabel.topAnchor.constraint(equalTo: indicatorView.bottomAnchor, constant: 20),
      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: titleHorizontalPadding),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -titleHorizontalPadding),
      
      confirmButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
      confirmButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
      confirmButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor),
      confirmButton.heightAnchor.constraint(equalToConstant: 50)
    ])
    
    switch type {
    case .month, .day, .duration:
      setupPicker()
    case .weekday:
      setupWeekdayTableView()
      break
    case .time:
      setupDatePicker()
      break
    }
    
    titleLabel.text = type.title
    confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    containerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
  }
  
  private func setupPicker() {
    let picker = UIPickerView()
    picker.translatesAutoresizingMaskIntoConstraints = false
    picker.dataSource = self
    picker.delegate = self
    
    containerView.addSubview(picker)
    
    NSLayoutConstraint.activate(commonConstraints(for: picker))
  
    picker.selectRow(scheduleVM.index(type: type), inComponent: 0, animated: false)
  }
  
  private func setupDatePicker() {
    let picker = UIDatePicker()
    picker.datePickerMode = .time
    picker.locale = Locale(identifier: "ko-KR")
    picker.preferredDatePickerStyle = .wheels
    picker.translatesAutoresizingMaskIntoConstraints = false
    picker.addTarget(self, action: #selector(timeDidChange(_:)), for: .valueChanged)
    picker.date = scheduleVM.time
    
    let divider = UIView()
    divider.translatesAutoresizingMaskIntoConstraints = false
    divider.backgroundColor = .init(red: 241, green: 241, blue: 241)
    
    let doseTitleLabel = UILabel()
    doseTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    doseTitleLabel.text = "섭취 량"
    doseTitleLabel.font = .notoSans(size: 16)
    
    let minusButton = CircleIconButton(type: .minus)
    minusButton.translatesAutoresizingMaskIntoConstraints = false
    minusButton.addTarget(self, action: #selector(pillPerDoseChange), for: .touchUpInside)
    let plusButton = CircleIconButton(type: .plus)
    plusButton.translatesAutoresizingMaskIntoConstraints = false
    plusButton.addTarget(self, action: #selector(pillPerDoseChange), for: .touchUpInside)
    
    doseLabel.text = "\(scheduleVM.pillsPerDose) 정"
    
    containerView.addSubview(picker)
    containerView.addSubview(divider)
    containerView.addSubview(doseTitleLabel)
    containerView.addSubview(doseLabel)
    containerView.addSubview(minusButton)
    containerView.addSubview(plusButton)

    NSLayoutConstraint.activate([
      picker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
      picker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      picker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      
      divider.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: .smallSpacing),
      divider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: titleHorizontalPadding),
      divider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -titleHorizontalPadding),
      divider.heightAnchor.constraint(equalToConstant: 1),
      
      doseTitleLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: .defaultSpacing),
      doseTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: titleHorizontalPadding),
      doseTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -titleHorizontalPadding),
      
      minusButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: titleHorizontalPadding),
      minusButton.centerYAnchor.constraint(equalTo: doseLabel.centerYAnchor),
      minusButton.widthAnchor.constraint(equalToConstant: 30),
      minusButton.heightAnchor.constraint(equalTo: minusButton.widthAnchor),
      
      doseLabel.topAnchor.constraint(equalTo: doseTitleLabel.bottomAnchor, constant: 25),
      doseLabel.bottomAnchor.constraint(equalTo:confirmButton.topAnchor, constant: -25),
      doseLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
      
      plusButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -titleHorizontalPadding),
      plusButton.centerYAnchor.constraint(equalTo: doseLabel.centerYAnchor),
      plusButton.widthAnchor.constraint(equalToConstant: 30),
      plusButton.heightAnchor.constraint(equalTo: plusButton.widthAnchor)
    ])
  }
  
  private func setupWeekdayTableView() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.separatorStyle = .none
    tableView.delegate = self
    tableView.dataSource = self
    tableView.isScrollEnabled = false
    tableView.register(WeekdayCell.self, forCellReuseIdentifier: String(describing: WeekdayCell.self))
    
    containerView.addSubview(tableView)
    
    NSLayoutConstraint.activate(commonConstraints(for: tableView, constant: titleHorizontalPadding + 2))
    
    tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 100)
    tableViewHeightConstraint?.isActive = true
  }
  
  private func commonConstraints(for view: UIView, constant: CGFloat = .zero) -> [NSLayoutConstraint] {
    return [
      view.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: constant > 0 ? .defaultSpacing : .zero),
      view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: constant),
      view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -constant),
      view.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -(.defaultSpacing))
    ]
  }
}


// MARK: - Actions
extension SchedulePickerViewController {
  @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: containerView)

    switch gesture.state {
    case .changed:
      if translation.y > 0 {
        UIView.animate(withDuration: 0.05, delay: 0, options: [.curveEaseOut], animations: {
          self.containerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        }, completion: nil)
      }
    case .ended:
      if translation.y > self.containerView.bounds.height * 0.5 {
        dismissWithAnimation(.cancel)
      } else {
        UIView.animate(withDuration: 0.2) {
          self.containerView.transform = .identity
        }
      }
    default:
      break
    }
  }
  
  @objc private func confirmButtonTapped(_ sender: UIButton) {
    dismissWithAnimation(.confirm)
  }
  
  private func dismissWithAnimation(_ dismissType: DismissType) {
    UIView.animate(withDuration: 0.2) {
      self.containerView.transform = CGAffineTransform(translationX: 0, y: self.containerView.bounds.height)
      self.backgroundView.alpha = 0
    } completion: { [weak self] _ in
      guard let self else { return }
      if dismissType == .confirm {
        self.onDismiss?()
      }
      self.dismiss(animated: false)
    }
  }
  
  @objc private func timeDidChange(_ sender: UIDatePicker) {
    scheduleVM.time = sender.date
  }
  
  @objc private func pillPerDoseChange(_ sender: CircleIconButton) {
    scheduleVM.setPillPerDose(type: sender.type)
    doseLabel.text = "\(scheduleVM.pillsPerDose) 정"
  }
}


// MARK: - UIPickerViewDataSource
extension SchedulePickerViewController: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return scheduleVM.numberOfRows(for: type)
  }
}


// MARK: - UIPickerViewDelegate
extension SchedulePickerViewController: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return scheduleVM.title(for: row, type: type)
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    scheduleVM.setValue(for: row, type: type)
  }
}


extension SchedulePickerViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Weekday.allCases.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WeekdayCell.self), for: indexPath) as? WeekdayCell else { return UITableViewCell() }
    
    let weekday = Weekday.allCases[indexPath.row]
    
    cell.configure(
      weekDay: weekday.title,
      isChecked: scheduleVM.days[weekday] ?? false
    )
    
    return cell
  }
}

extension SchedulePickerViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    scheduleVM.selectedDayToggle(weekDay: Weekday.allCases[indexPath.row])
    tableView.reloadRows(at: [indexPath], with: .none)
  }
}
