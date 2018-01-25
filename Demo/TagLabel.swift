//
//  TagLabel.swift
//  Demo
//
//  Created by Yuma Matsune on 2018/01/25.
//  Copyright © 2018年 matsune. All rights reserved.
//

import Foundation
import UIKit

open class TagLabel: PaddingLabel {
    
    internal var onTap: ((TagLabel) -> Void)?
    
    public private(set) var isSelected = false
    
    open var normalTextColor: UIColor = .black {
        didSet {
            updateContent(animated: false)
        }
    }
    
    open var normalBackgroundColor: UIColor = .orange {
        didSet {
            updateContent(animated: false)
        }
    }
    
    open var selectedTextColor: UIColor = .white {
        didSet {
            updateContent(animated: false)
        }
    }
    
    open var selectedBackgroundColor: UIColor = .orange {
        didSet {
            updateContent(animated: false)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TagLabel.handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        onTap?(self)
    }
    
    public func setSelected(_ selected: Bool, animated: Bool) {
        isSelected = selected
        updateContent(animated: animated)
    }
    
    private func updateContent(animated: Bool) {
        let updateColor = {
            if self.isSelected {
                self.backgroundColor = self.selectedBackgroundColor
                self.textColor = self.selectedTextColor
            } else {
                self.backgroundColor = self.normalBackgroundColor
                self.textColor = self.normalTextColor
            }
        }
        
        if animated {
            UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve, animations: updateColor, completion: nil)
        } else {
            updateColor()
        }
    }
}
