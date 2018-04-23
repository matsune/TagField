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
    func tagField(_ tagField: TagField, styleForTagAt index: Int) -> TagStyle?
    func tagField(_ tagField: TagField, interTagSpacingAt index: Int) -> CGFloat
    func tagField(_ tagField: TagField, sideInsetAtLine line: Int) -> (left: CGFloat, right: CGFloat)
}

public extension TagFieldDataSource {
    func tagField(_ tagField: TagField, styleForTagAt index: Int) -> TagStyle? {
        return nil
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
