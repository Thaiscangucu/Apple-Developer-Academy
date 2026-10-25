//
//  PaymentGroups.swift
//  EventsApp
//
//  Quem paga por quem na etapa de pagamento (TotalView).
//
//  Ex.: Thais vai pagar o dela e o do Motta → o card do Motta é solto em
//  cima do card da Thais e os dois viram um card só, com a soma dos
//  consumos. A Thais é a "pagadora" e o Motta fica "coberto" por ela.
//
//  O consumo de cada pessoa NÃO muda (os itens continuam atribuídos a
//  quem consumiu): só muda quem paga. Assim dá para separar de novo a
//  qualquer momento sem perder nada.
//

import Foundation

struct PaymentGroups: Equatable {

    /// Máximo de pessoas num card juntado (quem paga + quem ele cobre).
    static let maxMembers = 5

    /// Pagadora → pessoas que ela cobre, na ordem em que foram juntadas.
    private(set) var coveredByPayer: [UUID: [UUID]] = [:]

    // MARK: - Consultas

    /// Quem paga por essa pessoa (ela mesma, se ninguém a cobre).
    func payer(for userID: UUID) -> UUID {
        for (payer, covered) in coveredByPayer where covered.contains(userID) {
            return payer
        }
        return userID
    }

    /// `true` se outra pessoa paga por ela (e portanto ela não tem card).
    func isCovered(_ userID: UUID) -> Bool {
        payer(for: userID) != userID
    }

    /// Pessoas que essa pagadora cobre (sem incluir ela mesma).
    func covered(by payerID: UUID) -> [UUID] {
        coveredByPayer[payerID] ?? []
    }

    /// A pagadora seguida de quem ela cobre.
    func members(of payerID: UUID) -> [UUID] {
        [payerID] + covered(by: payerID)
    }

    /// Soma dos valores de todo o grupo de uma pagadora.
    func groupTotal(for payerID: UUID, totals: [UUID: Double]) -> Double {
        members(of: payerID).reduce(0) { $0 + (totals[$1] ?? 0) }
    }

    /// `true` se dá para juntar `userID` (com quem ele já cobre) no grupo
    /// de `payerID` sem passar de `maxMembers` pessoas.
    func canMerge(_ userID: UUID, into payerID: UUID) -> Bool {
        let finalPayer = payer(for: payerID)
        let movingPayer = payer(for: userID)
        guard finalPayer != movingPayer else { return false }

        // Quem paga leva o grupo inteiro; quem é coberto sai sozinho.
        let movingCount = movingPayer == userID ? members(of: userID).count : 1
        return members(of: finalPayer).count + movingCount <= Self.maxMembers
    }

    // MARK: - Alterações

    /// Junta `userID` (e quem ele já cobria) no grupo de quem paga por
    /// `payerID`. Retorna a pagadora final, ou `nil` se não fez nada
    /// (ex.: juntar alguém com ele mesmo ou com o próprio grupo).
    @discardableResult
    mutating func merge(_ userID: UUID, into payerID: UUID) -> UUID? {
        // Se quem recebe já é coberto por outra pessoa, o grupo vai para
        // a pagadora dela (não existe "pagador do pagador").
        let finalPayer = payer(for: payerID)
        let movingPayer = payer(for: userID)

        guard canMerge(userID, into: payerID) else { return nil }

        // Quem está sendo juntado leva junto as pessoas que ele cobria.
        let moving: [UUID]
        if movingPayer == userID {
            moving = members(of: userID)
            coveredByPayer[userID] = nil
        } else {
            // Era coberto por outra pessoa: sai só ele desse grupo.
            removeFromCurrentGroup(userID)
            moving = [userID]
        }

        coveredByPayer[finalPayer, default: []].append(contentsOf: moving)
        return finalPayer
    }

    /// Tira a pessoa do grupo em que ela está coberta: ela volta a pagar
    /// só o dela. Retorna quem pagava por ela (ou `nil` se já pagava só).
    @discardableResult
    mutating func split(_ userID: UUID) -> UUID? {
        guard isCovered(userID) else { return nil }
        let oldPayer = payer(for: userID)
        removeFromCurrentGroup(userID)
        return oldPayer
    }

    mutating func reset() {
        coveredByPayer = [:]
    }

    private mutating func removeFromCurrentGroup(_ userID: UUID) {
        let oldPayer = payer(for: userID)
        coveredByPayer[oldPayer]?.removeAll { $0 == userID }
        if coveredByPayer[oldPayer]?.isEmpty == true {
            coveredByPayer[oldPayer] = nil
        }
    }
}
