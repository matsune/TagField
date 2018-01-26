//
//  TagView.swift
//  TagField
//
//  Created by Yuma Matsune on 2018/01/26.
//  Copyright © 2018年 matsune. All rights reserved.
//

import Foundation

final class TagView: UIView {
    
    let label: TagLabel
    
    init(label: TagLabel) {
        self.label = label
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .clear
        addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    
//    var padding: UIEdgeInsets {
//        set { tagLabel.padding = newValue }
//        get { return tagLabel.padding }
//    }
//
//    var normalTextColor: UIColor {
//        set { tagLabel.normalTextColor = newValue }
//        get { return tagLabel.normalTextColor }
//    }
//
//    var normalBackgroundColor: UIColor {
//        set { tagLabel.normalBackgroundColor = newValue }
//        get { return tagLabel.normalBackgroundColor }
//    }
//
//    var selectedTextColor: UIColor {
//        set { tagLabel.normalBackgroundColor = newValue }
//        get { return tagLabel.normalBackgroundColor }
//    }
//
//    var selectedBackgroundColor: UIColor {
//        set { tagLabel.selectedBackgroundColor = newValue }
//        get { return tagLabel.selectedBackgroundColor }
//    }
//
//    var cornerRadius: CGFloat {
//        set { tagLabel.selectedBackgroundColor = newValue }
//        get { return tagLabel.selectedBackgroundColor }
//    }
}
