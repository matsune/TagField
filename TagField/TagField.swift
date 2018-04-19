//
//  TagField.swift
//  Demo
//
//  Created by Yuma Matsune on 2018/01/25.
//  Copyright © 2018年 matsune. All rights reserved.
//

import Foundation
import UIKit

final public class TagField: UIScrollView {
    
    weak public var tagDelegate: TagFieldDelegate?
    weak public var dataSource: TagFieldDataSource?
    
    public let textField = TagFieldContentTextField()
    
    // MARK: - Stored properties
    public var tagViews: [TagView] = []
    
    public var delimiter: String?
    
    public var lineBetweenSpace: CGFloat = 3.0
    
    public var allowMultipleSelection = false
    
    public var textFieldMinWidth: CGFloat = 20
    
    public var padding = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10) {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var font: UIFont? {
        didSet {
            textField.font = font
        }
    }
    
    public var isReadonly = false {
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
    
    public var numberOfLines = 0
    
    private var intrinsicContentHeight: CGFloat = 50
    
    private var isHiddenCaret = true {
        didSet {
            textField.isHiddenCaret = isHiddenCaret
        }
    }
    
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
        return tagViews.compactMap { $0.text }
    }
    
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: intrinsicContentHeight)
    }
    
    private var selectedTagViews: [TagView] {
        return tagViews.filter { $0.isSelected }
    }
    
    open var placeholder: String? {
        set { textField.placeholder = newValue}
        get { return textField.placeholder }
    }
    
    public var placeholderImageView: UIImageView?
    
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
    public override func layoutSubviews() {
        super.layoutSubviews()
        repositionSubviews()
    }
    
    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        isHiddenCaret = false
        return textField.becomeFirstResponder()
    }
    
    @discardableResult
    public override func resignFirstResponder() -> Bool {
        deselectAllTags(animated: true)
        tokenizeTextField()
        isHiddenCaret = true
        return textField.resignFirstResponder()
    }
    
    public func append(tag: String) {
        if isExistTag(tag) {
            clearTextField()
            return
        }
        
        let tagView = createTagView(text: tag, index: tags.count)
        addSubview(tagView)
        tagViews.append(tagView)
        repositionSubviews()
        
        tagDelegate?.tagField(self, didChange: tags)
    }
    
    public func append(tags: [String]) {
        for i in 0..<tags.filter( { !isExistTag($0) }).count {
            let tagView = createTagView(text: tags[i], index: tagViews.count)
            addSubview(tagView)
            tagViews.append(tagView)
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
        for i in 0..<tags.count {
            let tagView = createTagView(text: tags[i], index: i)
            addSubview(tagView)
            tagViews.append(tagView)
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
    
    private func createTagView(text: String, index: Int) -> TagView {
        let tagView = (dataSource?.tagField(self, classForTagAt: index) ?? TagView.self).init()
        tagView.text = text
        tagView.font = font
        tagView.onTapLabel = onTapTagLabel
        tagView.onTapDelete = onTapTagDelete
        return tagView
    }
    
    private func isExistTag(_ tag: String) -> Bool {
        return tagViews.contains(where: { $0.text == tag })
    }
    
    public func repositionSubviews() {
        var line = 1
        var sideInset: (left: CGFloat, right: CGFloat) = dataSource?.tagField(self, sideInsetAtLine: line) ?? (0, 0)
        var x: CGFloat = padding.left + sideInset.left
        var y: CGFloat = padding.top
        
        // - tagLabels position
        for i in 0..<tagViews.count {
            tagViews[i].apply(dataSource?.tagField(self, styleForTagAt: i) ?? defaultStyle)
            
            let tagSize = tagViews[i].intrinsicContentSize
            var availableWidth = bounds.width - x - (padding.right + sideInset.right)
            
            if tagSize.width > availableWidth {
                if i != 0 {
                    // new line
                    line += 1
                    if isReadonly && numberOfLines > 0 && numberOfLines < line {
                        // clip label if over `numberOflines`
                        let minimumWidth: CGFloat = 10
                        if availableWidth > minimumWidth {
                            tagViews[i].frame = CGRect(x: x, y: y, width: availableWidth, height: tagSize.height)
                        }
                        break
                    } else {
                        sideInset = dataSource?.tagField(self, sideInsetAtLine: line) ?? (0, 0)
                        // reset point
                        x = padding.left + sideInset.left
                        y = tagViews[i - 1].frame.maxY + lineBetweenSpace
                        
                        // refresh available width
                        availableWidth = bounds.width - x - (padding.right + sideInset.right)
                    }
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
            
            intrinsicContentHeight = tagViews[i].frame.maxY
            
            x += tagSize.width + (dataSource?.tagField(self, interTagSpacingAt: i) ?? 2.0)
        }
        
        // - textField position
        if !isReadonly {
            var availableWidth = bounds.width - x - (padding.right + sideInset.right)
            if availableWidth < textFieldMinWidth {
                // textField start next line
                line += 1
                sideInset = dataSource?.tagField(self, sideInsetAtLine: line) ?? (0, 0)
                x = padding.left + sideInset.left
                y = (tagViews.last?.frame.maxY ?? 0) + lineBetweenSpace
                availableWidth = bounds.width - x - (padding.right + sideInset.right)
            }
            let height: CGFloat
            if let last = tagViews.last {
                height = last.intrinsicContentSize.height
            } else {
                let virtualTagView = createTagView(text: "a", index: 0)
                virtualTagView.apply(dataSource?.tagField(self, styleForTagAt: 0) ?? defaultStyle)
                height = virtualTagView.intrinsicContentSize.height
            }
            textField.frame.size = CGSize(width: availableWidth, height: height)
            textField.frame.origin = CGPoint(x: x, y: y)
            intrinsicContentHeight = textField.frame.maxY
        }
        
        textField.isHiddenPlaceholder = !tags.isEmpty || !(text?.isEmpty ?? false) || placeholderImageView != nil
        if placeholderImageView != nil {
            placeholderImageView?.frame.origin = CGPoint(x: x + 5, y: y)
            placeholderImageView?.isHidden = !tags.isEmpty || !(text?.isEmpty ?? false)
            intrinsicContentHeight = placeholderImageView!.frame.maxY
        }

        intrinsicContentHeight += padding.bottom
        invalidateIntrinsicContentSize()
        
        contentSize = CGSize(width: bounds.width, height: intrinsicContentHeight)
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
