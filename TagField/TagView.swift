//
//  TagView.swift
//  TagField
//
//  Created by Yuma Matsune on 2018/01/26.
//  Copyright © 2018年 matsune. All rights reserved.
//

import Foundation

open class TagView: UIView {

    // MARK: - Subviews
    public let titleLabel = PaddingLabel()
    
    public var deleteButton: UIButton? {
        didSet {
            oldValue?.removeFromSuperview()
            if let button = deleteButton {
                button.alpha = 0.0
                button.addTarget(self, action: #selector(TagView.onClickDelete(_:)), for: .touchUpInside)
                addSubview(button)
            }
        }
    }
    
    // MARK: - Stored Properties
    public private(set) var isSelected = false

    public var animationDuration: TimeInterval = 0.3

    public var onTapLabel: ((TagView) -> Void)?
    public var onTapDelete: ((TagView) -> Void)?
    
    // MARK: - Computed Properties
    override open var intrinsicContentSize: CGSize {
        return titleLabel.intrinsicContentSize
    }
    
    public var padding: UIEdgeInsets {
        set { titleLabel.padding = newValue }
        get { return titleLabel.padding }
    }
    
    public var font: UIFont! {
        set { titleLabel.font = newValue }
        get { return titleLabel.font }
    }
    
    public var text: String? {
        set { titleLabel.text = newValue }
        get { return titleLabel.text }
    }
    
    public var cornerRadius: CGFloat {
        set { titleLabel.layer.cornerRadius = newValue }
        get { return titleLabel.layer.cornerRadius }
    }
    
    public var textAlignment: NSTextAlignment {
        set { titleLabel.textAlignment = newValue }
        get { return titleLabel.textAlignment}
    }
    
    public var lineBreakMode: NSLineBreakMode {
        set { titleLabel.lineBreakMode = newValue }
        get { return titleLabel.lineBreakMode }
    }
    
    // MARK: - Initializer
    public init(text: String?) {
        super.init(frame: .zero)
        titleLabel.text = text
        setup()
    }
    
    required public init() {
        super.init(frame: .zero)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TagView.handleTap(_:)))
        titleLabel.addGestureRecognizer(tapGesture)
        titleLabel.layer.masksToBounds = true
        titleLabel.isUserInteractionEnabled = true
        addSubview(titleLabel)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = bounds
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        onTapLabel?(self)
    }
    
    @objc
    private func onClickDelete(_ sender: UIButton) {
        if isSelected {
            onTapDelete?(self)
        }
    }

    
    // MARK: - Label Properties
    public var normalTextColor: UIColor = .black {
        didSet {
            updateView(animated: false)
        }
    }
    
    public var normalBackgroundColor: UIColor = .orange {
        didSet {
            updateView(animated: false)
        }
    }
    
    public var selectedTextColor: UIColor = .white {
        didSet {
            updateView(animated: false)
        }
    }
    
    public var selectedBackgroundColor: UIColor = .orange {
        didSet {
            updateView(animated: false)
        }
    }
    
    // MARK: - Public Methods
    public func setSelected(_ selected: Bool, animated: Bool) {
        isSelected = selected
        updateView(animated: animated)
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if isDeleteButton(inside: point, with: event) {
            return deleteButton
        }
        return view
    }
    
    // MARK: - Private Methods
    private func updateView(animated: Bool) {
        let duration = animated ? animationDuration : 0.0
        UIView.transition(with: titleLabel,
                          duration: duration,
                          options: .transitionCrossDissolve,
                          animations: updateContent, completion: nil)
    }
    
    private func updateContent() {
        if isSelected {
            titleLabel.backgroundColor = self.selectedBackgroundColor
            titleLabel.textColor = self.selectedTextColor
            deleteButton?.alpha = 1.0
        } else {
            titleLabel.backgroundColor = self.normalBackgroundColor
            titleLabel.textColor = self.normalTextColor
            deleteButton?.alpha = 0.0
        }
    }
    
    private func isDeleteButton(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let p = deleteButton?.convert(point, from: self),
            deleteButton?.point(inside: p, with: event) ?? false {
            return true
        }
        return false
    }
}

extension TagView {
    public func apply(_ style: TagStyle) {
        style.apply(to: self)
    }
}
