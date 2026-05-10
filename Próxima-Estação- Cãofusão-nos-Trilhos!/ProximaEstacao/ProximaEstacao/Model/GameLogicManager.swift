//
//  GameLogicManager.swift
//  POCEffects
//
//  Created by Binho Gadelha on 02/03/26.
//

import Foundation
import SpriteKit


class GameLogicManager {
    
    func checkContact(contact: SKPhysicsContact){
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // Verifica contato entre Player e Comprador (independente da ordem)
        if (bodyA.categoryBitMask == PhysicsCategory.Arara &&
            bodyB.categoryBitMask == PhysicsCategory.NPC) ||
            (bodyA.categoryBitMask == PhysicsCategory.NPC &&
             bodyB.categoryBitMask == PhysicsCategory.Arara) {
            
//            print("Contato entre Arara e Comprador")
            
            // Descobre quem é quem
            let playerNode = bodyA.categoryBitMask == PhysicsCategory.Arara
            ? bodyA.node
            : bodyB.node
            
            let compradorNode = bodyA.categoryBitMask == PhysicsCategory.NPC
            ? bodyA.node
            : bodyB.node
            
            guard let player = playerNode as? Arara,
                  let comprador = compradorNode as? NPC else {
                return
            }
            
            if comprador.state == .comprando {
                player.sell(comprador: comprador)
            }
        }
        //Verifica contato entre arara e cachorro
        if (bodyA.categoryBitMask == PhysicsCategory.Arara &&
            bodyB.categoryBitMask == PhysicsCategory.Cachorro) ||
            (bodyA.categoryBitMask == PhysicsCategory.Cachorro &&
             bodyB.categoryBitMask == PhysicsCategory.Arara) {

            let araraNode = bodyA.categoryBitMask == PhysicsCategory.Arara
            ? bodyA.node
            : bodyB.node
            
            let cachorroNode = bodyA.categoryBitMask == PhysicsCategory.Cachorro
            ? bodyA.node
            : bodyB.node
            
            guard let cachorro = cachorroNode as? Cachorro,
                  let revistado = araraNode as? Arara else {
                return
            }
            cachorro.revistar()
        }
        
        if (bodyA.categoryBitMask == PhysicsCategory.NPC &&
            bodyB.categoryBitMask == PhysicsCategory.Borda) ||
            (bodyA.categoryBitMask == PhysicsCategory.Borda &&
             bodyB.categoryBitMask == PhysicsCategory.NPC) {

            let NPCNode = bodyA.categoryBitMask == PhysicsCategory.NPC
            ? bodyA.node
            : bodyB.node
            
            let BordaNode = bodyA.categoryBitMask == PhysicsCategory.Borda
            ? bodyA.node
            : bodyB.node
            
            guard let npc = NPCNode as? NPC,
                  let borda = BordaNode as? borda else {
                return
            }
            
            npc.despawn()
        }
//        if (bodyA.categoryBitMask == PhysicsCategory.Arara &&
//            bodyB.categoryBitMask == PhysicsCategory.Borda) ||
//            (bodyA.categoryBitMask == PhysicsCategory.Arara &&
//             bodyB.categoryBitMask == PhysicsCategory.NPC) {
//            print("Contato entre Arara e Cachorro")
//
//            let NPCNode = bodyA.categoryBitMask == PhysicsCategory.Arara
//            ? bodyA.node
//            : bodyB.node
//            
//            let BordaNode = bodyA.categoryBitMask == PhysicsCategory.Borda
//            ? bodyA.node
//            : bodyB.node
//            
//            guard let npc = NPCNode as? Arara,
//                  let borda = BordaNode as? borda else {
//                return
//            }
//            
//        }
        
        
    }
}
