//
//  SavedBill.swift
//  EventsApp
//
//  Modelo persistido pelo SwiftData para guardar o histórico de contas
//  já divididas e finalizadas, para futura consulta/exportação.
//

import Foundation
import SwiftData
import SwiftUI
import UIKit

/// Uma conta já finalizada e paga, guardada no histórico.
///
/// É salva uma única vez, no momento em que o pagamento é concluído
/// em `CardView` (ver `BillViewModel.saveBillToHistory()`), como um
/// "retrato" da conta naquele instante — mudanças posteriores em
/// `Bill`/`Product`/`User` não afetam registros já salvos aqui.
@Model
final class SavedBill {
    var id: UUID
    var date: Date
    var serviceFeePercentage: Double

    /// Soma dos itens, sem a taxa de serviço.
    var subtotal: Double

    /// Total da conta já incluindo a taxa de serviço.
    var grandTotal: Double

    @Relationship(deleteRule: .cascade, inverse: \SavedBillItem.bill)
    var items: [SavedBillItem] = []

    @Relationship(deleteRule: .cascade, inverse: \SavedBillUser.bill)
    var users: [SavedBillUser] = []

    init(
        id: UUID = UUID(),
        date: Date = .now,
        serviceFeePercentage: Double,
        subtotal: Double,
        grandTotal: Double
    ) {
        self.id = id
        self.date = date
        self.serviceFeePercentage = serviceFeePercentage
        self.subtotal = subtotal
        self.grandTotal = grandTotal
    }
}

/// Um item da conta no momento em que ela foi finalizada.
@Model
final class SavedBillItem {
    var id: UUID
    var name: String
    var price: Double
    var quantity: Int

    /// Conta à qual este item pertence.
    var bill: SavedBill?

    init(
        id: UUID = UUID(),
        name: String,
        price: Double,
        quantity: Int
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.quantity = quantity
    }

    /// Valor total do item considerando a quantidade.
    var total: Double {
        price * Double(quantity)
    }
}

/// Um participante da conta no momento em que ela foi finalizada,
/// junto com o valor que ele pagou (já incluindo sua parte da taxa
/// de serviço).
@Model
final class SavedBillUser {
    var id: UUID
    var name: String
    var emoji: String
    var colorRed: Double
    var colorGreen: Double
    var colorBlue: Double
    var colorOpacity: Double

    /// Quanto esse participante pagou, já incluindo sua parte
    /// proporcional da taxa de serviço.
    var amountPaid: Double

    /// Conta à qual este participante pertence.
    var bill: SavedBill?

    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        color: Color,
        amountPaid: Double
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.amountPaid = amountPaid

        let uiColor = UIColor(color)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 1

        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            self.colorRed = Double(red)
            self.colorGreen = Double(green)
            self.colorBlue = Double(blue)
            self.colorOpacity = Double(alpha)
        } else {
            self.colorRed = 0.5
            self.colorGreen = 0.5
            self.colorBlue = 0.5
            self.colorOpacity = 1
        }
    }

    var color: Color {
        Color(
            red: colorRed,
            green: colorGreen,
            blue: colorBlue,
            opacity: colorOpacity
        )
    }
}
