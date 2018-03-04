//
//  ViewController.swift
//  Demo
//
//  Created by Yuma Matsune on 2018/01/25.
//  Copyright © 2018年 matsune. All rights reserved.
//

import UIKit
import TagField

final class CustomTagView: TagView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override init(text: String?) {
        super.init(text: text)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        deleteButton = UIButton()
        deleteButton?.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let r: CGFloat = 15
        deleteButton?.frame = CGRect(x: bounds.width - r/2, y: -r/2, width: r, height: r)
    }
}


final class ViewController: UIViewController {

    @IBOutlet weak var tagField: TagField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.didTapView(recognizer:))))

        let sharpLabel = UILabel(frame: CGRect(x: 12, y: 10, width: 25, height: 28))
        sharpLabel.textAlignment = .center
        sharpLabel.text = "♯"
        sharpLabel.font = UIFont.systemFont(ofSize: 24)
        tagField.addSubview(sharpLabel)

        tagField.registerTagView(CustomTagView.self)
        tagField.placeholder = "add tag..."
        tagField.tagDelegate = self
        tagField.padding.top = 8
        tagField.lineBetweenSpace = 13
        tagField.dataSource = self
        
        tagField.append(tags: ["tag1", "tag2"])
        tagField.append(tag: "tagtagtagtag")
        tagField.append(tag: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.")
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
    func tagField(_ tagField: TagField, didSelect tag: String) {
        print("didSelect \(String(describing: tag))")
    }
    
    func tagField(_ tagField: TagField, didChange tags: [String]) {
        print("didChange tags: \(tags)")
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
    
    func tagField(_ tagField: TagField, sideInsetAtLine line: Int) -> (left: CGFloat, right: CGFloat) {
        if line == 1 {
            return (30, 0)
        }
        return (0, 0)
    }
}

extension ViewController: TagFieldDataSource {
    // require
    func tagField(_ tagField: TagField, styleForTagAt index: Int) -> TagStyle {
        return TagStyle {
            $0.normalTextColor = .white
            $0.normalBackgroundColor = index == 0 ? UIColor(red: 0.2, green: 0.48, blue: 0.84, alpha: 1.0) : .orange
            $0.cornerRadius = 7.0
            $0.padding = UIEdgeInsets(top: 5, left: 5, bottom: 6, right: 5)
        }
    }
    
    // optional
    func tagField(_ tagField: TagField, interTagSpacingAt index: Int) -> CGFloat {
        return index == 0 ? 10 : 5
    }
}
