//
//  GameScene.swift
//  JoyStick
//
//  Created by Binho Gadelha on 23/02/26.
//

import Foundation
import SpriteKit
import GameController


class PlayerScene: SKScene {
    //criarNode com asset
    let player = SKShapeNode(circleOfRadius: 30)
    let bottomBorder = SKShapeNode()
    var playerPosx: CGFloat = 0
    var playerPosy: CGFloat = 0
    
    override func didMove(to view: SKView) {
        scene?.anchorPoint = .zero
        scene?.size = CGSize(width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height)
        scene?.scaleMode = .aspectFit
        player.fillColor = .systemRed
        player.strokeColor = .white
        player.position = CGPoint(x: size.width/2 , y: size.height/2)
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        player.physicsBody?.affectedByGravity = false
        
        addChild(player)
    }
    
//    override func update(_ currentTime: TimeInterval) {
//        //Verificar
//        player.speed = 2
//        let deltaPosition = getDeltaPosition(playerPosx, playerPosy, player.speed)
//        
//        if playerPosx != 0 {
//            player.position.x += deltaPosition.x
//        }
//        
//        if playerPosy != 0 {
//            player.position.y += deltaPosition.y
//        }
//    }
}
