//
//  TagFieldDelegate.swift
//  Demo
//
//  Created by Yuma Matsune on 2018/01/25.
//  Copyright © 2018年 matsune. All rights reserved.
//

import Foundation

public protocol TagFieldDelegate: class {
    func tagField(_ tagField: TagField, didSelect tag: String?)
    func tagFieldShouldReturn(_ tagField: TagField) -> Bool
}

extension TagFieldDelegate {
    
    func tagField(_ tagField: TagField, didSelect tag: String?) {
        print("didSelect")
    }
    
    func tagFieldShouldReturn(_ tagField: TagField) -> Bool {
        return true
    }
}
