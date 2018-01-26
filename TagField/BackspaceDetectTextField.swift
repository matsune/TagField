//
//  BackspaceDetectTextField.swift
//  Demo
//
//  Created by Yuma Matsune on 2018/01/26.
//  Copyright © 2018年 matsune. All rights reserved.
//

import Foundation
import UIKit

final class BackspaceDetectTextField: UITextField {
    
    var onDeleteBackward: (() -> Void)?
    
    override func deleteBackward() {
        onDeleteBackward?()
        super.deleteBackward()
    }
}
