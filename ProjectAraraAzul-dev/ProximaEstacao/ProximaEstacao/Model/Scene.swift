//
//  Scene.swift
//  POCEffects
//
//  Created by Thomas Pinheiro Grandin on 19/02/26.
//

import Foundation
import SpriteKit
import AVFoundation
import SwiftUI
import GameKit


class CustomScene: SKScene, @MainActor SKPhysicsContactDelegate {
    let gameLogicManager: GameLogicManager = GameLogicManager()
    let NPCManager: ManagerNPC = ManagerNPC()
    let matchManager: MatchManagerViewModel
    //var players: PlayerNode = PlayerNode()
    var players: [String : Player] = [:]
//    var araras: [Arara] = [Arara(), Arara()]
//    var cachorros: [Cachorro] = [Cachorro(), Cachorro()]
    
    var backgroundMusic: SKAudioNode!

  //    SKAction.playSoundFileNamed("arara.m4a", waitForCompletion: false)
    
    let trainTimer: Double = 10
    let spawns: [spawn] = [
        spawn(sprite: SKSpriteNode(color: .yellow, size: CGSize(width: 100, height: 500)), position: CGPoint(x: -50, y: 540)),
        spawn(sprite: SKSpriteNode(color: .yellow, size: CGSize(width: 100, height: 500)), position: CGPoint(x: 1970, y: 540))
    ]
    let paredesTrem: [parede] = [
        parede(sprite: SKSpriteNode(color: .clear, size: CGSize(width: 2220, height: 20))),
        parede(sprite: SKSpriteNode(color: .clear, size: CGSize(width: 2220, height: 20)))
    ]
    let bordas: [borda] = [borda(size: CGSize(width: 20, height: 840)), borda(size: CGSize(width: 20, height: 840))]
    var trens: [train] = []
    let tremSuperior = train(mirror: false)
    let tremInferior = train(mirror: true)
    
    
    init(size: CGSize, matchManager: MatchManagerViewModel) {
        self.matchManager = matchManager
        super.init(size: size)
        let camera = SKCameraNode()
        self.camera = camera
        camera.xScale = 1.0
        camera.yScale = 1.0
        camera.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        addChild(camera)
        
        
        for spawn in spawns {
            addChild(spawn)
        }
//        addChild(players)
//        for arara in araras {
//            addChild(arara)
//            arara.spawn(random: true)
//        }
//        for cachorro in cachorros {
//            addChild(cachorro)
//            cachorro.spawn(random: true)
//        }
        
        addChild(bordas[0])
        bordas[0].position = CGPoint(x: -100, y: 660)
        addChild(bordas[1])
        bordas[1].position = CGPoint(x: 2020, y: 420)
        
        addChild(paredesTrem[0])
        paredesTrem [0].position = CGPoint(x: 960, y: 850)
        addChild(paredesTrem[1])
        paredesTrem[1].position = CGPoint(x: 960, y: 230)
        
        addChild(NPCManager)
        // Chao
        let chao = SKSpriteNode(imageNamed: "chaoGrande")
        addChild(chao)
        chao.position = CGPoint(x: 960, y: 540)
        chao.scale(to: CGSize(width: 1920, height: 600))
        let chaoTrilhos = [SKSpriteNode(imageNamed: "pedra"), SKSpriteNode(imageNamed: "pedra"), SKSpriteNode(imageNamed: "pedra"), SKSpriteNode(imageNamed: "pedra"), SKSpriteNode(imageNamed: "pedra"), SKSpriteNode(imageNamed: "pedra"), SKSpriteNode(imageNamed: "pedra"), SKSpriteNode(imageNamed: "pedra"), SKSpriteNode(imageNamed: "pedra")]
        for i in 0..<chaoTrilhos.count {
            addChild(chaoTrilhos[i])
            chaoTrilhos[i].position = CGPoint(x: 240 * i, y: 120)
            chaoTrilhos[i].setScale(0.3)
        }
        let chaoTrilhosSuperior = [SKSpriteNode(imageNamed: "pedra"), SKSpriteNode(imageNamed: "pedra"), SKSpriteNode(imageNamed: "pedra"), SKSpriteNode(imageNamed: "pedra"), SKSpriteNode(imageNamed: "pedra"), SKSpriteNode(imageNamed: "pedra"), SKSpriteNode(imageNamed: "pedra"), SKSpriteNode(imageNamed: "pedra"), SKSpriteNode(imageNamed: "pedra")]
        
        for i in 0..<chaoTrilhosSuperior.count {
            addChild(chaoTrilhosSuperior[i])
            chaoTrilhosSuperior[i].position = CGPoint(x: 240 * i, y: 960)
            chaoTrilhosSuperior[i].setScale(0.3)
        }
        let trilhoInferior1 = SKSpriteNode(imageNamed: "trilhos")
        addChild(trilhoInferior1)
        trilhoInferior1.position = CGPoint(x:440, y: 100)
        let trilhoInferior2 = SKSpriteNode(imageNamed: "trilhos")
        addChild(trilhoInferior2)
        trilhoInferior2.position = CGPoint(x:1340, y: 100)
        let trilhoInferior3 = SKSpriteNode(imageNamed: "trilhos")
        addChild(trilhoInferior3)
        trilhoInferior3.position = CGPoint(x:2240, y: 100)
        let trilhoSuperior1 = SKSpriteNode(imageNamed: "trilhos")
        addChild(trilhoSuperior1)
        trilhoSuperior1.position = CGPoint(x:440, y: 980)
        let trilhoSuperior2 = SKSpriteNode(imageNamed: "trilhos")
        addChild(trilhoSuperior2)
        trilhoSuperior2.position = CGPoint(x:1340, y: 980)
        let trilhoSuperior3 = SKSpriteNode(imageNamed: "trilhos")
        addChild(trilhoSuperior3)
        trilhoSuperior3.position = CGPoint(x:2240, y: 980)
        addChild(tremSuperior)
        self.trens.append(tremInferior)
        addChild(tremInferior)
        self.trens.append(tremSuperior)
        self.tremSuperior.position = CGPoint(x: 2920, y: 960)
        self.tremInferior.position = CGPoint(x: -1000, y: 120)
        // Level Details
        let banco1 = SKSpriteNode(imageNamed: "bancoEstacao")
        addChild(banco1)
        banco1.position = CGPoint(x: 400, y: 540)
        banco1.setScale(0.4)
        banco1.zPosition = 5
        banco1.addPhysics()
        let banco2 = SKSpriteNode(imageNamed: "bancoEstacao")
        addChild(banco2)
        banco2.position = CGPoint(x: 630, y: 540)
        banco2.setScale(0.4)
        banco2.addPhysics()
        let poca1 = SKSpriteNode(imageNamed: "poça")
        addChild(poca1)
        poca1.position = CGPoint(x: 500, y: 700)
        poca1.setScale(0.5)
        let placaMolhado1 = SKSpriteNode(imageNamed: "placaMolhado")
        addChild(placaMolhado1)
        placaMolhado1.position = CGPoint(x: 460, y: 700)
        placaMolhado1.setScale(0.6)
        placaMolhado1.addPhysics()
        let lixo1 = SKSpriteNode(imageNamed: "lixo1")
        addChild(lixo1)
        lixo1.position = CGPoint(x: 790, y: 550)
        lixo1.setScale(0.4)
        lixo1.addPhysics()
        let banco3 = SKSpriteNode(imageNamed: "bancoEstacao")
        addChild(banco3)
        banco3.position = CGPoint(x: 1100, y: 540)
        banco3.setScale(0.4)
        banco3.zPosition = 5
        banco3.addPhysics()
        let banco4 = SKSpriteNode(imageNamed: "bancoEstacao")
        addChild(banco4)
        banco4.position = CGPoint(x: 1330, y: 540)
        banco4.setScale(0.4)
        banco4.addPhysics()
        let lixo2 = SKSpriteNode(imageNamed: "lixo1")
        addChild(lixo2)
        lixo2.position = CGPoint(x: 1490, y: 550)
        lixo2.setScale(0.4)
        lixo2.addPhysics()
//        let poste1 = SKSpriteNode(imageNamed: "posteDireita")
        
    }
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        if let musicURL = Bundle.main.url(forResource: "soundtrack", withExtension: "m4a") {
                   backgroundMusic = SKAudioNode(url: musicURL)
                   addChild(backgroundMusic)
               }
        
        NPCManager.initGame()
        trainRoutine()
//        for player in players.values {
//            player.spawn(random: true)
//        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        gameLogicManager.checkContact(contact: contact)
//        let bodyA: SKPhysicsBody
//        let bodyB: SKPhysicsBody
//        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
//            bodyA = contact.bodyA
//            bodyB = contact.bodyB
//        }
//        else {
//            bodyA = contact.bodyB
//            bodyB = contact.bodyA
//        }
//        
//        if let nodeA = bodyA.node as? NPC {
//            if let nodeB = bodyB.node as? borda {
//                nodeA.despawn()
//            }
//        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        NPCManager.update()
    }
    
    func trainRoutine() {
        
        self.tremInferior.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run {
                self.tremSuperior.position = CGPoint(x: 2920, y: 960)
                self.tremInferior.position = CGPoint(x: -1000, y: 120)
                self.NPCManager.populateTrains()
            },
            SKAction.wait(forDuration: self.trainTimer),
            SKAction.run {
                for npc in self.NPCManager.children {
                    if npc.position.y < 230 {
                        npc.run(SKAction.move(by: CGVector(dx: 1960, dy: 0), duration: 3))
                    }
                }
            },
            SKAction.move(to: CGPoint(x: 960, y: 120), duration: 3),
            SKAction.run {
                self.tremInferior.abrirPortas()
                self.paredesTrem[0].removeFromParent()
            },
            SKAction.wait(forDuration: self.trainTimer),
            SKAction.run {
                self.tremInferior.fecharPortas()
            },
            SKAction.wait(forDuration: 2),
            SKAction.run {
                self.addChild(self.paredesTrem[0])
            },
            SKAction.run {
                for npc in self.NPCManager.children {
                    if npc.position.y < 230 {
                        npc.run(SKAction.move(by: CGVector(dx: 1960, dy: 0), duration: 3))
                    }
                }
            },
            SKAction.move(to: CGPoint(x: 2920, y: 120), duration: 3)
        ])))
        self.tremSuperior.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: self.trainTimer),
            SKAction.run {
                for npc in self.NPCManager.children {
                    if npc.position.y > 870 {
                        npc.run(SKAction.move(by: CGVector(dx: -1960, dy: 0), duration: 3))
                    }
                }
            },
            SKAction.move(to: CGPoint(x: 960, y: 960), duration: 3),
            SKAction.run {
                self.tremSuperior.abrirPortas()
                self.paredesTrem[1].removeFromParent()
            },
            SKAction.wait(forDuration: self.trainTimer),
            SKAction.run {
                self.tremSuperior.fecharPortas()
            },
            SKAction.wait(forDuration: 2),
            SKAction.run {
                self.addChild(self.paredesTrem[1])
            },
            SKAction.run {
                for npc in self.NPCManager.children {
                    if npc.position.y > 870 {
                        npc.run(SKAction.move(by: CGVector(dx: -1960, dy: 0), duration: 3))
                    }
                }
            },
            SKAction.move(to: CGPoint(x: -1000, y: 960), duration: 3)
        ])))
    }
    
    func receiveInput(player: String, input: CGPoint) {
//        print("recebi isso aqui\(player) \(input)")
        if let arara = players[player] as? Arara {
//            print("posicao da arara: \(arara.position)")
            arara.position.x += input.x * 5
            arara.position.y += input.y * 5
//            print("posicao nova da arara: \(arara.position)")
//            if input.x > 0 {
//                arara.spritePlayer.xScale = -(arara.spritePlayer.xScale)
//            }
//            else {
//                arara.spritePlayer.xScale = abs(arara.spritePlayer.xScale)
//            }
        }
        else if let cachorro = players[player] as? Cachorro {
//            print("posicao da cachorro: \(cachorro.position)")
            cachorro.position.x += input.x * 5
            cachorro.position.y += input.y * 5
//            print("posicao nova da cachorro: \(cachorro.position)")
            if input.x > 0 {
                cachorro.spritePlayer.xScale = -(cachorro.spritePlayer.xScale)
            }
            else {
                cachorro.spritePlayer.xScale = abs(cachorro.spritePlayer.xScale)
            }
        }
        
    }
    
    func loadPlayer(araras: Int, cachorros: Int) {
        
//        print("MatchManager scene:", ObjectIdentifier(matchManager))
//        print(matchManager.playersIdList)
        
        let ids = matchManager.playersIdList
        
//        print("IDs recebidos:", ids)
//        print("players antes:", players.keys)

        var ararasRestantes = araras
        var cachorrosRestantes = cachorros

        for id in ids {
            
            // evita duplicar player
            if players[id] != nil {
                continue
            }

            if ararasRestantes > 0 {
                let newArara = Arara()
                players[id] = newArara
                addChild(newArara)
                newArara.spawn(random: true)
                
                ararasRestantes -= 1
//                print("Arara criada para \(id)")
                
            } else if cachorrosRestantes > 0 {
                let newCachorro = Cachorro()
                players[id] = newCachorro
                addChild(newCachorro)
                newCachorro.spawn(random: true)
                
                cachorrosRestantes -= 1
//                print("Cachorro criado para \(id)")
            }
        }

//        print("players depois:", players.keys)
    }
//        var count = 0
//        for i in 0..<araras {
//            let newArara = Arara()
//            players[ids[count]] = newArara
//            addChild(newArara)
//            newArara.spawn(random: true)
//            count += 1
//        }
//        
//        for i in 0..<cachorros{
//            let newCachorro = Cachorro()
//            players[ids[count]] = newCachorro
//            addChild(newCachorro)
//            newCachorro.spawn(random: true)
//            count += 1
//        }
        
        
//        var idsInterno = ids
//        print("recebi \(idsInterno.count) ids:")
//        for id in idsInterno {
//            print(id)
//        }
//        var count = 0
//        if araras == 1 {
//            self.araras[1].removeFromParent()
//            self.araras.remove(at: 1)
//        }
//        for i in 0..<self.araras.count {
//            players[idsInterno[count]] = self.araras[i]
//            print("valor do dicionario: \n \(players[idsInterno[count]])")
//            count += 1
//            print("criando arara")
//        }
//        if cachorros == 1 {
//            self.cachorros[1].removeFromParent()
//            self.cachorros.remove(at: 1)
//        }
//        for i in 0..<cachorros {
//            players[idsInterno[count]] = self.cachorros[i]
//            addChild(self.cachorros[i])
//            print("valor do dicionario: \n \(players[idsInterno[count]])")
//            count += 1
//            print("criando cachorro")
//        }
//        for player in players.values {
//            if let player = player as? Arara {
//                print("adicionando arara")
//                let arara = SKSpriteNode(imageNamed: "arara")
//                arara.name = "teste"
//                arara.zPosition = 150
//                arara.position = CGPoint(x: 500, y: 500)
//                player.zPosition = 150
//                self.addChild(arara)
//                self.addChild(player)
//                player.spawn(random: true)
//            }
//            else if let player = player as? Cachorro {
//                print("adicionando cachorro")
//                let arara = SKSpriteNode(imageNamed: "arara")
//                arara.name = "teste"
//                arara.zPosition = 150
//                arara.position = CGPoint(x: 500, y: 500)
//                player.zPosition = 150
//                player.zPosition = 150
//                self.addChild(arara)
//                self.addChild(player)
//                player.spawn(random: true)
//            }
//        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
