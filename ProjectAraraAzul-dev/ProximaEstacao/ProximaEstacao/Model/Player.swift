//
//  Player.swift
//  POCEffects
//
//  Created by Binho Gadelha on 25/02/26.
//

import Foundation
import SpriteKit

protocol Player: AnyObject {
    func update()
    func spawn(random: Bool)
}
class PlayerNode: SKNode{
    func addArara(){
        let newArara = Arara()
        addChild( newArara)
        newArara.spawn(random: true)
    }
    
    func addCachorro(){
        let newCachorro = Cachorro()
        addChild(newCachorro)
        newCachorro.spawn(random: true)
    }
}

class Arara: SKNode, Player {
    
    let spritePlayer: SKSpriteNode = SKSpriteNode(imageNamed: "araraVerdePerfil")
    
    override init() {
        super.init()
        addChild(spritePlayer)
        self.zPosition = 100
        self.spritePlayer.setScale(0.3)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.spritePlayer.size.width, height: 30), center: CGPoint(x: 0, y: -40))
        self.physicsBody?.isDynamic = true
        self.isUserInteractionEnabled = true
        self.physicsBody = SKPhysicsBody(rectangleOf: self.spritePlayer.size)
        self.physicsBody?.collisionBitMask = PhysicsCategory.Arara
        self.physicsBody?.categoryBitMask = PhysicsCategory.Arara
        self.physicsBody?.contactTestBitMask = PhysicsCategory.NPC
        self.physicsBody?.collisionBitMask = PhysicsCategory.Parede
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        self.zPosition = 100
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
    var isAlive: Bool = true
    //    var canInteract = false
    var qntdPitanga = 10
    var qntCaju     = 10
    var qntGuarana  = 10
    var fruta       = 10
    var nOfCoins    = 0
    //    let spritePlayer: SKSpriteNode = SKSpriteNode(imageNamed: "arara")
    var id: UUID = UUID()
    
    //como reconhecer o contato com o npcCerto
    func sell(comprador: NPC) {
        if fruta > 0 {
            comprador.comprou()
            //decrementar uma fruta
            fruta = fruta - 1
        }
    }
    
    func setTotalOfFruits(){
          fruta = qntdPitanga + qntCaju + qntGuarana
      }
    
    func spawn(random: Bool) {
        if let scene = SceneManager.shared.currentScene as? CustomScene {
            if random {
                self.position = CGPoint(x: CGFloat.random(in: 100...(scene.size.width - 100)), y: CGFloat.random(in: 200...(scene.size.height - 500)))
            }
        }
    }
    
    func update() {
        if !isAlive {
            
        }
    }
    
    func morrer() {
        self.removeFromParent()
    }
    
}

class Cachorro: SKNode, Player {
    let spritePlayer: SKSpriteNode = SKSpriteNode(imageNamed: "cachorro")
    
    override init() {
        super.init()
        addChild(spritePlayer)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.spritePlayer.size.width, height: 30), center: CGPoint(x: 0, y: -40))
        self.physicsBody?.isDynamic = true
        self.isUserInteractionEnabled = true
        spritePlayer.setScale(0.3)
        self.physicsBody?.collisionBitMask = PhysicsCategory.Parede
        self.physicsBody = SKPhysicsBody(rectangleOf: self.spritePlayer.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.Cachorro
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Arara
        self.zPosition = 100
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
    func revistar() {
        if let contatos = self.physicsBody?.allContactedBodies() {
            for contato in contatos {
                if let node = contato.node as? Arara {
                    node.morrer()
                }
            }
        }
    }
    
    func spawn(random: Bool) {
        if let scene = SceneManager.shared.currentScene as? CustomScene {
            if random {
                self.position = CGPoint(x: CGFloat.random(in: 300...(scene.size.width - 300)), y: CGFloat.random(in: 300...(scene.size.height - 300)))
            }
        }
    }
    
    func update() {
        
    }
    
    
}
