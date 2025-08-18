//
//  LifestyleTime.swift
//  Meditory
//
//  Created by 홍승아 on 8/17/25.
//

import Foundation

protocol LifestyleTime: CaseIterable, Hashable {
  var title: String { get }
  var imageName: String { get }
}
