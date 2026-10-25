//
//  AddUserViewModel.swift
//  EventsApp
//
//  Created by Thais Cangucu on 15/09/26.
//

import SwiftUI
import UIKit

// MARK: - ViewModel (Regras de Negócio e Estado)

/// ViewModel compartilhada entre a tela `AddUsers` e o formulário `AddUserForm`.
/// Guarda o estado da tela de participantes (sheets, alertas, configurações,
/// notificações) e as regras do formulário de criação/edição de participantes.
@Observable
final class AddUserViewModel {

    // MARK: - Estado da Tela AddUsers

    /// Controla a apresentação do formulário de participantes.
    var showForm = false
    /// Alerta exibido ao tentar avançar sem participantes.
    var showEmptyAlert = false
    /// Controla a exibição da SettingsView.
    var settingsView = false


    /// Preferência de notificações, salva no UserDefaults
    /// e sincronizada com a permissão do iOS.
    var notificationsOn: Bool = UserDefaults.standard.bool(forKey: "notificationsOn") {
        didSet { UserDefaults.standard.set(notificationsOn, forKey: "notificationsOn") }
    }

    /// Alerta explicando que a permissão foi negada antes e precisa ser
    /// liberada nos Ajustes do iPhone (o iOS só mostra o pedido uma vez).
    var showNotificationsDeniedAlert = false

    /// A pessoa tentou ligar as notificações e foi mandada aos Ajustes do
    /// iPhone: ao voltar para o app com a permissão liberada, liga sozinho.
    private var wantsNotificationsAfterSettings = false

    // MARK: - Estado de Navegação e Edição
    var currentPage: Page = .existing
    var editingOldUserID: User.ID?
    /// `true` quando o formulário está criando/editando o "Meu Card".
    var isEditingMyCard = false
    /// Participante da conta (bolha) sendo editado pelo toque longo.
    var editingBillUserID: User.ID?
    
    enum Page {
        case existing
        case form
    }
    
    // MARK: - Estado dos Campos do Formulário
    var name: String = ""
    var selectedEmoji: String = "🤓"
    var selectedColor: Color = .red
    
    /// Card do próprio usuário do app, salvo no UserDefaults.
    var myCard: User? = MyCardStore.load()

    /// Título da navegação da sheet de acordo com a página/modo atual.
    var formTitle: String {
        if currentPage == .existing { return String(localized: "Participantes") }
        if isEditingMyCard { return String(localized: "Meu Card") }
        return (editingOldUserID != nil || editingBillUserID != nil) ? String(localized: "Editar Participante") : String(localized: "Novo Participante")
    }
    
    // MARK: - Estado de Alertas
    var showAlert = false
    var alertMessage = ""
    
    // MARK: - Dados de Seleção
    let predefinedColors: [Color] = [
        Color(red: 1, green: 0.05, blue: 0.1),
        Color(red: 1, green: 0.56, blue: 0),
        Color(red: 1, green: 0.84, blue: 0.04),
        Color(red: 0.47, green: 1, blue: 0.35),
        Color(red: 0.1, green: 0.68, blue: 0.97),
        Color(red: 0, green: 0.49, blue: 1),
        .black,
        Color(red: 0.57, green: 0.57, blue: 0.57),
        Color(red: 0.4, green: 0.5, blue: 0.34),
        Color(red: 0.39, green: 0.39, blue: 0.8),
        Color(red: 0.76, green: 0, blue: 1),
        Color(red: 0.39, green: 0.12, blue: 0.25)
    ]
    
    let emojis = ["🤓", "😎", "😇", "🥸", "🥳", "🧐", "👨🏻‍🔬", "🧑‍💻", "🎈", "🌈", "🐙", "🕹️"]
    
    // MARK: - Transições de Tela
    func startNewUser() {
        editingOldUserID = nil
        editingBillUserID = nil
        isEditingMyCard = false
        name = ""
        randomizeSelection()
        
        withAnimation {
            currentPage = .form
        }
    }
    
    func startEditingUser(_ user: User) {
        isEditingMyCard = false
        editingBillUserID = nil
        name = user.name
        selectedEmoji = user.emoji
        selectedColor = user.color
        editingOldUserID = user.id
        
        // Vem do menu de toque longo: espera ele fechar antes de trocar de página.
        showFormAfterContextMenu()
    }
    
    func cancelForm() {
        isEditingMyCard = false
        editingBillUserID = nil
        withAnimation {
            currentPage = .existing
        }
    }
    
    /// Abre o formulário para criar o "Meu Card" ou, se já existir, editá-lo.
    func startMyCardForm(fromContextMenu: Bool = false) {
        editingOldUserID = nil
        editingBillUserID = nil
        isEditingMyCard = true

        if let myCard {
            name = myCard.name
            selectedEmoji = myCard.emoji
            selectedColor = myCard.color
        } else {
            name = ""
            randomizeSelection()
        }

        if fromContextMenu {
            showFormAfterContextMenu()
        } else {
            withAnimation {
                currentPage = .form
            }
        }
    }

    /// O menu de toque longo (`contextMenu`) tem a própria animação de
    /// fechar, que "devolve" a prévia para o card de origem. Se a página
    /// troca ao mesmo tempo, o card some no meio dessa animação e ela
    /// fica quebrada. Por isso esperamos o menu fechar antes de trocar.
    private func showFormAfterContextMenu() {
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            withAnimation {
                currentPage = .form
            }
        }
    }

    // MARK: - Seleção Aleatória
    func randomizeSelection() {
        if let randomEmoji = emojis.randomElement() {
            selectedEmoji = randomEmoji
        }
        if let randomColor = predefinedColors.randomElement() {
            selectedColor = randomColor
        }
    }
    
    // MARK: - Verificações de Usuários na Bill
    
    /// Checa se um participante salvo (ou o Meu Card) já está na Bill.
    ///
    /// A comparação é pelo id: cada participante da conta é uma cópia que
    /// guarda o id de origem em `sourceID`. Antes era pelo nome, e aí duas
    /// pessoas diferentes com o mesmo nome (ex.: o Meu Card e um amigo
    /// homônimo) eram tratadas como a mesma e uma bloqueava a outra.
    func isUserInBill(_ user: User, in billViewModel: BillViewModel) -> Bool {
        billViewModel.bill.users.contains {
            $0.sourceID == user.id || $0.id == user.id
        }
    }
    
    func canBeginAddingExistingUser(_ user: User, in billViewModel: BillViewModel) -> Bool {
        guard !isUserInBill(user, in: billViewModel) else {
            triggerAlert("Este participante já foi adicionado à conta!")
            randomizeSelection()
            return false
        }
        
        guard billViewModel.bill.users.count < 12 else {
            triggerAlert("Limite de participantes atingido!")
            return false
        }
        
        return true
    }
    
    func completeExistingUserAddition(_ user: User, in billViewModel: BillViewModel) {
        // Entra como cópia ligada ao participante salvo (sourceID), para
        // que editar o salvo atualize o círculo na bolha.
        billViewModel.addOldUserToBill(user)
        
        triggerHaptic()
    }
    
    /// Adiciona um usuário pré-existente (da lista `oldUsers`) à Bill com todas as validações de limite e duplicidade.
    @discardableResult
    func addExistingUser(_ user: User, in billViewModel: BillViewModel) -> Bool {
        
        guard canBeginAddingExistingUser(user, in: billViewModel) else {
            return false
        }
        
        completeExistingUserAddition(user, in: billViewModel)
        
        return true
    }
    
    func canBeginAddingMyCard(_ user: User, in billViewModel: BillViewModel) -> Bool {
        guard !isUserInBill(user, in: billViewModel) else {
            triggerAlert("Você já foi adicionado à conta")
            return false
        }
        
        guard billViewModel.bill.users.count < 12 else {
            triggerAlert("Limite de participantes atingido")
            return false
        }
        
        return true
    }
    
    func completeMyCardAddition(_ user: User, in billViewModel: BillViewModel) {
        billViewModel.addOldUserToBill(user)
        triggerHaptic()
    }
    
    /// Adiciona o "Meu Card" à Bill, sem salvá-lo na lista de antigos usuários.
    @discardableResult
    func addMyCardToBill(in billViewModel: BillViewModel) -> Bool {
        guard let myCard else { return false }
        
        guard canBeginAddingMyCard(myCard, in: billViewModel) else {
            return false
        }
        
        completeMyCardAddition(myCard, in: billViewModel)

        return true
    }

    // MARK: - Persistência e Validação do Formulário

    /// Ação do botão ✓ (e do "ir" do teclado): decide o que salvar
    /// de acordo com o modo do formulário.
    func submitForm(in billViewModel: BillViewModel) {
        if let billUserID = editingBillUserID {
            saveEditedBillUser(id: billUserID, in: billViewModel)
        } else if isEditingMyCard {
            saveMyCard(in: billViewModel)
        } else if let editingID = editingOldUserID {
            saveEditedUser(id: editingID, in: billViewModel)
        } else {
            saveUser(in: billViewModel)
        }
    }

    /// Cria ou atualiza o "Meu Card" e volta para a lista.
    @discardableResult
    func saveMyCard(in billViewModel: BillViewModel) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            triggerAlert("Digite o seu nome.")
            return false
        }

        // Não pode ser igual (nome, emoji e cor) a um participante já salvo
        // ou já na conta. A cópia do próprio Meu Card na conta não conta.
        let myCardID = myCard?.id
        let candidate = User(name: trimmedName, emoji: selectedEmoji, color: selectedColor)
        let othersInBill = billViewModel.bill.users.filter { myCardID == nil || $0.sourceID != myCardID }

        guard !containsIdenticalUser(candidate, in: othersInBill + billViewModel.oldUsers) else {
            triggerAlert("Já existe um participante com esse nome, emoji e cor.")
            return false
        }

        // Mantém o mesmo id ao editar.
        let card = User(
            id: myCard?.id ?? UUID(),
            name: trimmedName,
            emoji: selectedEmoji,
            color: selectedColor
        )

        MyCardStore.save(card)
        myCard = card
        // Se o Meu Card já está na conta, atualiza o círculo na bolha.
        billViewModel.syncBillUsers(withSource: card)
        triggerHaptic()

        isEditingMyCard = false
        name = ""
        withAnimation {
            currentPage = .existing
        }
        return true
    }

    /// Apaga o "Meu Card" salvo.
    func deleteMyCard() {
        MyCardStore.delete()
        withAnimation {
            myCard = nil
        }
    }
    @discardableResult
    func saveUser(in billViewModel: BillViewModel) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            triggerAlert("Digite um nome para o participante.")
            return false
        }

        // Não pode ser igual (nome, emoji e cor) ao Meu Card.
        let candidate = User(name: trimmedName, emoji: selectedEmoji, color: selectedColor)
        if let myCard, isIdentical(candidate, myCard) {
            triggerAlert("Esse participante é igual ao seu card.")
            return false
        }

        // A cópia do Meu Card na conta não entra nessa checagem de nome: ter
        // o mesmo nome que você é permitido (só não pode ser idêntico em
        // nome, emoji e cor, o que já foi checado acima).
        let isDuplicateInBill = billViewModel.bill.users.contains {
            guard myCard == nil || $0.sourceID != myCard?.id else { return false }
            return $0.name.trimmingCharacters(in: .whitespacesAndNewlines)
                .localizedCaseInsensitiveCompare(trimmedName) == .orderedSame
        }
        
        let isDuplicateInOldUsers = billViewModel.oldUsers.contains {
            $0.name.trimmingCharacters(in: .whitespacesAndNewlines)
                .localizedCaseInsensitiveCompare(trimmedName) == .orderedSame
        }

        guard !isDuplicateInBill else {
            triggerAlert("Este participante já foi adicionado à conta.")
            name = ""
            randomizeSelection()
            return false
        }
        
        guard !isDuplicateInOldUsers else {
            triggerAlert("Este participante já existe na sua lista de antigos usuários.")
            return false
        }

        let isDuplicateAppearanceInBill = billViewModel.bill.users.contains {
            $0.emoji == selectedEmoji && colorsMatch($0.color, selectedColor)
        }

        let isDuplicateAppearanceInOldUsers = billViewModel.oldUsers.contains {
            $0.emoji == selectedEmoji && colorsMatch($0.color, selectedColor)
        }

        guard !isDuplicateAppearanceInBill && !isDuplicateAppearanceInOldUsers else {
            triggerAlert("Já existe um participante com essa cor e esse emoji.")
            return false
        }
        
        guard billViewModel.bill.users.count < 12 else {
            triggerAlert("Limite de participantes atingido.")
            return false
        }

        billViewModel.addUser(name: trimmedName, emoji: selectedEmoji, color: selectedColor)

        name = ""
        triggerHaptic()
        randomizeSelection()
        
        return true
    }

    func saveEditedUser(id: User.ID, in billViewModel: BillViewModel) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            triggerAlert("Digite um nome para o participante.")
            return
        }

        var updated = User(name: trimmedName, emoji: selectedEmoji, color: selectedColor)
        updated.id = id

        // Não pode ficar igual (nome, emoji e cor) ao Meu Card nem a outro salvo.
        if let myCard, isIdentical(updated, myCard) {
            triggerAlert("Esse participante é igual ao seu card.")
            return
        }
        guard !containsIdenticalUser(updated, in: billViewModel.oldUsers.filter { $0.id != id }) else {
            triggerAlert("Já existe um participante com esse nome, emoji e cor.")
            return
        }
        billViewModel.updateOldUser(updated)
        // Se esse participante já está na conta, atualiza o círculo na bolha.
        billViewModel.syncBillUsers(withSource: updated)

        editingOldUserID = nil
        name = ""

        withAnimation {
            currentPage = .existing
        }
    }
    
    // MARK: - Edição de Participante da Conta (bolha)

    /// Abre a sheet direto no formulário para editar um participante da conta.
    func startEditingBillUser(id: User.ID, in billViewModel: BillViewModel) {
        guard let user = billViewModel.bill.users.first(where: { $0.id == id }) else { return }

        editingOldUserID = nil
        isEditingMyCard = false
        editingBillUserID = id

        name = user.name
        selectedEmoji = user.emoji
        selectedColor = user.color

        currentPage = .form
        showForm = true
    }

    /// Salva nome, emoji e cor do participante da conta e fecha a sheet.
    /// Os itens que ele já consumiu são mantidos.
    func saveEditedBillUser(id: User.ID, in billViewModel: BillViewModel) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            triggerAlert("Digite um nome para o participante.")
            return
        }

        let isDuplicateName = billViewModel.bill.users.contains {
            $0.id != id &&
            $0.name.trimmingCharacters(in: .whitespacesAndNewlines)
                .localizedCaseInsensitiveCompare(trimmedName) == .orderedSame
        }

        guard !isDuplicateName else {
            triggerAlert("Este participante já foi adicionado à conta.")
            return
        }

        guard let index = billViewModel.bill.users.firstIndex(where: { $0.id == id }) else { return }

        billViewModel.bill.users[index].name = trimmedName
        billViewModel.bill.users[index].emoji = selectedEmoji
        billViewModel.bill.users[index].color = selectedColor

        triggerHaptic()
        editingBillUserID = nil
        name = ""
        showForm = false
    }

    // MARK: - Ações da Tela AddUsers

    /// Abre o formulário sempre na lista de participantes (ou direto no
    /// formulário, se não houver participantes salvos — ver `AddUserForm`).
    func openForm() {
        currentPage = .existing
        editingOldUserID = nil
        editingBillUserID = nil
        isEditingMyCard = false
        name = ""
        showForm = true
    }

    func toggleSettings() {
        withAnimation { settingsView.toggle() }
    }

    func closeSettings() {
        withAnimation { settingsView = false }
    }

    /// Remove direto da conta o participante tocado na bolha.
    /// O haptic toca no momento do toque, em
    /// `playRemoveFeedback()`, e não aqui (que roda quando o voo termina).
    func removeUserFromBill(id: User.ID, in billViewModel: BillViewModel) {
        billViewModel.bill.users.removeAll { $0.id == id }
    }

    /// Haptic seco ao tocar num participante para removê-lo.
    /// Só toca se "Animações & haptics" estiver ligado nos Ajustes.
    func playRemoveFeedback() {
        guard AppSettings.isAnimationsOn else { return }
        removeHaptic.impactOccurred(intensity: 1.0)
        removeHaptic.prepare()
    }

    /// Gerador do haptic de remoção, já preparado para responder sem atraso.
    @ObservationIgnored private lazy var removeHaptic: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        return generator
    }()

    /// Avança para o scanner, ou mostra o alerta se não houver participantes.
    func continueToScan(billViewModel: BillViewModel, scanViewModel: ScanViewModel) {
        guard !billViewModel.bill.users.isEmpty else {
            showEmptyAlert = true
            return
        }
        billViewModel.restoreServiceFee()
        scanViewModel.showScanner = true
    }

    // MARK: - Notificações

    /// Sincroniza o toggle com a permissão real do iOS ao abrir a tela.
    /// Também roda quando o app volta para a frente (ex.: depois dos Ajustes).
    @MainActor
    func syncNotificationPermission() async {
        if !(await NotificationManagerModel.isAuthorized()) {
            // Usuário negou nos Ajustes do iOS: o toggle reflete Off.
            notificationsOn = false
        } else if wantsNotificationsAfterSettings {
            // Voltou dos Ajustes com a permissão liberada: liga o toggle
            // (o onChange agenda as notificações).
            wantsNotificationsAfterSettings = false
            notificationsOn = true
            UserDefaults.standard.set(true, forKey: "notificationsOnSet")
        } else if !UserDefaults.standard.bool(forKey: "notificationsOnSet") {
            // Primeira vez com permissão concedida: começa ligado.
            notificationsOn = true
            UserDefaults.standard.set(true, forKey: "notificationsOnSet")
        }
    }

    /// Reage à mudança do toggle de notificações.
    @MainActor
    func notificationsChanged(to isOn: Bool) {
        if isOn {
            Task {
                // O iOS só mostra o pedido de permissão UMA vez. Se a pessoa
                // já negou, `requestAuthorization` volta `false` na hora, sem
                // mostrar nada — por isso o toggle "não ligava" nunca mais.
                // Nesse caso, explica e oferece abrir os Ajustes do iPhone.
                if await NotificationManagerModel.authorizationStatus() == .denied {
                    notificationsOn = false
                    showNotificationsDeniedAlert = true
                    return
                }

                // Nunca perguntado (ou já autorizado): pede/agenda normalmente.
                if await NotificationManagerModel.enableNotifications() {
                    UserDefaults.standard.set(true, forKey: "notificationsOnSet")
                } else {
                    notificationsOn = false
                }
            }
        } else {
            // Marca o botão como configurado: assim, ao abrir o app de novo,
            // o ContentView respeita o "desligado" e não reagenda nada.
            UserDefaults.standard.set(true, forKey: "notificationsOnSet")
            NotificationManagerModel.disableNotifications()
        }
    }

    /// Abre a tela de notificações deste app nos Ajustes do iPhone.
    @MainActor
    func openNotificationSettings() {
        wantsNotificationsAfterSettings = true
        guard let url = URL(string: UIApplication.openNotificationSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Métodos Privados Auxiliares

    /// Dois participantes são "iguais" quando têm o mesmo nome (sem diferenciar
    /// maiúsculas/minúsculas e espaços nas pontas), o mesmo emoji e a mesma cor.
    private func isIdentical(_ lhs: User, _ rhs: User) -> Bool {
        let lhsName = lhs.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let rhsName = rhs.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return lhsName.localizedCaseInsensitiveCompare(rhsName) == .orderedSame
            && lhs.emoji == rhs.emoji
            && colorsMatch(lhs.color, rhs.color)
    }

    private func containsIdenticalUser(_ user: User, in users: [User]) -> Bool {
        users.contains { isIdentical(user, $0) }
    }
    private func triggerAlert(_ message: LocalizedStringResource) {
        alertMessage = String(localized: message)
        showAlert = true
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Compara duas Colors pelos componentes RGBA resolvidos, já que cores
    /// nomeadas (ex.: `.red`) e cores reconstruídas a partir de valores salvos
    /// (`Color(red:green:blue:opacity:)`) não são `==` mesmo sendo a mesma cor.
    private func colorsMatch(_ lhs: Color, _ rhs: Color) -> Bool {
        var lr: CGFloat = 0, lg: CGFloat = 0, lb: CGFloat = 0, la: CGFloat = 0
        var rr: CGFloat = 0, rg: CGFloat = 0, rb: CGFloat = 0, ra: CGFloat = 0

        UIColor(lhs).getRed(&lr, green: &lg, blue: &lb, alpha: &la)
        UIColor(rhs).getRed(&rr, green: &rg, blue: &rb, alpha: &ra)

        let tolerance: CGFloat = 0.01
        return abs(lr - rr) < tolerance
            && abs(lg - rg) < tolerance
            && abs(lb - rb) < tolerance
            && abs(la - ra) < tolerance
    }
}
