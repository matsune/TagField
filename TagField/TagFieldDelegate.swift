//
//  TagFieldDelegate.swift
//  Demo
//
//  Created by Yuma Matsune on 2018/01/25.
//  Copyright © 2018年 matsune. All rights reserved.
//

import Foundation
import UIKit

public protocol TagFieldDelegate: class {
    func tagField(_ tagField: TagField, didSelect tag: String?)
    func tagFieldShouldReturn(_ tagField: TagField) -> Bool
    func tagFieldDidBeginEditing(_ tagField: TagField)
    func tagFieldDidEndEditing(_ tagField: TagField)
    func tagFieldDidEndEditing(_ tagField: TagField, reason: UITextFieldDidEndEditingReason)
    func tagFieldShouldClear(_ tagField: TagField) -> Bool
    func tagFieldShouldEndEditing(_ tagField: TagField) -> Bool
    func tagFieldShouldBeginEditing(_ tagField: TagField) -> Bool
}

public extension TagFieldDelegate {
    
    func tagField(_ tagField: TagField, didSelect tag: String?) {}
    
    func tagFieldShouldReturn(_ tagField: TagField) -> Bool {
        return true
    }
    
    func tagFieldDidBeginEditing(_ tagField: TagField) {}
    
    func tagFieldDidEndEditing(_ tagField: TagField) {}
    
    func tagFieldDidEndEditing(_ tagField: TagField, reason: UITextFieldDidEndEditingReason) {}
    
    func tagFieldShouldClear(_ tagField: TagField) -> Bool {
        return false
    }
    
    func tagFieldShouldEndEditing(_ tagField: TagField) -> Bool {
        return true
    }
    
    func tagFieldShouldBeginEditing(_ tagField: TagField) -> Bool {
        return true
    }
}
