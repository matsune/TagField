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
    private let label = PaddingLabel()
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
        return label.intrinsicContentSize
    }
    
    public var padding: UIEdgeInsets {
        set { label.padding = newValue }
        get { return label.padding }
    }
    
    public var font: UIFont! {
        set { label.font = newValue }
        get { return label.font }
    }
    
    public var text: String? {
        set { label.text = newValue }
        get { return label.text }
    }
    
    public var cornerRadius: CGFloat {
        set { label.layer.cornerRadius = newValue }
        get { return label.layer.cornerRadius }
    }
    
    // MARK: - Initializer
    override public init(frame: CGRect) {
        super.init(frame: frame)
        label.frame = frame
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public init(text: String?) {
        super.init(frame: .zero)
        label.text = text
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TagView.handleTap(_:)))
        label.addGestureRecognizer(tapGesture)
        label.layer.masksToBounds = true
        label.isUserInteractionEnabled = true
        addSubview(label)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        onTapLabel?(self)
    }
    
    @objc
    private func onClickDelete(_ sender: UIButton) {
        onTapDelete?(self)
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
    
    // MARK: - Private Methods
    private func updateView(animated: Bool) {
        let duration = animated ? animationDuration : 0.0
        UIView.transition(with: label,
                          duration: duration,
                          options: .transitionCrossDissolve,
                          animations: updateContent, completion: nil)
    }
    
    private func updateContent() {
        if isSelected {
            label.backgroundColor = self.selectedBackgroundColor
            label.textColor = self.selectedTextColor
            deleteButton?.alpha = 1.0
        } else {
            label.backgroundColor = self.normalBackgroundColor
            label.textColor = self.normalTextColor
            deleteButton?.alpha = 0.0
        }
    }
}

extension TagView {
    public func apply(_ style: TagStyle) {
        style.apply(to: self)
    }
}
