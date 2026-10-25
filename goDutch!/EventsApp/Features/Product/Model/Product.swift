//
//  Product.swift
//  EventsApp
//
//  Created by Thais Cangucu on 07/08/26.
//
import SwiftUI
import Foundation

struct Product: Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var price: Double
    var quantity: Int
    var assignedUserIDs: Set<UUID> = []

    /// Quanto cada pessoa atribuída paga por esse produto.
    var pricePerAssignedUser: Double {
        guard !assignedUserIDs.isEmpty else { return 0 }
        return total / Double(assignedUserIDs.count)
    }
}

extension Product {
    /// Cria um Product a partir do item identificado pela leitura da nota.
    @available(iOS 26.0, *)
    init(from generated: ConsumedItem) {
        self.id = UUID()
        self.name = generated.name
        self.price = generated.price
        self.quantity = generated.quantity
        self.assignedUserIDs = []
    }

    /// Valor total do produto considerando a quantidade comprada.
    var total: Double {
        price * Double(quantity)
    }
}

