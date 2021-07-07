//
//  UILabelExtension.swift
//  SwipeDownClose
//
//  Created by 이아연 on 2021/07/07.
//

import UIKit

extension UILabel {
    
    var visibleTextLength: Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedString.Key : Any])
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
        
        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
                }
            } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key : Any], context: nil).size.height <= labelHeight
            return prev
        }
        return self.text!.count
    }
    
    var isTruncated: Bool {
        guard let labelText = text ,
              !labelText.isEmpty else {
            return false
        }
        
        let labelTextSize = (labelText as NSString).boundingRect(
            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font as Any],
            context: nil).size
        
        return labelTextSize.height > bounds.size.height
    }
    
    func setMoreText(description: String, moreText : String, moreTextColor: UIColor) {
        let desc = description

        let endIndex = desc.index(desc.startIndex, offsetBy: self.visibleTextLength - moreText.count)
        let trimmedStr = String(desc[...endIndex] + moreText)
        let attrStr = NSMutableAttributedString(string: trimmedStr)
        attrStr.addAttribute(.foregroundColor, value : moreTextColor, range : (trimmedStr as NSString).range(of: moreText))
        
        self.attributedText = attrStr
        self.isUserInteractionEnabled = true
    }
    
}
