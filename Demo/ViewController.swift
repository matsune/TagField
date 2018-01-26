//
//  ViewController.swift
//  Demo
//
//  Created by Yuma Matsune on 2018/01/25.
//  Copyright © 2018年 matsune. All rights reserved.
//

import UIKit
import TagField

final class ViewController: UIViewController {

    let tagField = TagField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        
        tagField.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 200)
        tagField.placeholder = "add tag..."
        
        view.addSubview(tagField)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.didTapView(recognizer:))))
        
        tagField.addTag(text: "tag1")
        tagField.addTag(text: "tag2")
        tagField.addTag(text: "tagtagtagtag")
        tagField.addTag(text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tagField.becomeFirstResponder()
    }
    
    @objc
    func didTapView(recognizer: UITapGestureRecognizer) {
        tagField.resignFirstResponder()
    }
}

