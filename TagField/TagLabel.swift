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
    
    open var cornerRadius: CGFloat = 3 {
        didSet {
            setNeedsLayout()
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
        textAlignment = .center
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TagLabel.handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width + (padding.left + padding.right),
                      height: super.intrinsicContentSize.height + (padding.top + padding.bottom))
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let fittingSize = CGSize(width: size.width - (padding.left + padding.right),
                                 height: size.height - (padding.top + padding.bottom))
        let labelSize = super.sizeThatFits(fittingSize)
        return CGSize(width: labelSize.width + (padding.left + padding.right),
                      height: labelSize.height + (padding.top + padding.bottom))
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
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
    }
}
