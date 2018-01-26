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
    
    var onTap: ((TagLabel) -> Void)?
    
    public private(set) var isSelected = false
    
    open var animationDuration: TimeInterval = 0.4
    
    public var normalTextColor: UIColor = .black {
        didSet {
            updateView(animated: false)
        }
    }
    
    public var normalBackgroundColor: UIColor = .orange {
        didSet {
            updateView(animated: false)
        }
    }
    
    public var selectedTextColor: UIColor = .white {
        didSet {
            updateView(animated: false)
        }
    }
    
    public var selectedBackgroundColor: UIColor = .orange {
        didSet {
            updateView(animated: false)
        }
    }
    
    public var cornerRadius: CGFloat = 3 {
        didSet {
            setNeedsLayout()
        }
    }
        
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.masksToBounds = false
        textAlignment = .center
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TagLabel.handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        onTap?(self)
    }
    
    public func setSelected(_ selected: Bool, animated: Bool) {
        isSelected = selected
        updateView(animated: animated)
    }
    
    public func updateContent() {
        if isSelected {
            self.backgroundColor = self.selectedBackgroundColor
            self.textColor = self.selectedTextColor
            selectedAnimation()
        } else {
            self.backgroundColor = self.normalBackgroundColor
            self.textColor = self.normalTextColor
            deselectedAnimation()
        }
    }
    
    open func selectedAnimation() {
        
    }
    
    open func deselectedAnimation() {
        
    }
    
    private func updateView(animated: Bool) {
        let duration = animated ? animationDuration : 0.0
        UIView.transition(with: self,
                          duration: duration,
                          options: .transitionCrossDissolve,
                          animations: updateContent, completion: nil)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
    }
}
