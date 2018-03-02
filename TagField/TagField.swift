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
    weak open var dataSource: TagFieldDataSource?
    
    private var tagViews: [TagView] = []
    
    public let textField = TagFieldContentTextField()
    
    // MARK: - Stored properties
    open var delimiter: String?
    
    open var lineBetweenSpace: CGFloat = 3.0
    
    open var allowMultipleSelection = false
    
    open var textFieldMinWidth: CGFloat = 20
    
    open var yOffsetForCarret: CGFloat = 0
    
    open var padding = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10) {
        didSet {
            setNeedsLayout()
        }
    }
    
    open var font: UIFont? {
        didSet {
            textField.font = font
        }
    }
    
    open var isReadonly = false {
        didSet {
            if isReadonly {
                textField.resignFirstResponder()
                deselectAllTags(animated: true)
            }
            textField.isEnabled = !isReadonly
            textField.isHiddenPlaceholder = isReadonly
            repositionSubviews()
        }
    }
    
    public private(set) var numberOfLines = 1
    
    private var intrinsicContentHeight: CGFloat = 50
    
    private var isHiddenCaret = true {
        didSet {
            textField.isHiddenCaret = isHiddenCaret
        }
    }
    
    private var TagViewClassType = TagView.self
    
    private var defaultStyle: TagStyle {
        return TagStyle {
            $0.padding = UIEdgeInsets(top: 4, left: 2, bottom: 3, right: 4)
            $0.normalTextColor = .white
            $0.normalBackgroundColor = .orange
            $0.selectedTextColor = .white
            $0.selectedBackgroundColor = .red
            $0.cornerRadius = 8.0
        }
    }
    
    // MARK: - Computed Properties
    public var tags: [String] {
        return tagViews.flatMap { $0.text }
    }
    
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width - (padding.left + padding.right), height: intrinsicContentHeight)
    }
    
    private var selectedTagViews: [TagView] {
        return tagViews.filter { $0.isSelected }
    }
    
    open var placeholder: String? {
        set { textField.placeholder = newValue}
        get { return textField.placeholder }
    }
    
    open var placeholderImageView: UIImageView?
    
    public func setPlaceholderImage(_ image: UIImage?) {
        if let newValue = image {
            if placeholderImageView == nil {
                placeholderImageView = UIImageView()
                addSubview(placeholderImageView!)
            }
            placeholderImageView?.image = newValue
            placeholderImageView?.sizeToFit()
        } else {
            placeholderImageView?.removeFromSuperview()
        }
    }
    
    // MARK: - Initializer
    override public init(frame: CGRect) {
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
        
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(TagField.textFieldDidChange(notification:)),
                         name: Notification.Name.UITextFieldTextDidChange,
                         object: textField)
    }
    
    // MARK: - Public Methods
    open override func layoutSubviews() {
        super.layoutSubviews()
        repositionSubviews()
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
    
    public func registerTagView(_ classType: TagView.Type) {
        self.TagViewClassType = classType
    }
    
    public func append(tag: String) {
        if isExistTag(tag) {
            clearTextField()
            return
        }
        
        let tagView = createTagView(text: tag)
        addSubview(tagView)
        tagViews.append(tagView)
        repositionSubviews()
        
        tagDelegate?.tagField(self, didChange: tags)
    }
    
    public func append(tags: [String]) {
        tags
            .filter { !isExistTag($0) }
            .map { createTagView(text: $0) }
            .forEach {
                addSubview($0)
                tagViews.append($0)
            }
        repositionSubviews()
        
        tagDelegate?.tagField(self, didChange: tags)
    }
    
    public func remove(tag: String) {
        if let tagView = tagViews.first(where: {$0.text == tag}) {
            deleteTagView(tagView)
            tagDelegate?.tagField(self, didChange: tags)
        }
    }
    
    public func removeTags() {
        tagViews.forEach { $0.removeFromSuperview() }
        tagViews.removeAll()
        repositionSubviews()
        tagDelegate?.tagField(self, didChange: [])
    }
    
    public func setTags(_ tags: [String]) {
        tagViews.forEach { $0.removeFromSuperview() }
        tagViews.removeAll()
        tags.map { createTagView(text: $0) }
            .forEach {
                addSubview($0)
                tagViews.append($0)
        }
        repositionSubviews()
        tagDelegate?.tagField(self, didChange: tags)
    }
    
    // MARK: - Private methods
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        if !isReadonly {
            deselectAllTags(animated: true)
            becomeFirstResponder()
        }
    }
    
    private func createTagView(text: String) -> TagView {
        let tagView = TagViewClassType.init()
        tagView.text = text
        tagView.font = font
        tagView.onTapLabel = onTapTagLabel
        tagView.onTapDelete = onTapTagDelete
        return tagView
    }
    
    private func isExistTag(_ tag: String) -> Bool {
        return tagViews.contains(where: { $0.text == tag })
    }
    
    private lazy var tagViewHeight: CGFloat = {
        return createTagView(text: "a").intrinsicContentSize.height
    }()
    
    public func repositionSubviews() {
        numberOfLines = 1
        
        var sideInset: (left: CGFloat, right: CGFloat) = tagDelegate?.tagField(self, sideInsetAtLine: numberOfLines) ?? (0, 0)
        var x: CGFloat = padding.left + sideInset.left
        var y: CGFloat = padding.top
        
        // - tagLabels position
        for i in 0..<tagViews.count {
            let tagSize = tagViews[i].intrinsicContentSize
            var availableWidth = bounds.width - x - (padding.right + sideInset.right)
            
            if tagSize.width > availableWidth {
                if i != 0 {
                    // new line
                    numberOfLines += 1
                    sideInset = tagDelegate?.tagField(self, sideInsetAtLine: numberOfLines) ?? (0, 0)
                    // reset point
                    x = padding.left + sideInset.left
                    y += tagViewHeight + lineBetweenSpace
                    
                    // refresh available width
                    availableWidth = bounds.width - x - (padding.right + sideInset.right)
                }
                
                if tagSize.width > availableWidth {
                    // clipping
                    tagViews[i].frame = CGRect(x: x, y: y, width: availableWidth, height: tagSize.height)
                } else {
                    tagViews[i].frame = CGRect(origin: CGPoint(x: x, y: y), size: tagSize)
                }
            } else {
                tagViews[i].frame = CGRect(origin: CGPoint(x: x, y: y), size: tagSize)
            }
            
            tagViews[i].apply(dataSource?.tagField(self, styleForTagAt: i) ?? defaultStyle)
            
            x += tagSize.width + (dataSource?.tagField(self, interTagSpacingAt: i) ?? 2.0)
        }
        
        // - textField position
        if !isReadonly {
            var availableWidth = bounds.width - x - (padding.right + sideInset.right)
            if availableWidth < textFieldMinWidth {
                // textField start next line
                numberOfLines += 1
                sideInset = tagDelegate?.tagField(self, sideInsetAtLine: numberOfLines) ?? (0, 0)
                x = padding.left + sideInset.left
                y += tagViewHeight + lineBetweenSpace
                availableWidth = bounds.width - x - (padding.right + sideInset.right)
            }
            y += yOffsetForCarret
            textField.frame.size = CGSize(width: availableWidth, height: tagViewHeight)
            textField.frame.origin = CGPoint(x: x, y: y)
        }
        
        textField.isHiddenPlaceholder = !tags.isEmpty || placeholderImageView != nil
        placeholderImageView?.frame.origin = CGPoint(x: x + 5, y: y)
        placeholderImageView?.isHidden = !tags.isEmpty

        intrinsicContentHeight = y + tagViewHeight - padding.top
        invalidateIntrinsicContentSize()
        
        contentSize = CGSize(width: bounds.width, height: intrinsicContentHeight + padding.top + padding.bottom)
    }
    
    private func onTapTagLabel(_ tagView: TagView) {
        if isReadonly {
            tagDelegate?.tagField(self, didSelect: tagView.text ?? "")
            return
        }
        
        // show keyboard but carret is stil hidden
        textField.becomeFirstResponder()
        isHiddenCaret = true
        
        if !allowMultipleSelection {
            // deselect if allowMultipleSelection is false
            selectedTagViews.forEach { $0.setSelected(false, animated: true) }
        }
        tagView.setSelected(true, animated: true)

        tagDelegate?.tagField(self, didSelect: tagView.text ?? "")
    }
    
    private func onTapTagDelete(_ tagView: TagView) {
        deleteTagView(tagView)
        tagDelegate?.tagField(self, didChange: tags)
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
        tagViews
            .filter { $0.isSelected }
            .forEach { $0.setSelected(false, animated: true) }
    }
    
    private func onDeleteBackward() {
        let selectedViews = selectedTagViews
        if !selectedViews.isEmpty {
            // delete selected tags
            selectedTagViews.forEach {
                deleteTagView($0)
            }
            tagDelegate?.tagField(self, didChange: tags)
            tagDelegate?.tagFieldDidChangeText(self)
            return
        }
        
        if let text = textField.text, text.isEmpty && !tagViews.isEmpty {
            // select last tag if textField is empty
            isHiddenCaret = true
            tagViews.last?.setSelected(true, animated: true)
        }
    }
    
    private func deleteTagView(_ tagView: TagView) {
        tagView.removeFromSuperview()
        if let index = tagViews.index(of: tagView) {
            tagViews.remove(at: index)
        }
        repositionSubviews()
        becomeFirstResponder()
    }
}

// MARK: - TextField Properties
extension TagField {
    public var keyboardType: UIKeyboardType {
        set { textField.keyboardType = newValue }
        get { return textField.keyboardType }
    }
    
    public var returnKeyType: UIReturnKeyType {
        set { textField.returnKeyType = newValue }
        get { return textField.returnKeyType }
    }
    
    public var spellCheckingType: UITextSpellCheckingType {
        set { textField.spellCheckingType = newValue }
        get { return textField.spellCheckingType }
    }
    
    public var autocapitalizationType: UITextAutocapitalizationType {
        set { textField.autocapitalizationType = newValue }
        get { return textField.autocapitalizationType }
    }
    
    public var autocorrectionType: UITextAutocorrectionType {
        set { textField.autocorrectionType = newValue }
        get { return textField.autocorrectionType }
    }
    
    public var enablesReturnKeyAutomatically: Bool {
        set { textField.enablesReturnKeyAutomatically = newValue }
        get { return textField.enablesReturnKeyAutomatically }
    }
    
    public var text: String? {
        set { textField.text = newValue }
        get { return textField.text }
    }
    
    @available(iOS, unavailable)
    override open var inputAccessoryView: UIView? {
        return super.inputAccessoryView
    }
    
    open var inputFieldAccessoryView: UIView? {
        set { textField.inputAccessoryView = newValue }
        get { return textField.inputAccessoryView }
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
    
    @objc
    func textFieldDidChange(notification: Notification) {
        placeholderImageView?.isHidden = !tags.isEmpty || !(textField.text?.isEmpty ?? false)
        tagDelegate?.tagFieldDidChangeText(self)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard !isHiddenCaret else {
            return false
        }
        
        tokenizeTextField()
        if isScrollEnabled {
            scrollRectToVisible(textField.frame, animated: false)
        }

        return tagDelegate?.tagFieldShouldReturn(self) ?? true
    }
    
    private func tokenizeTextField() {
        if let text = textField.text, !text.isEmpty {
            append(tag: text)
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
    
    @available(iOS 10.0, *)
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
