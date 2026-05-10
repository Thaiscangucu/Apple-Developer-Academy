//
//  Misc.swift
//  POCEffects
//
//  Created by Thomas Pinheiro Grandin on 19/02/26.
//

import Foundation
import SpriteKit
import SwiftUI

let WALL_DEPTH = 20
class borda: SKNode {
        let sprite: SKSpriteNode
        
    init(size: CGSize) {
        self.sprite = SKSpriteNode(color: .purple, size: size)
            super.init()
            
            self.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
            self.physicsBody?.affectedByGravity = false
            self.isUserInteractionEnabled = false
            self.physicsBody?.isDynamic = false
            self.physicsBody?.categoryBitMask = PhysicsCategory.Borda
        self.physicsBody?.contactTestBitMask = PhysicsCategory.NPC
            addChild(sprite)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}

class spawn: SKNode {
    
    let sprite: SKSpriteNode
    
    init(sprite: SKSpriteNode, position: CGPoint) {
        self.sprite = sprite
        super.init()
        self.position = position
        addChild(sprite)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class train: SKNode {
    let sprite = SKSpriteNode(imageNamed: "chaoTrem")
    let mirror: Bool
    
    let portas = [[parede(sprite: SKSpriteNode(imageNamed: "porta")), parede(sprite: SKSpriteNode(imageNamed: "porta"))],[parede(sprite: SKSpriteNode(imageNamed: "porta")), parede(sprite: SKSpriteNode(imageNamed: "porta"))]]
    let paredes = [parede(sprite: SKSpriteNode(color: .clear, size: CGSize(width: 330, height: WALL_DEPTH))), parede(sprite: SKSpriteNode(color: .clear, size: CGSize(width: 330, height: WALL_DEPTH))), parede(sprite: SKSpriteNode(color: .clear, size: CGSize(width: 330, height: WALL_DEPTH))), parede(sprite: SKSpriteNode(color: .clear, size: CGSize(width: 330, height: WALL_DEPTH))), parede(sprite: SKSpriteNode(color: .clear, size: CGSize(width: 1920, height: WALL_DEPTH))), parede(sprite: SKSpriteNode(color: .clear, size: CGSize(width: WALL_DEPTH, height: 240))), parede(sprite: SKSpriteNode(color: .clear, size: CGSize(width: WALL_DEPTH, height: 240)))
    ]
    
    init(mirror: Bool) {
        self.mirror = mirror
        super.init()
        sprite.scale(to: CGSize(width: 1920, height: 240))
        addChild(sprite)
        // Bancos -----------
        let bancoFundo = SKSpriteNode(imageNamed: "bancoLongo")
        addChild(bancoFundo)
        bancoFundo.setScale(0.3)
        bancoFundo.position = CGPoint(x: 860, y: 0)
        let banco1 = SKSpriteNode(imageNamed: "bancoTrem")
        addChild(banco1)
        banco1.setScale(0.3)
        banco1.position = CGPoint(x: -380, y: 95)
        let banco2 = SKSpriteNode(imageNamed: "bancoTrem")
        addChild(banco2)
        banco2.setScale(0.3)
        banco2.position = CGPoint(x: 380, y: 95)
        
        // Painel -----------
        let painel = SKSpriteNode(imageNamed: "painelControle")
        addChild(painel)
        painel.setScale(0.3)
        painel.position = CGPoint(x: -910, y: 0)
        painel.zPosition = 5
        painel.addPhysics()
        
        // Cadeira -----------
        let cadeira = SKSpriteNode(imageNamed: "cadeira")
        addChild(cadeira)
        cadeira.setScale(0.4)
        cadeira.position = CGPoint(x: -860, y: 0)
        
        // Portas e paredes -----------
        addChild(portas[0][0])
        addChild(portas[0][1])
        addChild(portas[1][0])
        addChild(portas[1][1])
        portas[0][0].position = CGPoint(x: -555, y: -110)
        portas[0][1].position = CGPoint(x: -405, y: -110)
        portas[1][0].position = CGPoint(x: 405, y: -110)
        portas[1][1].position = CGPoint(x: 555, y: -110)
        portas[0][0].xScale = 0.5
        portas[0][0].yScale = 0.5
        portas[0][1].xScale = 0.5
        portas[0][1].yScale = 0.5
        portas[1][0].xScale = 0.5
        portas[1][0].yScale = 0.5
        portas[1][1].xScale = 0.5
        portas[1][1].yScale = 0.5
        
        addChild(paredes[0])
        addChild(paredes[1])
        addChild(paredes[2])
        addChild(paredes[3])
        addChild(paredes[4])
        addChild(paredes[5])
        addChild(paredes[6])
        paredes[0].position = CGPoint(x: -795, y: -110)
        paredes[1].position = CGPoint(x: -165, y: -110)
        paredes[2].position = CGPoint(x: 165, y: -110)
        paredes[3].position = CGPoint(x: 795, y: -110)
        paredes[4].position = CGPoint(x: 0, y: 110)
        paredes[5].position = CGPoint(x: -960, y: 0)
        paredes[6].position = CGPoint(x: 960, y: 0)
        
        if mirror {
            self.setScale(-1)
            cadeira.yScale = -0.4
            painel.yScale = -0.3
            for parede in paredes {
                parede.mirror()
            }
            for porta in portas {
                porta[0].mirror()
                porta[1].mirror()
            }
        }
    }
    
    func abrirPortas() {
        portas[0][0].run(SKAction.move(by: CGVector(dx: -150, dy: 0), duration: 1))
        portas[0][1].run(SKAction.move(by: CGVector(dx: 150, dy: 0), duration: 1))
        portas[1][0].run(SKAction.move(by: CGVector(dx: -150, dy: 0), duration: 1))
        portas[1][1].run(SKAction.move(by: CGVector(dx: 150, dy: 0), duration: 1))
    }
    
    func fecharPortas() {
        portas[0][0].run(SKAction.move(by: CGVector(dx: 150, dy: 0), duration: 1))
        portas[0][1].run(SKAction.move(by: CGVector(dx: -150, dy: 0), duration: 1))
        portas[1][0].run(SKAction.move(by: CGVector(dx: 150, dy: 0), duration: 1))
        portas[1][1].run(SKAction.move(by: CGVector(dx: -150, dy: 0), duration: 1))
    }
    
    func testarPortas() {
        self.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run {
                self.abrirPortas()
            },
            SKAction.wait(forDuration: 3),
            SKAction.run {
                self.fecharPortas()
            },
            SKAction.wait(forDuration: 3)
        ])))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class parede: SKNode {
    let sprite: SKSpriteNode
    
    init(sprite: SKSpriteNode) {
        self.sprite = sprite
        super.init()
        
        self.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        self.physicsBody?.affectedByGravity = false
        self.isUserInteractionEnabled = false
        self.physicsBody?.isDynamic = false
        self.physicsBody?.collisionBitMask = PhysicsCategory.Parede
        self.physicsBody?.categoryBitMask = PhysicsCategory.Parede
        addChild(sprite)
    }
    
    func mirror() {
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: -self.sprite.size.width, height: -self.sprite.size.height))
        self.physicsBody?.affectedByGravity = false
        self.isUserInteractionEnabled = false
        self.physicsBody?.isDynamic = false
        self.physicsBody?.collisionBitMask = PhysicsCategory.Parede
        self.physicsBody?.categoryBitMask = PhysicsCategory.Parede
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SKSpriteNode {
    func addPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.isUserInteractionEnabled = false
        self.physicsBody?.isDynamic = false
        self.physicsBody?.collisionBitMask = PhysicsCategory.Parede
        self.physicsBody?.categoryBitMask = PhysicsCategory.Parede
    }
}

struct PhysicsCategory {
    
    static let NPC: UInt32 = 0b1
    static let Arara: UInt32 = 0b10
    static let Cachorro: UInt32 = 0b11
    static let Borda: UInt32 = 0b0100
    static let Parede: UInt32 = 0b1111
}
