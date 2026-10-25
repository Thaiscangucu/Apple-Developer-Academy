//
//  UiViewController.swift
//  FisioterApp
//
//  Created by Thais Cangucu on 14/04/26.
//

import UIKit

extension UIViewController {
    func addChildController(_ child: UIViewController, frame: CGRect) {
        addChild(child)
        view.addSubview(child.view)
        
        child.view.frame = frame
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        child.didMove(toParent: self)
    }
    
    func removeChild() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
