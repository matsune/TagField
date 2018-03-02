//
//  TagStyle.swift
//  TagField
//
//  Created by Yuma Matsune on 2018/03/02.
//  Copyright © 2018年 matsune. All rights reserved.
//

import Foundation

public struct TagStyle {
    
    public let style: (TagView) -> Void
    
    public init(_ style: @escaping (TagView) -> Void) {
        self.style = style
    }
    
    public func apply(to view: TagView) {
        style(view)
    }
}
