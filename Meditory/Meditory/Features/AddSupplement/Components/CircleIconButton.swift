//
//  CircleIconButton.swift
//  Meditory
//
//  Created by 홍승아 on 8/14/25.
//

import UIKit

class CircleIconButton: UIButton {
  enum ButtonType: String {
    case plus, minus
  }
  
  let type: ButtonType
  
  init(type: ButtonType, frame: CGRect = .zero) {
    self.type = type
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    self.type = .plus
    super.init(coder: coder)
    setup()
  }
  
  private func setup() {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .main
    config.baseForegroundColor = .white
    config.cornerStyle = .capsule
    config.contentInsets = .zero
    let symbolConfig = UIImage.SymbolConfiguration(
        pointSize: 14,
        weight: .bold
    )
    config.image = UIImage(
      systemName: type.rawValue,
      withConfiguration: UIImage.SymbolConfiguration(
          pointSize: 14,
          weight: .bold
      )
    )
    
    self.configuration = config
  }
}

