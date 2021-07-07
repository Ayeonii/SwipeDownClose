//
//  UIButtonExtension.swift
//  SwipeDownClose
//
//  Created by 이아연 on 2021/07/07.
//
import UIKit

extension UIButton {
    func setBackgroundColor(_ color: UIColor, forState: UIControl.State) {
        setBackgroundImage(imageWithColor(color), for: forState)
    }
    
    func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
}

