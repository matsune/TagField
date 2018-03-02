//
//  TagFieldDataSource.swift
//  TagField
//
//  Created by Yuma Matsune on 2018/03/02.
//  Copyright © 2018年 matsune. All rights reserved.
//

import Foundation

public protocol TagFieldDataSource: class {
    func tagField(_ tagField: TagField, styleForTagAt index: Int) -> TagStyle
    func tagField(_ tagField: TagField, interTagSpacingAt index: Int) -> CGFloat
}

extension TagFieldDataSource {
    func tagField(_ tagField: TagField, interTagSpacingAt index: Int) -> CGFloat {
        return 2.0
    }
}
