
//
//  UIView+Utils.swift
//  ViewcodeAtividade
//
//  Created by Diego Saragoza Da Silva on 19/03/26.
//

import UIKit

extension UIView {
    public func setCornerRadius() {
        layer.cornerRadius = min(frame.size.width, frame.size.height) / 2.0
        clipsToBounds = true
    }
    
    public func setCornerRadius(radius: Double) {
        layer.cornerRadius = radius
    }
    
    public func setDropShadow(color: UIColor, opacity: Double, radius: Double, offset: CGSize = .zero) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = Float(opacity)
        layer.shadowRadius = radius
        layer.shadowOffset = offset
    }
    
    public func setBorder(color: UIColor, lineWidth: Double) {
        layer.borderColor = color.cgColor
        layer.borderWidth = lineWidth
    }
}
