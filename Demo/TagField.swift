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
    
    private let textField = BackspaceDetectTextField()
    
    // - MARK: Stored properties
    open var delimiter: String?
    
    open var tagBetweenSpace: CGFloat = 2.0
    
    open var lineBetweenSpace: CGFloat = 3.0
    
    open var allowMultipleSelection = false
    
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
    
    open var tagTextColor: UIColor = .black {
        didSet {
            tagViews.forEach { $0.normalTextColor = tagTextColor }
        }
    }
    
    open var tagBackgroundColor: UIColor = .clear {
        didSet {
            tagViews.forEach { $0.normalBackgroundColor = tagBackgroundColor }
        }
    }
    
    open var tagSelectedTextColor: UIColor = .white {
        didSet {
            tagViews.forEach { $0.selectedTextColor = tagSelectedTextColor }
        }
    }
    
    open var tagSelectedBackgroundColor: UIColor = .orange {
        didSet {
            tagViews.forEach { $0.selectedBackgroundColor = tagSelectedBackgroundColor }
        }
    }
    
    // - MARK: Computed properties
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width - (padding.left + padding.right), height: intrinsicContentHeight)
    }
    
    private var selectedTagViews: [TagView] {
        return tagViews.filter { $0.isSelected }
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
        textField.onDeleteBackward = onDeleteBackward
        addSubview(textField)
    }
    
    // - MARK: Override
    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        clearAllSelection(animated: true)
        tokenizeTextField()
        return textField.resignFirstResponder()
    }
    
    // - MARK: Public methods
    public func addTag(text: String) {
        if tagViews.contains(where: {$0.text == text}) {
            clearTextField()
            return
        }
        
        let tagView = createTagView(text: text)
        addSubview(tagView)
        tagViews.append(tagView)
        repositionSubviews()
    }
    
    public func deleteTag(text: String) {
        if let tagView = tagViews.first(where: {$0.text == text}) {
            deleteTagView(tagView)
        }
    }
    
    // - MARK: Private methods
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        textField.becomeFirstResponder()
    }
    
    private func createTagView(text: String) -> TagView {
        let tagView = TagView()
        tagView.isUserInteractionEnabled = true
        tagView.normalTextColor = tagTextColor
        tagView.normalBackgroundColor = tagBackgroundColor
        tagView.selectedTextColor = tagSelectedTextColor
        tagView.selectedBackgroundColor = tagSelectedBackgroundColor
        tagView.padding = tagPadding
        tagView.text = text
        tagView.onTap = onTapTagView(_:)
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
    
    private func onTapTagView(_ tagView: TagView) {
        textField.becomeFirstResponder()
        if !allowMultipleSelection {
            selectedTagViews.forEach { $0.setSelected(false, animated: true) }
        }
        tagView.setSelected(true, animated: true)
        tagDelegate?.tagField(self, didSelect: tagView)
    }
    
    private func clearTextField() {
        textField.text = nil
    }
    
    private func clearAllSelection(animated: Bool) {
        tagViews
            .filter { $0.isSelected }
            .forEach { $0.setSelected(false, animated: true) }
    }
    
    private func onDeleteBackward() {
        let tagViews = selectedTagViews
        tagViews.forEach {
            deleteTagView($0)
        }
    }
    
    private func deleteTagView(_ tagView: TagView) {
        tagView.removeFromSuperview()
        if let index = tagViews.index(of: tagView) {
            tagViews.remove(at: index)
        }
        repositionSubviews()
    }
}

extension TagField: UITextFieldDelegate {
    // - MARK: UITextFieldDelegate
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        clearAllSelection(animated: true)
        scrollRectToVisible(textField.frame, animated: true)
        
        if string == delimiter {
            tokenizeTextField()
            return false
        }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tokenizeTextField()
        return tagDelegate?.tagFieldShouldReturn(self) ?? true
    }
    
    private func tokenizeTextField() {
        if let text = textField.text, !text.isEmpty {
            addTag(text: text)
            clearTextField()
        }
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        clearAllSelection(animated: true)
    }
}
