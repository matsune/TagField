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

    @IBOutlet weak var tagField: TagField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.didTapView(recognizer:))))

        let sharpLabel = UILabel(frame: CGRect(x: 12, y: 7, width: 25, height: 28))
        sharpLabel.textAlignment = .center
        sharpLabel.text = "♯"
        sharpLabel.font = UIFont.systemFont(ofSize: 24)
        tagField.addSubview(sharpLabel)
        
        tagField.placeholder = "add tag..."
        tagField.tagDelegate = self
        tagField.tagDataSource = self
        
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
    
    @IBAction func readOnlyValueChanged(_ sender: UISwitch) {
        tagField.isReadonly = sender.isOn
    }
}

extension ViewController: TagFieldDelegate {
    func tagField(_ tagField: TagField, didSelect tag: String?) {
        print("didSelect \(String(describing: tag))")
    }
    
    func tagFieldShouldReturn(_ tagField: TagField) -> Bool {
        print("shouldReturn")
        return true
    }
    
    func tagFieldDidBeginEditing(_ tagField: TagField) {
        print("didBeginEditing")
    }
    
    func tagFieldDidEndEditing(_ tagField: TagField) {
        print("didEndEditing")
    }
    
    func tagFieldDidEndEditing(_ tagField: TagField, reason: UITextFieldDidEndEditingReason) {
        print("didEndEditing reason: \(reason)")
    }
    
    func tagFieldShouldClear(_ tagField: TagField) -> Bool {
        print("shouldClear")
        return false
    }
    
    func tagFieldShouldBeginEditing(_ tagField: TagField) -> Bool {
        print("shouldBeginEditing")
        return true
    }
    
    func tagFieldShouldEndEditing(_ tagField: TagField) -> Bool {
        print("shouldEndEditing")
        return true
    }
}

extension ViewController: TagFieldDataSource {
    func tagField(_ tagField: TagField, sideInsetAtLine line: Int) -> (left: CGFloat, right: CGFloat) {
        if line == 1 {
            return (30, 0)
        }
        return (0, 0)
    }
}
