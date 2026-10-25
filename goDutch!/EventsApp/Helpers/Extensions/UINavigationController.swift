//
//  File.swift
//  EventsApp
//
//  Created by Thais Cangucu on 03/09/26.
//

import SwiftUI

// MARK: - Helper para controle do Swipe Back
extension UINavigationController {
    
    static func disableSwipeBack() {
        findNavigationController()?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    static func enableSwipeBack() {
        findNavigationController()?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private static func findNavigationController() -> UINavigationController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return nil
        }
        return findNestedNavigationController(in: rootViewController)
    }
    
    private static func findNestedNavigationController(in vc: UIViewController) -> UINavigationController? {
        if let nav = vc as? UINavigationController {
            return nav
        }
        for child in vc.children {
            if let nav = findNestedNavigationController(in: child) {
                return nav
            }
        }
        return nil
    }
}
