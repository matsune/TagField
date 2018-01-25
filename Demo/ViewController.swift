//
//  ViewController.swift
//  Demo
//
//  Created by Yuma Matsune on 2018/01/25.
//  Copyright © 2018年 matsune. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    let tagField = TagField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
     
        tagField.frame = CGRect(x: 12, y: 50, width: view.bounds.width - 24, height: 100)
        tagField.backgroundColor = .white
        tagField.padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tagField.addTag(text: "aaa")
        tagField.addTag(text: "aa")
        tagField.addTag(text: "aaaaaaaaaaaaaaaaa")
        tagField.addTag(text: "aaadasfdfsads")
        tagField.addTag(text: "aaaddd")
        tagField.tagBackgroundColor = .orange
        
        view.addSubview(tagField)
    }

}

