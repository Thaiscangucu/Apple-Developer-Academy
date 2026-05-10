//
//  NPCs.swift
//  POCEffects
//
//  Created by Thomas Pinheiro Grandin on 19/02/26.
//

import Foundation
import SpriteKit
internal import Combine

let spritesAraras = ["araraAzulPerfil", "araraVermelhaPerfil", "araraVerdePerfil"]

class NPC: SKNode {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var state: NPCState = .idle
    let sprite: SKSpriteNode = SKSpriteNode(imageNamed: spritesAraras.randomElement()!)
    var spriteFruta: SKSpriteNode!
    
    override init() {
        super.init()
        self.zPosition = 100
        self.sprite.setScale(0.3)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.sprite.size.width, height: 50), center: CGPoint(x: 0, y: -40))
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.collisionBitMask = PhysicsCategory.NPC
        self.physicsBody?.categoryBitMask = PhysicsCategory.NPC
        self.physicsBody?.allowsRotation = false
        addChild(sprite)
        self.isUserInteractionEnabled = true
    }
    
    func spawn(location: spawnLocation) {
        if let scene = SceneManager.shared.currentScene as? CustomScene {
            if location == .aleatorio {
                self.position = CGPoint(x: CGFloat.random(in: 100...(scene.size.width - 100)), y: CGFloat.random(in: 300...(scene.size.height - 300)))
            }
            else if location == .entradas {
                let spawn = scene.spawns[Int.random(in: 0..<scene.spawns.count)]
                self.position = CGPoint(x: spawn.position.x + Double.random(in: -(spawn.sprite.size.width / 2)...(spawn.sprite.size.width / 2)), y: spawn.position.y + CGFloat.random(in: -(spawn.sprite.size.height / 2)...(spawn.sprite.size.height / 2)))
                self.state = .andando
                var dx: Double = 0
                var dy: Double = 0
                if self.position.x <= 0 {
                    dx = Double.random(in: 300...800)
                    dy = Double.random(in: -200...200)
                }
                else {
                    dx = Double.random(in: -800 ... -300)
                    dy = Double.random(in: -200...200)
                }
                self.run(SKAction.move(by: CGVector(dx: dx, dy: dy), duration: (sqrt(pow(dx, 2) + pow(dy, 2))) / 200), completion: {
                    if self.state == .comprando { return }
                    self.state = .idle
                })
            }
            else if location == .tremSuperior {
                let tremSuperior = scene.tremSuperior
                self.position = CGPoint(x: tremSuperior.position.x + Double.random(in: ((tremSuperior.sprite.frame.minX) + 100)...(tremSuperior.sprite.frame.maxX - 100)), y: tremSuperior.position.y + CGFloat.random(in: tremSuperior.sprite.frame.minY + 100...tremSuperior.sprite.frame.maxY) - 50)
            }
            else if location == .tremInferior {
                let tremInferior = scene.tremInferior
                self.position = CGPoint(x: tremInferior.position.x + Double.random(in: ((tremInferior.sprite.frame.minX) + 100)...(tremInferior.sprite.frame.maxX - 100)), y: tremInferior.position.y + CGFloat.random(in: tremInferior.sprite.frame.minY + 100...tremInferior.sprite.frame.maxY) - 50)
            }
        }
    }
    
    func despawn() {
        if self.state == .comprando {
            comprou()
        }
        self.removeFromParent()
    }
    
    func update() {
        switch self.state {
        case .idle:
            let x = Int.random(in: 1...10)
            if x <= 9 {
                andar()
            }
            else {
                parar()
            }
        case .parado:
            return
        case .andando:
            return
        case .revista:
            return
        case .comprando:
            return
        default:
            fatalError()
        }
    }
    
    func andar() {
        self.state = .andando
        let dx = CGFloat.random(in: -200...200)
        let dy = CGFloat.random(in: -200...200)
        // MARK: - Adicionar flipagem da sprite
        if dx > 0 {
            self.sprite.xScale = -(self.sprite.xScale)
        }
        else {
            
            self.sprite.xScale = abs(self.sprite.xScale)
        }
        self.run(SKAction.move(by: CGVector(dx: dx, dy: dy), duration: (sqrt(pow(dx, 2) + pow(dy, 2))) / 200), completion: {
            if self.state == .comprando { return }
            self.state = .idle
        })
        
    }
    func parar() {
        self.state = .parado
        self.run(SKAction.wait(forDuration: Double.random(in: 2...5)), completion: {
            if self.state == .comprando { return }
            self.andar()
        })
        
    }
    
    
    func revistar() {
        
    }
    
    func comprar() {
        self.spriteFruta = SKSpriteNode(imageNamed: ["pitanga", "guarana", "caju"].randomElement()!)
        self.spriteFruta.size = CGSize(width: 80, height: 80)
        self.spriteFruta.position = CGPoint(x: 0, y: 100)
        self.run(SKAction.playSoundFileNamed("arara.m4a", waitForCompletion: false))
        self.state = .comprando
        addChild(spriteFruta)
        self.zPosition = 105
    }
    
    func comprou() {
        spriteFruta.removeFromParent()
        if let parent = self.parent as? ManagerNPC {
            parent.compradoresAtuais -= 1
        }
        self.state = .idle
        self.zPosition = 100
        self.run(SKAction.playSoundFileNamed("cash.m4a", waitForCompletion: false))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.state == .comprando {
            comprou()
        }
    }
    
}

class ManagerNPC: SKNode {
    
    let maxCompradores: Int = 10
    var compradoresAtuais: Int = 0
    let maxNPCs: Int = 30
    
    override init() {
        super.init()
        self.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 4),
            SKAction.run {
                self.addCompradores()
            }
        ])))
    }
    
    func populate() {
        for _ in 0..<maxNPCs {
            let newNPC = NPC()
            self.addChild(newNPC)
            newNPC.spawn(location: .aleatorio)
        }
    }
    
    func populateTrains() {
        for _ in 1...Int(maxNPCs / 2) {
            let newNPC = NPC()
            self.addChild(newNPC)
            newNPC.spawn(location: .tremSuperior)
        }
        
        for _ in 1...Int(maxNPCs / 2) {
            let newNPC = NPC()
            self.addChild(newNPC)
            newNPC.spawn(location: .tremInferior)
        }
    }
    
    func addCompradores() {
        while compradoresAtuais < maxCompradores {
            if let child = self.children.randomElement() as? NPC {
                if child.state != .comprando {
                    child.comprar()
                    compradoresAtuais += 1
                    break
                }
            }
        }
    }
    
    
    func update() {
        for child in self.children {
            if let child = child as? NPC {
                child.update()
            }
            if self.children.count < maxNPCs {
                let newNPC = NPC()
                self.addChild(newNPC)
                newNPC.spawn(location: .entradas)
            }
        }
    }
    
    func initGame() {
        populate()
        addCompradores()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum spawnLocation {
    case aleatorio
    case entradas
    case tremSuperior
    case tremInferior
}

enum NPCState {
    case idle
    case parado
    case andando
    case revista
    case comprando
}
