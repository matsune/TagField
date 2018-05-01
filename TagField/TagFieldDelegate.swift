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
    func tagField(_ tagField: TagField, didAppend tags: [String?])
    func tagField(_ tagField: TagField, didRemove tags: [String?], at indexes: [Int])
    
    func tagFieldDidChangeText(_ tagField: TagField)
    func tagFieldShouldReturn(_ tagField: TagField) -> Bool
    func tagFieldDidBeginEditing(_ tagField: TagField)
    func tagFieldDidEndEditing(_ tagField: TagField)
    @available(iOS 10.0, *)
    func tagFieldDidEndEditing(_ tagField: TagField, reason: UITextFieldDidEndEditingReason)
    func tagFieldShouldClear(_ tagField: TagField) -> Bool
    func tagFieldShouldEndEditing(_ tagField: TagField) -> Bool
    func tagFieldShouldBeginEditing(_ tagField: TagField) -> Bool
    func tagField(_ tagField: TagField, shouldSelectAt index: Int) -> Bool
}

public extension TagFieldDelegate {
    
    func tagField(_ tagField: TagField, didSelect tag: String?) {}
    
    func tagField(_ tagField: TagField, didAppend tags: [String?]) {}
    
    func tagField(_ tagField: TagField, didRemove tags: [String?], at indexes: [Int]) {}
    
    func tagFieldDidChangeText(_ tagField: TagField) {}
    
    func tagFieldShouldReturn(_ tagField: TagField) -> Bool {
        return true
    }
    
    func tagFieldDidBeginEditing(_ tagField: TagField) {}
    
    func tagFieldDidEndEditing(_ tagField: TagField) {}
    
    @available(iOS 10.0, *)
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
    
    func tagField(_ tagField: TagField, shouldSelectAt index: Int) -> Bool {
        return true
    }
}
