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
    
    private let textField = TagFieldContentTextField()
    
    // MARK: - Stored properties
    open var delimiter: String?
    
    open var tagBetweenSpace: CGFloat = 2.0
    
    open var lineBetweenSpace: CGFloat = 3.0
    
    open var allowMultipleSelection = false
    
    open var textFieldMinWidth: CGFloat = 20
    
    open var padding = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10) {
        didSet {
            setNeedsLayout()
        }
    }
    
    open var isReadonly = false {
        didSet {
            if isReadonly {
                textField.resignFirstResponder()
                deselectAllTags(animated: true)
            }
            textField.isEnabled = !isReadonly
        }
    }
    
    public private(set) var numberOfLines = 1
    
    private var intrinsicContentHeight: CGFloat = 50
    
    private var isHiddenCaret = true {
        didSet {
            textField.isHiddenCaret = isHiddenCaret
        }
    }
    
    open var font: UIFont? {
        didSet {
            textField.font = font
            tagLabels.forEach { $0.font = font }
        }
    }
    
    open var placeholder: String? {
        set {
            textField.placeholder = newValue
        }
        get {
            return textField.placeholder
        }
    }
    
    // MARK: - TagLabel properties
    open var tagPadding = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8) {
        didSet {
            tagLabels.forEach { $0.padding = tagPadding }
        }
    }
    
    open var tagTextColor: UIColor = .white {
        didSet {
            tagLabels.forEach { $0.normalTextColor = tagTextColor }
        }
    }
    
    open var tagBackgroundColor: UIColor = .orange {
        didSet {
            tagLabels.forEach { $0.normalBackgroundColor = tagBackgroundColor }
        }
    }
    
    open var tagSelectedTextColor: UIColor = .white {
        didSet {
            tagLabels.forEach { $0.selectedTextColor = tagSelectedTextColor }
        }
    }
    
    open var tagSelectedBackgroundColor: UIColor = .red {
        didSet {
            tagLabels.forEach { $0.selectedBackgroundColor = tagSelectedBackgroundColor }
        }
    }
    
    open var tagCornerRadius: CGFloat = 8.0 {
        didSet {
            tagLabels.forEach { $0.cornerRadius = tagCornerRadius }
        }
    }
    
    // MARK: - Computed properties
    
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
        layer.masksToBounds = true
        backgroundColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TagField.handleTap(_:)))
        addGestureRecognizer(tapGesture)
       
        textField.contentHorizontalAlignment = .right
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        textField.delegate = self
        textField.onTap = onTapTextField
        textField.onDeleteBackward = onDeleteBackward
        addSubview(textField)
    }
    
    // MARK: - Override
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width - (padding.left + padding.right), height: intrinsicContentHeight)
    }
    
    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        isHiddenCaret = false
        return textField.becomeFirstResponder()
    }
    
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        deselectAllTags(animated: true)
        tokenizeTextField()
        isHiddenCaret = true
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
            deselectAllTags(animated: true)
            becomeFirstResponder()
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
        tagLabel.font = font
        tagLabel.text = text
        tagLabel.onTap = onTapTagLabel(_:)
        return tagLabel
    }
    
    private func repositionSubviews() {
        numberOfLines = 1
        var lastTagViewHeight: CGFloat = 0
        var sideInset: (left: CGFloat, right: CGFloat) = tagDelegate?.tagField(self, sideInsetAtLine: numberOfLines) ?? (0, 0)
        var x: CGFloat = padding.left + sideInset.left
        var y: CGFloat = padding.top
        
        // - tagLabels position
        
        for tagLabel in tagLabels {
            let tagSize = tagLabel.intrinsicContentSize
            var availableWidth = bounds.width - x - (padding.right + sideInset.right)
            
            if tagSize.width > availableWidth {
                let isFirstTag = lastTagViewHeight == 0
                if !isFirstTag {
                    // new line
                    numberOfLines += 1
                    sideInset = tagDelegate?.tagField(self, sideInsetAtLine: numberOfLines) ?? (0, 0)
                    // reset point
                    x = padding.left + sideInset.left
                    y += lastTagViewHeight + lineBetweenSpace
                    
                    // refresh available width
                    availableWidth = bounds.width - x - (padding.right + sideInset.right)
                }
                
                if tagSize.width > availableWidth {
                    // clipping
                    tagLabel.frame = CGRect(x: x, y: y, width: availableWidth, height: tagSize.height)
                } else {
                    tagLabel.sizeToFit()
                    tagLabel.frame.origin = CGPoint(x: x, y: y)
                }
            } else {
                tagLabel.sizeToFit()
                tagLabel.frame.origin = CGPoint(x: x, y: y)
            }
            x += tagSize.width + tagBetweenSpace
            lastTagViewHeight = tagSize.height
        }
        
        // - textField position
        
        let availableWidth = bounds.width - x - (padding.right + sideInset.right)
        if availableWidth < textFieldMinWidth {
            // textField start next line
            numberOfLines += 1
            sideInset = tagDelegate?.tagField(self, sideInsetAtLine: numberOfLines) ?? (0, 0)
            x = padding.left + sideInset.left
            y += lastTagViewHeight + lineBetweenSpace
            
            textField.sizeToFit()
            textField.frame.size.width = availableWidth
        } else {
            if lastTagViewHeight == 0 {
                textField.sizeToFit()
                lastTagViewHeight = textField.frame.height
            }
            textField.frame.size = CGSize(width: availableWidth, height: lastTagViewHeight)
        }
        textField.frame.origin = CGPoint(x: x, y: y)
        intrinsicContentHeight = y + textField.frame.height - padding.top
        invalidateIntrinsicContentSize()
        
        contentSize = CGSize(width: bounds.width, height: intrinsicContentHeight + padding.top + padding.bottom)
        
        if isScrollEnabled {
            scrollRectToVisible(textField.frame, animated: false)
        }
    }
    
    private func onTapTagLabel(_ tagLabel: TagLabel) {
        if isReadonly {
            tagDelegate?.tagField(self, didSelect: tagLabel.text)
            return
        }
        
        // show keyboard but carret is stil hidden
        textField.becomeFirstResponder()
        isHiddenCaret = true
        
        if !allowMultipleSelection {
            // deselect if allowMultipleSelection is false
            selectedTagLabels.forEach { $0.setSelected(false, animated: true) }
        }
        tagLabel.setSelected(true, animated: true)

        // scroll to selected label
        scrollRectToVisible(tagLabel.frame, animated: true)

        tagDelegate?.tagField(self, didSelect: tagLabel.text)
    }
    
    private func onTapTextField() {
        if !isReadonly {
            deselectAllTags(animated: true)
            becomeFirstResponder()
            isHiddenCaret = false
        }
    }
    
    private func clearTextField() {
        textField.text = nil
    }
    
    private func deselectAllTags(animated: Bool) {
        tagLabels
            .filter { $0.isSelected }
            .forEach { $0.setSelected(false, animated: true) }
    }
    
    private func onDeleteBackward() {
        let selectedLabels = selectedTagLabels
        if !selectedLabels.isEmpty {
            // delete selected tags
            selectedLabels.forEach {
                deleteTagLabel($0)
            }
            return
        }
        
        if let text = textField.text, text.isEmpty && !tagLabels.isEmpty {
            // select last tag if textField is empty
            isHiddenCaret = true
            tagLabels.last?.setSelected(true, animated: true)
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

// MARK: - TextField Properties
extension TagField {
    public var keyboardType: UIKeyboardType {
        get {
            return textField.keyboardType
        }
        set {
            textField.keyboardType = newValue
        }
    }
    
    public var returnKeyType: UIReturnKeyType {
        get {
            return textField.returnKeyType
        }
        set {
            textField.returnKeyType = newValue
        }
    }
    
    public var spellCheckingType: UITextSpellCheckingType {
        get {
            return textField.spellCheckingType
        }
        set {
            textField.spellCheckingType = newValue
        }
    }
    
    public var autocapitalizationType: UITextAutocapitalizationType {
        get {
            return textField.autocapitalizationType
        }
        set {
            textField.autocapitalizationType = newValue
        }
    }
    
    public var autocorrectionType: UITextAutocorrectionType {
        get {
            return textField.autocorrectionType
        }
        set {
            textField.autocorrectionType = newValue
        }
    }
    
    public var enablesReturnKeyAutomatically: Bool {
        get {
            return textField.enablesReturnKeyAutomatically
        }
        set {
            textField.enablesReturnKeyAutomatically = newValue
        }
    }
    
    public var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    @available(iOS, unavailable)
    override open var inputAccessoryView: UIView? {
        return super.inputAccessoryView
    }
    
    open var inputFieldAccessoryView: UIView? {
        get {
            return textField.inputAccessoryView
        }
        set {
            textField.inputAccessoryView = newValue
        }
    }
}


extension TagField: UITextFieldDelegate {
    // MARK: - UITextFieldDelegate
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !isHiddenCaret else {
            return false
        }
        
        deselectAllTags(animated: true)
        if isScrollEnabled {
            scrollRectToVisible(textField.frame, animated: true)
        }
        
        if string == delimiter {
            tokenizeTextField()
            return false
        }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard !isHiddenCaret else {
            return false
        }
        
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
        deselectAllTags(animated: true)
        tagDelegate?.tagFieldDidBeginEditing(self)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        tagDelegate?.tagFieldDidEndEditing(self)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        tagDelegate?.tagFieldDidEndEditing(self, reason: reason)
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        guard !isHiddenCaret else {
            return false
        }
        return tagDelegate?.tagFieldShouldClear(self) ?? false
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return tagDelegate?.tagFieldShouldEndEditing(self) ?? true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return tagDelegate?.tagFieldShouldBeginEditing(self) ?? true
    }
}
