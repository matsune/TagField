//
//  ViewController.swift
//  Demo
//
//  Created by Yuma Matsune on 2018/01/25.
//  Copyright © 2018年 matsune. All rights reserved.
//

import UIKit

open class PaddingLabel: UILabel {
    
    open var padding = UIEdgeInsets.zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    open override func drawText(in rect: CGRect) {
        let newRect = UIEdgeInsetsInsetRect(rect, padding)
        super.drawText(in: newRect)
    }
    
    open override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.width += (padding.left + padding.right)
        intrinsicContentSize.height += (padding.top + padding.bottom)
        intrinsicContentSize.height += fontDescent
        return intrinsicContentSize
    }
    
    private var fontDescent: CGFloat {
        let f = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        let descentHeight = ceilf(Float(CTFontGetDescent(f)))
        return CGFloat(descentHeight)
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let fittingSize = CGSize(width: size.width - (padding.left + padding.right),
                                 height: size.height - (padding.top + padding.bottom))
        let labelSize = super.sizeThatFits(fittingSize)
        return CGSize(width: labelSize.width + (padding.left + padding.right),
                      height: labelSize.height + (padding.top + padding.bottom))
    }

    open func sizeToFit(_ size: CGSize) -> CGSize {
        if intrinsicContentSize.width > size.width {
            return CGSize(width: size.width,
                          height: self.frame.size.height)
        }
        return intrinsicContentSize
    }
}

class TagView: PaddingLabel {
    
}

extension TagField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == delimiter {
            tokenizeTextField(textField)
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tokenizeTextField(textField)
        return tagDelegate?.tagFieldShouldReturn(self) ?? true
    }
    
    private func tokenizeTextField(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            addTag(text: text)
            textField.text = nil
        }
    }
}

protocol TagFieldDelegate: class {
    func tagFieldShouldReturn(_ tagField: TagField) -> Bool
}

extension TagFieldDelegate {
    func tagFieldShouldReturn(_ tagField: TagField) -> Bool {
        return true
    }
}

final class TagField: UIScrollView {
    
    weak var tagDelegate: TagFieldDelegate?
    
    private var tagViews: [TagView] = []
    
    private let textField = UITextField()
    
    var delimiter: String?
    
    var tagBetweenSpace: CGFloat = 2.0
    
    var lineBetweenSpace: CGFloat = 3.0
    
    var intrinsicContentHeight: CGFloat = 50
    
    var padding: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    // - MARK: TagView properties
    var tagPadding: UIEdgeInsets = .zero {
        didSet {
            tagViews.forEach { $0.padding = tagPadding }
        }
    }
    
    var tagBackgroundColor: UIColor = .clear {
        didSet {
            tagViews.forEach { $0.backgroundColor = tagBackgroundColor }
        }
    }

    // - MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        textField.delegate = self
        addSubview(textField)
    }
    
    func addTag(text: String) {
        let tagView = createTagView(text: text)
        addSubview(tagView)
        tagViews.append(tagView)
        setNeedsLayout()
    }
    
    private func createTagView(text: String) -> TagView {
        let tagView = TagView()
        tagView.backgroundColor = tagBackgroundColor
        tagView.padding = tagPadding
        tagView.text = text
        return tagView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        repositionSubviews()
    }
    
    private func repositionSubviews() {
        let fullWidth = bounds.width - (padding.left + padding.right)
        
        var numOfLines = 1
        var maxHeightOfLine: CGFloat = 0
        
        var x: CGFloat = padding.left
        var y: CGFloat = padding.top
        for tagView in tagViews {
            let tagSize = tagView.intrinsicContentSize
            let spaceWidth = fullWidth - x
            
            if tagSize.width > spaceWidth {
                // new line
                x = padding.left
                y += maxHeightOfLine + lineBetweenSpace
                maxHeightOfLine = 0
                numOfLines += 1
                
                if tagSize.width > fullWidth {
                    // cripping
                    tagView.frame = CGRect(x: x, y: y, width: fullWidth, height: tagSize.height)
                } else {
                    tagView.sizeToFit()
                    tagView.frame.origin = CGPoint(x: x, y: y)
                }
            } else {
                tagView.sizeToFit()
                tagView.frame.origin = CGPoint(x: x, y: y)
            }
            x += tagSize.width + tagBetweenSpace
            maxHeightOfLine = max(maxHeightOfLine, tagSize.height)
        }
        
        let textFieldMinWidth: CGFloat = 20
        let spaceWidth = (fullWidth - x)
        if spaceWidth < textFieldMinWidth {
            // textField start next line
            x = padding.left
            y += maxHeightOfLine + lineBetweenSpace
        }
        let h = (textField.font?.pointSize ?? 15) + 3
        textField.frame = CGRect(x: x, y: y, width: fullWidth, height: h)
    }
}

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

