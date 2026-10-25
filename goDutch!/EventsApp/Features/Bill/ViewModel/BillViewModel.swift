//
//  ContaViewModel.swift
//  EventsApp
//
//  Created by Thais Cangucu on 11/08/26.
//

import Foundation
import SwiftUI
import SwiftData
import UIKit

/// ViewModel responsável por toda a lógica de negócio da conta compartilhada:
/// criação da conta, gerenciamento de itens e usuários, atribuição de itens
/// a usuários e cálculo de valores.
///
/// Segue o padrão MVVM: as Views (`ContaView`, `AddUsers`, `SplitView`, etc.)
/// apenas leem o estado publicado aqui e chamam estes métodos em resposta a
/// ações do usuário — nenhuma regra de negócio deve viver nas Views.
///
/// Por ser `@Observable`, qualquer View que leia propriedades desta classe via
/// `@Environment(BillViewModel.self)` é automaticamente re-renderizada quando
/// esses valores mudam.
@Observable
class BillViewModel {
    /// A conta atualmente ativa, contendo a lista de itens e de usuários.
    ///
    /// Começa vazia (`Bill()`) e é substituída por `createNewBill()`
    /// quando o usuário inicia uma nova divisão de conta.
    var bill: Bill = Bill()

    /// Lista de usuários que já foram cadastrados anteriormente.
    ///
    /// Esses usuários são carregados do SwiftData quando o `ModelContext`
    /// é configurado.
    var oldUsers: [User] = [User(name: "Motta", emoji: "🍌", color: .blue)]
    
    // MARK: - Conta

    /// Soma do preço total de todos os itens da conta, ponderado pela
    /// quantidade de cada um.
    var total: Double {
        bill.items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }

    /// Valor da taxa de serviço calculado sobre o total da conta.
    /// Retorna 0 quando a taxa foi removida via swipe na comanda.
    var serviceFee: Double {
        guard !bill.isServiceFeeRemoved else { return 0 }
        return total * (bill.serviceFeePercentage / 100)
    }

    /// Valor total da conta incluindo a taxa de serviço.
    var grandTotal: Double {
        total + serviceFee
    }

    /// Contexto utilizado pelo SwiftData para salvar e recuperar
    /// os participantes previamente cadastrados.
    private var modelContext: ModelContext?

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }

    // MARK: - SwiftData

    /// Configura o contexto do SwiftData e carrega os usuários
    /// previamente cadastrados.
    func setModelContext(_ context: ModelContext) {
        modelContext = context
        loadOldUsers()
    }

    /// Carrega do SwiftData todos os participantes previamente cadastrados
    /// e transforma cada `SavedUser` em um `User` utilizado pela aplicação.
    func loadOldUsers() {
        guard let modelContext else { return }

        do {
            let descriptor = FetchDescriptor<SavedUser>(
                sortBy: [SortDescriptor(\.name)]
            )

            let savedUsers = try modelContext.fetch(descriptor)

            oldUsers = savedUsers.map { savedUser in
                User(
                    id: savedUser.id,
                    name: savedUser.name,
                    emoji: savedUser.emoji,
                    color: savedUser.color
                )
            }
        } catch {
            print("Erro ao carregar usuários salvos: \(error)")
        }
    }

    /// Salva um participante no SwiftData caso ele ainda não exista.
    ///
    /// A comparação é feita pelo nome para evitar que o mesmo participante
    /// seja salvo várias vezes.
    private func saveUser(_ user: User) {
        guard let modelContext else { return }

        do {
            let descriptor = FetchDescriptor<SavedUser>()
            let savedUsers = try modelContext.fetch(descriptor)

            let alreadyExists = savedUsers.contains {
                $0.name.caseInsensitiveCompare(user.name) == .orderedSame
            }

            guard !alreadyExists else {
                return
            }

            let savedUser = SavedUser(
                id: user.id,
                name: user.name,
                emoji: user.emoji,
                color: user.color
            )

            modelContext.insert(savedUser)
            try modelContext.save()

            oldUsers.append(user)
            oldUsers.sort {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        } catch {
            print("Erro ao salvar usuário: \(error)")
        }
    }

    /// Remove um participante da lista de usuários salvos no SwiftData.
    func removeOldUser(_ user: User) {
        guard let modelContext else {
            withAnimation(.easeInOut(duration: 0.25)) {
                oldUsers.removeAll { $0.id == user.id }
            }
            return
        }

        do {
            let descriptor = FetchDescriptor<SavedUser>()
            let savedUsers = try modelContext.fetch(descriptor)

            if let savedUser = savedUsers.first(where: { $0.id == user.id }) {
                modelContext.delete(savedUser)
                try modelContext.save()
            }

            // Só a remoção da lista precisa de animação — é o que a
            // List/ForEach observa pra tocar a transição da linha.
            withAnimation(.easeInOut(duration: 0.25)) {
                oldUsers.removeAll { $0.id == user.id }
            }
        } catch {
            print("Erro ao remover usuário salvo: \(error)")
        }
    }

    /// Atualiza os dados de um participante que já está salvo no SwiftData.
    func updateOldUser(_ updated: User) {
        guard let modelContext else {
            if let index = oldUsers.firstIndex(where: { $0.id == updated.id }) {
                oldUsers[index] = updated
            }
            return
        }

        do {
            let descriptor = FetchDescriptor<SavedUser>()
            let savedUsers = try modelContext.fetch(descriptor)

            guard let savedUser = savedUsers.first(where: { $0.id == updated.id }) else {
                return
            }

            savedUser.name = updated.name
            savedUser.emoji = updated.emoji

            let uiColor = UIColor(updated.color)

            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 1

            if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
                savedUser.colorRed = Double(red)
                savedUser.colorGreen = Double(green)
                savedUser.colorBlue = Double(blue)
                savedUser.colorOpacity = Double(alpha)
            }

            try modelContext.save()

            if let index = oldUsers.firstIndex(where: { $0.id == updated.id }) {
                oldUsers[index] = updated
            }
        } catch {
            print("Erro ao atualizar usuário salvo: \(error)")
        }
    }


    /// Remove a taxa de serviço da conta atual. A partir daqui, o valor
    /// da taxa passa a ser 0 em todos os cálculos, mas a porcentagem
    /// configurada em `bill.serviceFeePercentage` é preservada — ela só
    /// volta a valer numa conta nova (`createNewBill()`).
    func removeServiceFee() {
        bill.isServiceFeeRemoved = true
    }

    /// Restaura a taxa de serviço removida anteriormente, voltando a
    /// considerá-la no cálculo do total com a porcentagem já configurada
    /// em `bill.serviceFeePercentage`. Chamado ao reiniciar a etapa de
    /// montar a conta (escanear a nota ou adicionar itens manualmente).
    func restoreServiceFee() {
        bill.isServiceFeeRemoved = false
    }

    /// Inicia uma nova conta vazia.
    func createNewBill() {
        self.bill = Bill()
    }

    /// Remove todos os itens e usuários da conta atual.
    ///
    /// Os usuários salvos no SwiftData não são removidos.
    func resetBill() {
        bill.items.removeAll()
        bill.users.removeAll()
    }

    /// Remove todos os itens da conta atual, mantendo os participantes.
    ///
    /// Também limpa os itens atribuídos a cada usuário, para não sobrar
    /// nenhuma referência a produtos que não existem mais na comanda.
    func clearItems() {
        bill.items.removeAll()
        for index in bill.users.indices {
            bill.users[index].items.removeAll()
        }
    }

    // MARK: - Itens

    /// Valida e adiciona um novo item à conta.
    @discardableResult
    func addItem(name: String, price: Double, quantity: Int) -> Result<Void, FormError> {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        guard !trimmedName.isEmpty else {
            return .failure(.emptyName)
        }

        guard price > 0 else {
            return .failure(.invalidPrice)
        }

        guard quantity > 0 else {
            return .failure(.invalidQuantity)
        }

        bill.items.append(
            Product(
                name: trimmedName,
                price: price,
                quantity: quantity
            )
        )

        return .success(())
    }

    /// Remove um item específico da conta, incluindo a cópia guardada
    /// em `user.items` de qualquer usuário que estivesse associado a ele.
    func removeItem(_ item: Product) {
        bill.items.removeAll { $0.id == item.id }
        syncUserItemsAfterRemoval(of: item.id)
        // Vale para o swipe na comanda e para a lixeira do form de edição.
        Haptics.itemRemoved()
    }

    /// Atualiza um item já existente na conta, preservando os
    /// `assignedUserIDs` que já estavam nele.
    func updateItem(_ updated: Product) {
        guard let index = bill.items.firstIndex(where: { $0.id == updated.id }) else {
            return
        }

        bill.items[index] = updated
        syncUserItemsAfterUpdate(updated)
    }

    /// Adiciona itens escaneados via OCR + Apple Intelligence à conta atual,
    /// sem descartar itens ou usuários já existentes.
    func addScannedItems(_ items: [Product]) {
        bill.items.append(contentsOf: items)
    }

    // MARK: - Usuários

    /// Valida e adiciona um novo usuário à conta atual.
    ///
    /// O participante também é salvo no SwiftData para aparecer
    /// como opção em contas futuras.
    func addUser(name: String, emoji: String, color: Color) {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        guard !trimmedName.isEmpty else {
            return
        }

        let id = UUID()
        let user = User(
            id: id,
            name: trimmedName,
            emoji: emoji,
            color: color,
            // Salvo com o mesmo id, então ele é a própria origem.
            sourceID: id
        )

        bill.users.append(user)
        saveUser(user)
    }

    /// Adiciona um usuário previamente salvo à conta atual.
    ///
    /// O usuário original salvo no SwiftData não é alterado.
    /// É criada uma nova instância de `User` para a conta atual.
    func addOldUserToBill(_ oldUser: User) {
        let user = User(
            id: UUID(),
            name: oldUser.name,
            emoji: oldUser.emoji,
            color: oldUser.color,
            sourceID: oldUser.id
        )

        bill.users.append(user)
    }

    /// Repassa nome, emoji e cor editados de um participante salvo (ou do
    /// Meu Card) para as cópias dele que já estão na conta — assim o
    /// círculo na bolha atualiza na hora. Os itens consumidos são mantidos.
    func syncBillUsers(withSource source: User) {
        for index in bill.users.indices where bill.users[index].sourceID == source.id {
            bill.users[index].name = source.name
            bill.users[index].emoji = source.emoji
            bill.users[index].color = source.color
        }
    }

    /// Verifica se um usuário com determinado nome já está na conta atual.
    func userAlreadyExists(name: String) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        return bill.users.contains {
            $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame
        }
    }

    /// Atribui um usuário a um item específico, marcando-o como
    /// corresponsável pelo pagamento daquele item, e guarda uma cópia
    /// do item em `user.items` para consulta posterior.
    func assignUser(_ userID: UUID, toProductID productID: Product.ID) {
        guard let productIndex = bill.items.firstIndex(where: { $0.id == productID }) else {
            return
        }

        bill.items[productIndex].assignedUserIDs.insert(userID)

        guard let userIndex = bill.users.firstIndex(where: { $0.id == userID }) else {
            return
        }

        let product = bill.items[productIndex]

        if let existingIndex = bill.users[userIndex].items.firstIndex(where: { $0.id == product.id }) {
            bill.users[userIndex].items[existingIndex] = product
        } else {
            bill.users[userIndex].items.append(product)
        }

        // Os outros usuários que já tinham esse item guardavam uma cópia com
        // os `assignedUserIDs` antigos (ex.: só 1 pessoa) — atualiza todos.
        syncUserItemsAfterUpdate(product)
    }

    /// Remove a atribuição de um usuário a um item, removendo também
    /// a cópia correspondente em `user.items`.
    func unassignUser(_ userID: UUID, fromProductID productID: Product.ID) {
        guard let productIndex = bill.items.firstIndex(where: { $0.id == productID }) else {
            return
        }

        bill.items[productIndex].assignedUserIDs.remove(userID)

        guard let userIndex = bill.users.firstIndex(where: { $0.id == userID }) else {
            return
        }

        bill.users[userIndex].items.removeAll { $0.id == productID }

        // Atualiza a cópia de quem continua no item (agora dividido por menos pessoas).
        syncUserItemsAfterUpdate(bill.items[productIndex])
    }

    ///Remove todos os usuários atribuídos a um produto em uma única atualização
    func unassignAllUsers(fromProductID productID: Product.ID) {
        var updatedBill = bill
        
        guard let productIndex = updatedBill.items.firstIndex(where: { $0.id == productID }) else {
            return
        }
        
        let assignedUserIDs = updatedBill.items[productIndex].assignedUserIDs
        
        guard !assignedUserIDs.isEmpty else {
            return
        }
                
        updatedBill.items[productIndex]
            .assignedUserIDs
            .removeAll()
        
        for userIdex in updatedBill.users.indices {
            let userID = updatedBill.users[userIdex].id
            
            guard assignedUserIDs.contains(userID) else {
                continue
            }
            
            updatedBill.users[userIdex].items.removeAll {
                $0.id == productID
            }
        }
        
        bill = updatedBill
                
    }
    
    
    // MARK: - Itens por Usuário

    /// Itens atribuídos a um usuário, lidos direto de `bill.items`
    /// (fonte da verdade), sempre com os `assignedUserIDs` atualizados.
    func items(for user: User) -> [Product] {
        bill.items.filter { $0.assignedUserIDs.contains(user.id) }
    }

    // MARK: - Valores
    /// Calcula quanto um usuário específico deve pagar no total, somando sua
    /// parte em cada item ao qual foi atribuído.
    func total(for user: User) -> Double {
        bill.items.reduce(0) { partial, product in
            guard product.assignedUserIDs.contains(user.id) else {
                return partial
            }

            return partial + product.pricePerAssignedUser
        }
    }

    /// Calcula o total de um usuário incluindo proporcionalmente
    /// a taxa de serviço da conta.
    func totalWithServiceFee(for user: User) -> Double {
        let userTotal = total(for: user)

        guard total > 0 else {
            return userTotal
        }

        let serviceFee = bill.isServiceFeeRemoved ? 0 : total * (bill.serviceFeePercentage / 100)
        let userServiceFee = serviceFee * (userTotal / total)

        return userTotal + userServiceFee
    }

    // MARK: - Histórico

    /// Salva um "retrato" da conta atual no histórico permanente
    /// (SwiftData), incluindo os itens e quanto cada participante pagou.
    ///
    /// Deve ser chamado quando a conta é efetivamente finalizada (hoje,
    /// no `onPaymentCompleted` de `CardView`), antes de `resetBill()`
    /// apagar os dados da conta em andamento. Registros já salvos aqui
    /// não são afetados por mudanças posteriores na `bill` atual — servem
    /// de base para uma futura tela de histórico e para exportação.
    @discardableResult
    func saveBillToHistory() -> SavedBill? {
        guard let modelContext else { return nil }

        // Não vale a pena guardar uma conta vazia no histórico.
        guard !bill.items.isEmpty else { return nil }

        let savedBill = SavedBill(
            serviceFeePercentage: bill.isServiceFeeRemoved ? 0 : bill.serviceFeePercentage,
            subtotal: total,
            grandTotal: grandTotal
        )

        savedBill.items = bill.items.map { item in
            SavedBillItem(
                id: item.id,
                name: item.name,
                price: item.price,
                quantity: item.quantity
            )
        }

        savedBill.users = bill.users.map { user in
            SavedBillUser(
                id: user.id,
                name: user.name,
                emoji: user.emoji,
                color: user.color,
                amountPaid: totalWithServiceFee(for: user)
            )
        }

        modelContext.insert(savedBill)

        do {
            try modelContext.save()
        } catch {
            print("Erro ao salvar histórico da conta: \(error)")
        }

        return savedBill
    }

    // MARK: - Sincronização auxiliar

    /// Remove um item da lista de itens de todos os usuários
    /// que tinham esse item atribuído.
    private func syncUserItemsAfterRemoval(of productID: Product.ID) {
        for index in bill.users.indices {
            bill.users[index].items.removeAll { $0.id == productID }
        }
    }

    /// Atualiza a cópia de um item armazenada nos usuários
    /// que possuem esse item atribuído.
    private func syncUserItemsAfterUpdate(_ updated: Product) {
        for index in bill.users.indices {
            guard let itemIndex = bill.users[index].items.firstIndex(where: { $0.id == updated.id }) else {
                continue
            }

            bill.users[index].items[itemIndex] = updated
        }
    }
}

extension BillViewModel {
    /// Retorna o valor total da conta incluindo a taxa de serviço.
    var totalWithServiceFeeForBill: Double {
        total + serviceFee
    }
}
