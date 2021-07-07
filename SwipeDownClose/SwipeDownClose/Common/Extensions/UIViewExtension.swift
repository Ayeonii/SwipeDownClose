//
//  UIViewExtension.swift
//  SwipeDownClose
//
//  Created by 이아연 on 2021/07/07.
//

import UIKit

extension UIView {
    
    @available(iOS 11.0, *)
    func roundCorners(cornerRadius: CGFloat, maskedCorners: CACornerMask) {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = CACornerMask(arrayLiteral: maskedCorners)
        
    }
    
    func roundCorners(cornerRadius: CGFloat, byRoundingCorners: UIRectCorner) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: byRoundingCorners,
                                cornerRadii: CGSize(width:cornerRadius, height: cornerRadius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = path.cgPath
        
        layer.mask = maskLayer
    }
}
