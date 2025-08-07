//
//  CompletionCircleView.swift
//  Meditory
//
//  Created by 홍승아 on 8/7/25.
//

import UIKit

class CompletionCircleView: UIView {
  
  private let circleView: UIView = {
    let view = UIView()
    view.clipsToBounds = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  private let checkmarkImageView: UIImageView = {
    let imageView = UIImageView()
    let config = UIImage.SymbolConfiguration(weight: .bold)
    imageView.image = UIImage(systemName: "checkmark", withConfiguration: config)
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.tintColor = .white
    return imageView
  }()
  private var size: CGFloat = 44.0
  
  private var checkmarkImageViewWidthConstraint: NSLayoutConstraint?
  private var checkmarkImageViewHeightConstraint: NSLayoutConstraint?
  
  var isCompleted: Bool = false {
    didSet {
      updateAppearance()
    }
  }
  
  init(size: CGFloat = 44.0) {
    self.size = size
    super.init(frame: .zero)
    setupView()
    updateAppearance()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    self.translatesAutoresizingMaskIntoConstraints = false
    self.widthAnchor.constraint(equalToConstant: size).isActive = true
    self.heightAnchor.constraint(equalToConstant: size).isActive = true
    
    circleView.layer.cornerRadius = size / 2
    
    addSubview(circleView)
    circleView.addSubview(checkmarkImageView)
    
    NSLayoutConstraint.activate([
      circleView.topAnchor.constraint(equalTo: topAnchor),
      circleView.bottomAnchor.constraint(equalTo: bottomAnchor),
      circleView.leadingAnchor.constraint(equalTo: leadingAnchor),
      circleView.trailingAnchor.constraint(equalTo: trailingAnchor),
      
      checkmarkImageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
      checkmarkImageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
      checkmarkImageView.widthAnchor.constraint(equalToConstant: size * 0.6),
      checkmarkImageView.heightAnchor.constraint(equalToConstant: size * 0.6)
    ])
  }
  
  private func updateAppearance() {
    if isCompleted {
      circleView.backgroundColor = .main
      checkmarkImageView.isHidden = false
      circleView.layer.borderWidth = 0
    } else {
      circleView.backgroundColor = .white
      checkmarkImageView.isHidden = true
      circleView.layer.borderColor = UIColor.gray.cgColor
      circleView.layer.borderWidth = size * 0.06
    }
  }
}
