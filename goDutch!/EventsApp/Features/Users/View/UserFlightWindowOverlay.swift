//
//  UserFlightWindowOverlay.swift
//  EventsApp
//
//  Created by Camila Parolin on 25/09/26.
//

import UIKit
import SpriteKit

final class UserFlightWindowOverlay {
    private let scene: UserFlightScene = {
        let scene = UserFlightScene()
        
        scene.scaleMode = .resizeFill
        scene.anchorPoint = .zero
        scene.backgroundColor = .clear
        
        return scene
    }()
    
    private var overlayView: SKView?
    
    var isFlying: Bool {
        scene.isFlying
    }
    
    @discardableResult
    func fly(
        user: User,
        from startPoint: CGPoint,
        to endPoint: CGPoint,
        sourceDiameter: CGFloat,
        targetDiameter: CGFloat,
        duration: TimeInterval,
        occlusionFrame: CGRect? = nil,
        onArrival: @escaping () -> Void,
        onFinished: @escaping () -> Void
    ) -> Bool {
        guard
            !scene.isFlying,
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
            let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            return false
        }
        
        let skView: SKView
        
        if let existingView = overlayView, existingView.superview === window {
            skView = existingView
            skView.frame = window.bounds
        } else {
            overlayView?.presentScene(nil)
            overlayView?.removeFromSuperview()
            
            let newView = SKView(frame: window.bounds)
            
            newView.backgroundColor = .clear
            newView.isOpaque = false
            newView.allowsTransparency = true
            newView.isUserInteractionEnabled = false
            newView.accessibilityElementsHidden = true
            newView.autoresizingMask = [
                .flexibleWidth,
                .flexibleHeight
            ]
            
            scene.size = window.bounds.size
            
            window.addSubview(newView)
            newView.presentScene(scene)
            
            overlayView = newView
            skView = newView
        }
        
        window.bringSubviewToFront(skView)
        
        skView.isPaused = false
        skView.preferredFramesPerSecond = UIScreen.main.maximumFramesPerSecond
        
        scene.size = skView.bounds.size
        scene.isPaused = false
        scene.speed = 1
        
        applyOcclusion(over: occlusionFrame, in: skView)
        
        let didStart = scene.fly(
            user: user,
            from: startPoint,
            to: endPoint,
            viewportSize: skView.bounds.size,
            sourceDiameter: sourceDiameter,
            targetDiameter: targetDiameter,
            duration: duration,
            onArrival: onArrival,
            onFinished: { [weak self] in
                self?.clearOcclusion()
                self?.pauseOverlay()
                onFinished()
            })
        
        if !didStart {
            clearOcclusion()
            pauseOverlay()
        }
        
        return didStart
    }
    
    private func applyOcclusion(over frame: CGRect?, in skView: SKView) {
        skView.layer.mask = nil
        
        guard let frame, !frame.isEmpty else {
            return
        }
        
        let protectedFrame = frame.insetBy(dx: -3, dy: -3)
        
        let visibleArea = UIBezierPath(rect: skView.bounds)
        
        let buttonArea = UIBezierPath(roundedRect: protectedFrame, cornerRadius: protectedFrame.height / 2)
        
        visibleArea.append(buttonArea)
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = skView.bounds
        maskLayer.path = visibleArea.cgPath
        maskLayer.fillRule = .evenOdd
        maskLayer.fillColor = UIColor.black.cgColor
        
        skView.layer.mask = maskLayer
    }
    
    private func clearOcclusion() {
        overlayView?.layer.mask = nil
    }
    
    private func pauseOverlay() {
        guard !scene.isFlying else {
            return
        }
        
        overlayView?.isPaused = true
        scene.isPaused = true
    }
    
    func detach() {
        clearOcclusion()
        
        scene.isPaused = true
        overlayView?.isPaused = true
        
        overlayView?.presentScene(nil)
        overlayView?.removeFromSuperview()
        overlayView = nil
    }
}
