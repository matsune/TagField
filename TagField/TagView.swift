//
//  TagView.swift
//  TagField
//
//  Created by Yuma Matsune on 2018/01/26.
//  Copyright © 2018年 matsune. All rights reserved.
//

import Foundation

final class TagView: UIView {

    // MARK: - Subviews
    private let label = PaddingLabel()
    
    // MARK: - Stored Properties
    public private(set) var isSelected = false

    public var animationDuration: TimeInterval = 0.3

    var onTap: ((TagView) -> Void)?
    
    // MARK: - Computed Properties
    override var intrinsicContentSize: CGSize {
        return label.intrinsicContentSize
    }
    
    public var padding: UIEdgeInsets {
        set { label.padding = newValue }
        get { return label.padding }
    }
    
    var font: UIFont! {
        set { label.font = newValue }
        get { return label.font }
    }
    
    var text: String? {
        set { label.text = newValue }
        get { return label.text }
    }
    
    public var cornerRadius: CGFloat {
        set { label.layer.cornerRadius = newValue }
        get { return label.layer.cornerRadius }
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.frame = frame
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init(text: String?) {
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        onTap?(self)
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
        } else {
            label.backgroundColor = self.normalBackgroundColor
            label.textColor = self.normalTextColor
        }
    }
}
