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
    
    private var tagViews: [TagView] = []
    
    var tagPadding: UIEdgeInsets = .zero {
        didSet {
            tagViews.forEach { $0.padding = tagPadding }
        }
    }
    
    var tagBackgroundColor: UIColor = .clear {
        didSet {
            tagViews.forEach { $0.backgroundColor = tagBackgroundColor }
        }
    }
    
    var padding: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    var tagBetweenSpace: CGFloat = 2.0
    
    var lineBetweenSpace: CGFloat = 3.0
    
    var intrinsicContentHeight: CGFloat = 50

    func addTag(text: String) {
        let tagView = createTagView(text: text)
        addSubview(tagView)
        tagViews.append(tagView)
        setNeedsLayout()
    }
    
    private func createTagView(text: String) -> TagView {
        let tagView = TagView()
        tagView.text = text
        return tagView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        repositionSubviews()
    }
    
    private func repositionSubviews() {
        let fullWidth = bounds.width - (padding.left + padding.right)
        
        var numOfLines = 1
        var maxHeightOfLine: CGFloat = 0
        
        var x: CGFloat = padding.left
        var y: CGFloat = padding.top
        for tagView in tagViews {
            let tagSize = tagView.intrinsicContentSize
            let spaceWidth = fullWidth - x
            
            if tagSize.width > spaceWidth {
                // new line
                x = padding.left
                y += maxHeightOfLine + lineBetweenSpace
                maxHeightOfLine = 0
                numOfLines += 1
                
                if tagSize.width > fullWidth {
                    // cripping
                    tagView.frame = CGRect(x: x, y: y, width: fullWidth, height: tagSize.height)
                } else {
                    tagView.sizeToFit()
                    tagView.frame.origin = CGPoint(x: x, y: y)
                }
            } else {
                tagView.sizeToFit()
                tagView.frame.origin = CGPoint(x: x, y: y)
            }
            x += tagSize.width + tagBetweenSpace
            maxHeightOfLine = max(maxHeightOfLine, tagSize.height)
        }
    }
}

final class ViewController: UIViewController {

    var d = TagField(frame: CGRect(x: 0, y: 100, width: 100, height: 100))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        
        d.backgroundColor = .white
        d.padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        d.addTag(text: "aaa")
        d.addTag(text: "aa")
        d.addTag(text: "aaaaaaaaaaaaaaaaa")
        d.addTag(text: "aaadasfdfsads")
        d.addTag(text: "aaaddd")
        d.tagBackgroundColor = .orange
        
        view.addSubview(d)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//
//        }
    }

}

