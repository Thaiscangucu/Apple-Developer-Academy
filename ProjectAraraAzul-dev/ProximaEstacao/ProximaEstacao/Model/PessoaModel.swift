//
//  Pessoa.swift
//  ProximaEstacao
//
//  Created by Vinicius Marques on 26/02/26.
//

import GameKit
import GameController

struct PessoaModel {
    var pareamento : GKPlayer
    #if os(iOS)
    var controle: GCVirtualController
    #endif
    var playerScene : SKSpriteNode
    
}
