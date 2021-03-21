//
//  Extension.swift
//  HappyTherapist
//
//  Created by REO HARADA on 2021/03/21.
//

import UIKit

extension UILabel {
    func blinking() {
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { (ti) in
            self.isHidden = !self.isHidden
        }
    }
}
