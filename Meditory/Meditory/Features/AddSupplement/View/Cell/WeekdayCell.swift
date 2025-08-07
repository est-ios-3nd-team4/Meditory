//
//  WeekdayCell.swift
//  Meditory
//
//  Created by 홍승아 on 8/7/25.
//

import UIKit

class WeekdayCell: UITableViewCell {
  
  private let weekdayLabel: UILabel = {
    let label = UILabel()
    label.font = .notoSans(size: 18)
    label.textColor = .label
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let checkBox = CompletionCircleView(size: 25)
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    setupLayout()
  }
  
  private func setupLayout() {
    self.selectionStyle = .none
    
    checkBox.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.addSubview(weekdayLabel)
    contentView.addSubview(checkBox)
    
    let horizontalPadding: CGFloat = 4
    let verticalPadding: CGFloat = .smallSpacing
    
    NSLayoutConstraint.activate([
      weekdayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalPadding),
      weekdayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
      weekdayLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalPadding),

      checkBox.leadingAnchor.constraint(greaterThanOrEqualTo: weekdayLabel.trailingAnchor, constant: 10),
      checkBox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
      checkBox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
    ])
  }
  
  func configure(weekDay: String, isChecked: Bool) {
    weekdayLabel.text = weekDay
    checkBox.isCompleted = isChecked
  }
}
