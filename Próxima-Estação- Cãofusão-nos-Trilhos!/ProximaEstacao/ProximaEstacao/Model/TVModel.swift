//
//  Pessoa.swift
//  ProximaEstacao
//
//  Created by Vinicius Marques on 26/02/26.
//

import GameKit
import SpriteKit

#if os(tvOS)
class TVModel {
    public static var shared: TVModel {
        return TVModel()
    }
    var cenario: CustomScene?
    
    private init() {}
}

#endif
