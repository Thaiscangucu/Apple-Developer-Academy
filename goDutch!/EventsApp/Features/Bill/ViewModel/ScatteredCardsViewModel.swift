
//
//  ScatteredCardsViewModel.swift
//  POCMoveCards
//

import SwiftUI

@Observable
class ScatteredCardsViewModel {

    var totalAmount: Double = 0.0

    var targetAmount: Double = 0.0

    var isCompleted: Bool = false

    /// Quem já foi arrastado para "Pago" (usado pelo VoiceOver para listar
    /// só quem ainda falta pagar).
    var paidUserIDs: Set<UUID> = []

    /// Preenchido pela CardsScene: marca uma pessoa como paga sem arrasto.
    @ObservationIgnored
    var markUserAsPaid: ((UUID) -> Void)?

    /// Preenchido pela CardsScene: leva todos os cards que faltam para o
    /// círculo de "Pago" (com ou sem animação de voo).
    @ObservationIgnored
    var payAllUsers: ((_ animated: Bool) -> Void)?

    /// Preenchido pela CardsScene: esconde/mostra o card de uma pessoa
    /// enquanto a cópia dele aparece em destaque acima da sheet de consumo.
    @ObservationIgnored
    var setCardHidden: ((_ userID: UUID, _ hidden: Bool) -> Void)?

    /// Quem paga por quem (cards juntados). Ver `PaymentGroups`.
    var groups = PaymentGroups()

    /// Preenchido pela CardsScene: junta o card de `userID` no card de
    /// `payerID` (mesmo efeito de soltar um card em cima do outro).
    @ObservationIgnored
    var mergeCards: ((_ userID: UUID, _ payerID: UUID) -> Void)?

    /// Preenchido pela CardsScene: separa a pessoa do grupo e o card dela
    /// volta a aparecer na tela.
    @ObservationIgnored
    var splitCard: ((_ userID: UUID) -> Void)?

    /// Marca como pago todo mundo do grupo da pagadora.
    func markGroupAsPaid(payerID: UUID) {
        for member in groups.members(of: payerID) {
            paidUserIDs.insert(member)
        }
    }

    /// `true` enquanto os cards estão voando para o círculo após
    /// "Concluir pagamento" — trava o botão para não disparar de novo.
    var isPayingAll: Bool = false

    // MARK: - Formatação

    private func formatAmount(_ amount: Double) -> String {

        CurrencyHelper.format(amount)
    }

    var formattedTotal: String {
        formatAmount(totalAmount)
    }

    var formattedTarget: String {
        formatAmount(targetAmount)
    }

    // MARK: - Reset

    func reset() {
        
        totalAmount = 0.0
        targetAmount = 0.0
        isCompleted = false
        isPayingAll = false
        paidUserIDs = []
        groups.reset()
    }
}

