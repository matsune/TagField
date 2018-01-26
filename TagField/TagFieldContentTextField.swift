//
//  TagFieldContentTextField.swift
//  Demo
//
//  Created by Yuma Matsune on 2018/01/26.
//  Copyright © 2018年 matsune. All rights reserved.
//

import Foundation
import UIKit

final class TagFieldContentTextField: UITextField {
    
    var onDeleteBackward: (() -> Void)?
    var onTap: (() -> Void)?
    var isHiddenCaret = false
    var isHiddenPlaceholder = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TagFieldContentTextField.handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    override func deleteBackward() {
        onDeleteBackward?()
        super.deleteBackward()
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        if isHiddenCaret {
            return .zero
        }
        return super.caretRect(for: position)
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        onTap?()
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        if isHiddenPlaceholder {
            return .zero
        }
        return super.placeholderRect(forBounds: bounds)
    }
}
