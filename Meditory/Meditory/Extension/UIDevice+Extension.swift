//
//  UIDevice+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/4/25.
//

import UIKit

extension UIDevice {
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}
