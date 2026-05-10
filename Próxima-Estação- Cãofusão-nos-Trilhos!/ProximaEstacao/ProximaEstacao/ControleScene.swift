//
//  GameScene.swift
//  JoyStick
//
//  Created by Binho Gadelha on 23/02/26.
//

import Foundation
import SpriteKit
import GameController
import SwiftUI


class ControleScene: SKScene {
#if os(iOS)
    @ObservedObject var matchManager = MatchManagerViewModel.shared
    //criarNode com asset
    let player = SKShapeNode(circleOfRadius: 10)
    let bottomBorder = SKShapeNode()

    var virtualController: GCVirtualController?
    var playerPosx: CGFloat = 0
    var playerPosy: CGFloat = 0
    
    override init(){
        let size = CGSize(width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Quando touchMoved é chamado? Toda vez que o toque muda de posicao
    //funcao didMove chamada quando a SKScene carrega pela primeira vez
    override func didMove(to view: SKView) {
        scene?.anchorPoint = .zero
        scene?.size = CGSize(width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height)
        scene?.scaleMode = .aspectFit
        scene?.backgroundColor = .clear
        player.fillColor = .systemGray
        player.strokeColor = .white
        player.position = CGPoint(x: size.width/2 , y: size.height/2)
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        player.physicsBody?.affectedByGravity = false
        
        addChild(player)
        
        virtualController = GCVirtualController.setUpVirtualController()
    }
    
    func uptadePos(_ message: String){
        guard message != "" else { return }
//        print("mandei o update \(message)")
        matchManager.SendString("position:\(message)")
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        //Verificar
        
        
        playerPosx = virtualController?.getPosX() ?? 0
        playerPosy = virtualController?.getPosY() ?? 0

        if playerPosx != 0 || playerPosy != 0 {
            let deltaPosition = getDeltaPosition(playerPosx, playerPosy)
            player.position.x = playerPosx
            player.position.y = playerPosy
//            print("\(matchManager.playerUUIDKey)!\(player.position.x)!\(player.position.y)")
            uptadePos("\(matchManager.playerUUIDKey)!\(player.position.x)!\(player.position.y)")
        }
    }
#endif
}




func getDeltaPosition(_ playerPosX: CGFloat , _ playerPosY: CGFloat) -> CGPoint{
    let p = CGPoint(x: playerPosX , y: playerPosY)
    let pLength = p.length()
    let pNormalized = CGPoint(x: p.x / pLength, y: p.y / pLength)
    let deltaPosition = CGPoint(x: pNormalized.x, y: pNormalized.y)
    return deltaPosition
}

extension CGPoint {
    func length() -> Double {
        return sqrt(self.x * self.x + self.y * self.y)
    }


}

