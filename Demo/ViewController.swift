//
//  ViewController.swift
//  Demo
//
//  Created by Yuma Matsune on 2018/01/25.
//  Copyright © 2018年 matsune. All rights reserved.
//

import UIKit

open class PaddingLabel: UILabel {
    
    open var padding = UIEdgeInsets.zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    open override func drawText(in rect: CGRect) {
        let newRect = UIEdgeInsetsInsetRect(rect, padding)
        super.drawText(in: newRect)
    }
    
    open override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.height += (padding.top + padding.bottom)
        intrinsicContentSize.width += (padding.left + padding.right)
        return intrinsicContentSize
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let fittingSize = CGSize(width: size.width - (padding.left + padding.right),
                                 height: size.height - (padding.top + padding.bottom))
        let labelSize = super.sizeThatFits(fittingSize)
        return CGSize(width: labelSize.width + (padding.left + padding.right),
                      height: labelSize.height + (padding.top + padding.bottom))
    }
    
    open func sizeToFit(_ size: CGSize) -> CGSize {
        if intrinsicContentSize.width > size.width {
            return CGSize(width: size.width,
                          height: self.frame.size.height)
        }
        return intrinsicContentSize
    }
}

class TagView: PaddingLabel {
    
}

final class TagField: UIScrollView {
    
}

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let v = TagView(frame: CGRect(x: 100, y: 50, width: 100, height: 10))
//        v.text = "aaaaaa"
//        v.backgroundColor = .orange
//        view.addSubview(v)
        
        let d = TagView(frame: CGRect(x: 100, y: 230, width: 100, height: 10))
        d.text = "aaaaaa"
        d.backgroundColor = .orange
        d.padding = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 0)
        d.sizeToFit()
        view.addSubview(d)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

