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
    
    private var tagLabels: [TagLabel] = []
    
    private let textField = BackspaceDetectTextField()
    
    // MARK: - Stored properties
    open var delimiter: String?
    
    open var tagBetweenSpace: CGFloat = 2.0
    
    open var lineBetweenSpace: CGFloat = 3.0
    
    open var allowMultipleSelection = false
    
    open var numberOfLines = 1
    
    open var padding: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    open var isReadonly = false {
        didSet {
            if !oldValue {
                textField.resignFirstResponder()
            }
            textField.isEnabled = !isReadonly
        }
    }
    
    private var intrinsicContentHeight: CGFloat = 50
    
    // MARK: - TagLabel properties
    open var tagPadding: UIEdgeInsets = .zero {
        didSet {
            tagLabels.forEach { $0.padding = tagPadding }
        }
    }
    
    open var tagTextColor: UIColor = .black {
        didSet {
            tagLabels.forEach { $0.normalTextColor = tagTextColor }
        }
    }
    
    open var tagBackgroundColor: UIColor = .clear {
        didSet {
            tagLabels.forEach { $0.normalBackgroundColor = tagBackgroundColor }
        }
    }
    
    open var tagSelectedTextColor: UIColor = .white {
        didSet {
            tagLabels.forEach { $0.selectedTextColor = tagSelectedTextColor }
        }
    }
    
    open var tagSelectedBackgroundColor: UIColor = .orange {
        didSet {
            tagLabels.forEach { $0.selectedBackgroundColor = tagSelectedBackgroundColor }
        }
    }
    
    open var tagCornerRadius: CGFloat = 3.0 {
        didSet {
            tagLabels.forEach { $0.cornerRadius = tagCornerRadius }
        }
    }
    
    // MARK: - Computed properties
    open var font: UIFont? {
        set {
            textField.font = newValue
            tagLabels.forEach { $0.font = newValue }
        }
        get {
            return textField.font
        }
    }
    
    private var selectedTagLabels: [TagLabel] {
        return tagLabels.filter { $0.isSelected }
    }
    
    // MARK: - Initializer
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
    
    // MARK: - Override
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width - (padding.left + padding.right), height: intrinsicContentHeight)
    }
    
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
    
    // MARK: - Public methods
    public func addTag(text: String) {
        if tagLabels.contains(where: {$0.text == text}) {
            clearTextField()
            return
        }
        
        let tagLabel = createTagLabel(text: text)
        addSubview(tagLabel)
        tagLabels.append(tagLabel)
        repositionSubviews()
    }
    
    public func deleteTag(text: String) {
        if let tagLabel = tagLabels.first(where: {$0.text == text}) {
            deleteTagLabel(tagLabel)
        }
    }
    
    // MARK: - Private methods
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        if !isReadonly {
            textField.becomeFirstResponder()
        }
    }
    
    private func createTagLabel(text: String) -> TagLabel {
        let tagLabel = TagLabel()
        tagLabel.isUserInteractionEnabled = true
        tagLabel.normalTextColor = tagTextColor
        tagLabel.normalBackgroundColor = tagBackgroundColor
        tagLabel.selectedTextColor = tagSelectedTextColor
        tagLabel.selectedBackgroundColor = tagSelectedBackgroundColor
        tagLabel.cornerRadius = tagCornerRadius
        tagLabel.padding = tagPadding
        tagLabel.text = text
        tagLabel.onTap = onTapTagLabel(_:)
        return tagLabel
    }
    
    private func repositionSubviews() {
        let fullWidth = bounds.width - (padding.left + padding.right)
        
        numberOfLines = 1
        var maxHeightOfLine: CGFloat = 0
        
        var x: CGFloat = padding.left
        var y: CGFloat = padding.top
        for tagLabel in tagLabels {
            let tagSize = tagLabel.intrinsicContentSize
            let spaceWidth = fullWidth - x
            
            if tagSize.width > spaceWidth {
                // new line
                x = padding.left
                y += maxHeightOfLine + lineBetweenSpace
                maxHeightOfLine = 0
                numberOfLines += 1
                
                if tagSize.width > fullWidth {
                    // clipping
                    tagLabel.frame = CGRect(x: x, y: y, width: fullWidth, height: tagSize.height)
                } else {
                    tagLabel.sizeToFit()
                    tagLabel.frame.origin = CGPoint(x: x, y: y)
                }
            } else {
                tagLabel.sizeToFit()
                tagLabel.frame.origin = CGPoint(x: x, y: y)
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
    
    private func onTapTagLabel(_ tagLabel: TagLabel) {
        if isReadonly {
            tagDelegate?.tagField(self, didSelect: tagLabel.text)
            return
        }
        
        textField.becomeFirstResponder()
        if !allowMultipleSelection {
            selectedTagLabels.forEach { $0.setSelected(false, animated: true) }
        }
        tagLabel.setSelected(true, animated: true)
        tagDelegate?.tagField(self, didSelect: tagLabel.text)
    }
    
    private func clearTextField() {
        textField.text = nil
    }
    
    private func clearAllSelection(animated: Bool) {
        tagLabels
            .filter { $0.isSelected }
            .forEach { $0.setSelected(false, animated: true) }
    }
    
    private func onDeleteBackward() {
        let tagLabels = selectedTagLabels
        tagLabels.forEach {
            deleteTagLabel($0)
        }
    }
    
    private func deleteTagLabel(_ tagLabel: TagLabel) {
        tagLabel.removeFromSuperview()
        if let index = tagLabels.index(of: tagLabel) {
            tagLabels.remove(at: index)
        }
        repositionSubviews()
    }
}

extension TagField: UITextFieldDelegate {
    // MARK: - UITextFieldDelegate
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
