//
//  TagFieldDataSource.swift
//  TagField
//
//  Created by Yuma Matsune on 2018/03/02.
//  Copyright © 2018年 matsune. All rights reserved.
//

import Foundation

public protocol TagFieldDataSource: class {
    func tagField(_ tagField: TagField, classForTagAt index: Int) -> TagView.Type
    func tagField(_ tagField: TagField, styleForTagAt index: Int) -> TagStyle
    func tagField(_ tagField: TagField, interTagSpacingAt index: Int) -> CGFloat
    func tagField(_ tagField: TagField, sideInsetAtLine line: Int) -> (left: CGFloat, right: CGFloat)
}

public extension TagFieldDataSource {
    func tagField(_ tagField: TagField, styleForTagAt index: Int) -> TagStyle {
        return TagStyle {
            $0.padding = UIEdgeInsets(top: 4, left: 2, bottom: 3, right: 4)
            $0.normalTextColor = .white
            $0.normalBackgroundColor = .orange
            $0.selectedTextColor = .white
            $0.selectedBackgroundColor = .red
            $0.cornerRadius = 8.0
        }
    }
    
    func tagField(_ tagField: TagField, classForTagAt index: Int) -> TagView.Type {
        return TagView.self
    }
    
    func tagField(_ tagField: TagField, interTagSpacingAt index: Int) -> CGFloat {
        return 2.0
    }
    
    func tagField(_ tagField: TagField, sideInsetAtLine line: Int) -> (left: CGFloat, right: CGFloat) {
        return (left: 0, right: 0)
    }
}
