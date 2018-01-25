//
//  TagField.swift
//  Demo
//
//  Created by Yuma Matsune on 2018/01/25.
//  Copyright © 2018年 matsune. All rights reserved.
//

import Foundation
import UIKit

open class TagField: UIScrollView {
    
    weak open var tagDelegate: TagFieldDelegate?
    
    private var tagViews: [TagView] = []
    
    private let textField = UITextField()
    
    // - MARK: Stored properties
    open var delimiter: String?
    
    open var tagBetweenSpace: CGFloat = 2.0
    
    open var lineBetweenSpace: CGFloat = 3.0
    
    private var intrinsicContentHeight: CGFloat = 50
    
    open var padding: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    // - MARK: TagView properties
    open var tagPadding: UIEdgeInsets = .zero {
        didSet {
            tagViews.forEach { $0.padding = tagPadding }
        }
    }
    
    open var tagBackgroundColor: UIColor = .clear {
        didSet {
            tagViews.forEach { $0.backgroundColor = tagBackgroundColor }
        }
    }
    
    // - MARK: Computed properties
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width - (padding.left + padding.right), height: intrinsicContentHeight)
    }
    
    // - MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TagField.handleTap(_:)))
        addGestureRecognizer(tapGesture)
        
        textField.delegate = self
        addSubview(textField)
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        textField.becomeFirstResponder()
    }
    
    public func addTag(text: String) {
        let tagView = createTagView(text: text)
        addSubview(tagView)
        tagViews.append(tagView)
        repositionSubviews()
    }
    
    private func createTagView(text: String) -> TagView {
        let tagView = TagView()
        tagView.isUserInteractionEnabled = true
        tagView.backgroundColor = tagBackgroundColor
        tagView.padding = tagPadding
        tagView.text = text
        tagView.onTap = {
            self.tagDelegate?.tagField(self, didSelect: $0)
        }
        return tagView
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
        
        let textFieldMinWidth: CGFloat = 20
        let spaceWidth = (fullWidth - x)
        let h = (textField.font?.pointSize ?? 15) + 3
        if spaceWidth < textFieldMinWidth {
            // textField start next line
            x = padding.left
            y += maxHeightOfLine + lineBetweenSpace
            textField.frame = CGRect(x: x, y: y, width: fullWidth, height: h)
        } else {
            textField.frame = CGRect(x: x, y: y, width: spaceWidth, height: h)
        }
        intrinsicContentHeight = y + h - padding.top
        invalidateIntrinsicContentSize()
        
        contentSize = CGSize(width: bounds.width, height: intrinsicContentHeight + padding.top + padding.bottom)
        scrollRectToVisible(textField.frame, animated: false)
    }
}

extension TagField: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        scrollRectToVisible(textField.frame, animated: true)
        
        if string == delimiter {
            tokenizeTextField(textField)
            return false
        }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tokenizeTextField(textField)
        return tagDelegate?.tagFieldShouldReturn(self) ?? true
    }
    
    private func tokenizeTextField(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            addTag(text: text)
            textField.text = nil
        }
    }
}
