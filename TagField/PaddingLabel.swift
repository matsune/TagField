//
//  PaddingLabel.swift
//  Demo
//
//  Created by Yuma Matsune on 2018/01/25.
//  Copyright © 2018年 matsune. All rights reserved.
//

import Foundation
import UIKit

open class PaddingLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var padding = UIEdgeInsets.zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override open func drawText(in rect: CGRect) {
        let newRect = UIEdgeInsetsInsetRect(rect, padding)
        super.drawText(in: newRect)
    }
    
    override open var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.width += (padding.left + padding.right)
        intrinsicContentSize.height += (padding.top + padding.bottom)
        return intrinsicContentSize
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        let fittingSize = CGSize(width: size.width - (padding.left + padding.right),
                                 height: size.height - (padding.top + padding.bottom))
        let labelSize = super.sizeThatFits(fittingSize)
        return CGSize(width: labelSize.width + (padding.left + padding.right),
                      height: labelSize.height + (padding.top + padding.bottom))
    }
    
    func sizeToFit(_ size: CGSize) -> CGSize {
        if intrinsicContentSize.width > size.width {
            return CGSize(width: size.width,
                          height: self.frame.size.height)
        }
        return intrinsicContentSize
    }
}
