//
//  UIImage.swift
//  FisioterApp
//
//  Created by Thais Cangucu on 16/04/26.
//
import UIKit

extension UIImage {
    static func gradientImage(bounds: CGRect, colors: [UIColor]) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        // Define a direção (0,0 a 1,0 é diagonal, 0,0 a 1,0 horizontal, etc)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { ctx in
            gradientLayer.render(in: ctx.cgContext)
        }
    }
}
