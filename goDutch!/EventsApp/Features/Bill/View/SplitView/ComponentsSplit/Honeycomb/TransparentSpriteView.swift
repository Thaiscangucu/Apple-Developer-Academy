//
//  TransparentSpriteView.swift
//  EventsApp
//
//  Created by Camila Parolin on 02/09/26.
//

import SwiftUI
import SpriteKit
import UIKit

struct TransparentSpriteView: UIViewRepresentable {
    
    let scene: SKScene
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        
        skView.backgroundColor = .clear
        skView.isOpaque = false
        skView.allowsTransparency = true
        skView.isPaused = false
        skView.preferredFramesPerSecond = 60
        
        scene.isPaused = false
        scene.speed = 1
        scene.backgroundColor = .clear
        
        skView.presentScene(scene)
        
        return skView
    }
    
    func updateUIView(_ skView: SKView, context: Context) {
        skView.backgroundColor = .clear
        skView.isOpaque = false
        skView.allowsTransparency = true
        skView.isPaused = false
        
        scene.isPaused = false
        scene.speed = 1
        scene.backgroundColor = .clear
        
        if skView.scene !== scene {
            skView.presentScene(scene)
        }
    }
}
