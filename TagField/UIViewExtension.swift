//
//  UIViewExtension.swift
//  TagField
//
//  Created by Yuma Matsune on 2018/03/02.
//  Copyright © 2018年 matsune. All rights reserved.
//

import Foundation

extension UIView {
    convenience init<V>(style: Style<V>) {
        self.init(frame: .zero)
        apply(style)
    }
    
    func apply<V>(_ style: Style<V>) {
        guard let view = self as? V else {
            print("Could not apply style for \(V.self) to \(type(of: self))")
            return
        }
        style.apply(to: view)
    }
}
