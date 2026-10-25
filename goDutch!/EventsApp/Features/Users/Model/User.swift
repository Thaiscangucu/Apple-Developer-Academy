//
//  Untitled.swift
//  EventsApp
//
//  Created by Thais Cangucu on 07/08/26.
//

import SwiftUI

struct User: Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var emoji: String
    var items: [Product] = []
    var color: Color
    /// Para participantes da conta: id do participante salvo (ou do Meu Card)
    /// de onde ele veio. Usado para atualizar o círculo na bolha quando o
    /// original é editado.
    var sourceID: UUID?
    
    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        color: Color,
        sourceID: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.color = color
        self.sourceID = sourceID
        self.items = []
    }
}
