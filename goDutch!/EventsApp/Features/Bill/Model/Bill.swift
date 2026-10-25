//
//  Bill.swift
//  EventsApp
//
//  Created by Thais Cangucu on 07/08/26.
//

import SwiftUI

struct Bill: Identifiable{
    var id: UUID = UUID()
    var serviceFeePercentage: Double = 0.0

    /// Indica se a taxa de serviço foi removida da conta (via swipe na
    /// comanda). Enquanto for `true`, a taxa deixa de entrar no cálculo
    /// do total, mesmo que `serviceFeePercentage` continue guardando a
    /// porcentagem configurada.
    var isServiceFeeRemoved: Bool = false
    
    var items: [Product] = []
    var users: [User] = []
    
//    var users: [User] = [User(name: "Thais", emoji: "🌈", color: .yellow), User(name: "Motta", emoji: "🎈", color: .green), User(name: "Parolin", emoji: "🦅", color: .red), User(name: "Yasmin", emoji: "🌸", color: .blue)]
//    var items: [Product] = [Product(name: "Cerveja", price: 16.50, quantity: 7), Product(name: "Batata", price: 70, quantity: 1)]
//    
}

