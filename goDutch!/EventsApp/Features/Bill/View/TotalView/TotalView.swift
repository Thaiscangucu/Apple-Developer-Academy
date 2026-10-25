//
//  ScatteredCardsScreen.swift
//  POCMoveCards
//

import SwiftUI
import SpriteKit

// MARK: - Total View 

struct TotalView: View {
    @Binding var path: NavigationPath
    @State private var cardsVm = ScatteredCardsViewModel()
    @Environment(BillViewModel.self) private var billVm
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var headerBottomY: CGFloat = 100
    @State private var sceneId = UUID()
    @State private var selectedUser: User?
    @State private var showsPayAllAlert = false

    // Card em destaque acima da sheet de consumo (igual ao protótipo).
    @State private var spotlightUser: User?
    @State private var spotlightOrigin: CGPoint = .zero
    @State private var isSpotlightLifted = false

    /// Altura da sheet de consumo (mesmo valor do presentationDetents).
    private let consumeSheetHeight: CGFloat = 514
    private let spotlightScale: CGFloat = 1.35

    /// Cards juntados: cada pessoa aparece separada acima da sheet, em
    /// zigue-zague. Posição horizontal da bolinha de cada card (fração da
    /// largura da tela), na ordem: quem paga, depois quem foi juntado.
    private let groupSpotlightColumns: [CGFloat] = [0.29, 0.50, 0.14, 0.40, 0.22]
    /// Distância vertical entre um card e o próximo (cards de 70pt de altura
    /// se sobrepõem um pouco, como no protótipo).
    private let groupSpotlightStep: CGFloat = 62

    /// 4 ou 5 pessoas (o máximo de um grupo): os cards ficam em duas
    /// colunas centralizadas, alternando esquerda/direita. Como cards
    /// vizinhos ficam em colunas diferentes, eles podem subir bem mais
    /// um ao lado do outro — e sobra espaço para ficarem maiores.
    private let groupSpotlightTwoColumnsFrom = 4
    /// Espaço entre as duas colunas e entre cards da mesma coluna.
    private let groupSpotlightGap: CGFloat = 10
    /// Maior tamanho que os cards podem ter nas duas colunas.
    private let groupSpotlightMaxScale: CGFloat = 1.15
    @AppStorage(AppSettings.animationsOn) private var animationsOn = true

    // TAMANHOS (ajuste aqui): o botão "pagar todos" cresce com o texto
    // (Dynamic Type) até `maxPayAllScale` vezes o tamanho original.
    @ScaledMetric(relativeTo: .body) private var payAllRawScale: CGFloat = 1
    private let maxPayAllScale: CGFloat = 1.35
    private var payAllScale: CGFloat { min(payAllRawScale, maxPayAllScale) }
    private var payAllButtonSize: CGFloat { max(44, 54 * payAllScale) }
    private var payAllIconSize: CGFloat { 28 * payAllScale }

    // MARK: - Progress

    private var progress: CGFloat {
        guard cardsVm.targetAmount > 0 else {
            return 0
        }

        return min(CGFloat(cardsVm.totalAmount / cardsVm.targetAmount), 1)
    }

    // MARK: - Scene

    private func makeScene() -> CardsScene {
        let scene = CardsScene()

        scene.size = UIScreen.main.bounds.size
        scene.scaleMode = .resizeFill
        scene.cardsVm = cardsVm
        scene.billVm = billVm
        scene.userTotals = userTotals
        scene.topBoundaryScreenY = headerBottomY + 16
        scene.onTapUser = { userID, avatarCenter in
            handleCardTap(userID: userID, avatarCenter: avatarCenter)
        }

        return scene
    }

    private var userTotals: [UUID: Double] {
        Dictionary(
            uniqueKeysWithValues: billVm.bill.users.map {
                ($0.id, billVm.totalWithServiceFee(for: $0))
            }
        )
    }

    // MARK: - Cards juntados (um paga pelo outro)

    /// Quem tem card próprio: todo mundo menos quem outra pessoa cobre.
    private var payers: [User] {
        billVm.bill.users.filter { !cardsVm.groups.isCovered($0.id) }
    }

    /// Valor de cada card: o consumo da pessoa + o de quem ela cobre.
    private var groupTotals: [UUID: Double] {
        let totals = userTotals
        return Dictionary(
            uniqueKeysWithValues: payers.map {
                ($0.id, cardsVm.groups.groupTotal(for: $0.id, totals: totals))
            }
        )
    }

    /// Pessoas que `payer` está cobrindo, na ordem em que foram juntadas.
    private func coveredUsers(of payer: User) -> [User] {
        cardsVm.groups.covered(by: payer.id).compactMap { id in
            billVm.bill.users.first { $0.id == id }
        }
    }

    /// Quem `payer` ainda pode cobrir: quem falta pagar, menos ele mesmo,
    /// sem passar de 5 pessoas no grupo.
    private func coverCandidates(for payer: User) -> [User] {
        unpaidUsers.filter {
            $0.id != payer.id && cardsVm.groups.canMerge($0.id, into: payer.id)
        }
    }

    /// `payer` passa a pagar também o consumo de `other`.
    private func merge(_ other: User, into payer: User) {
        if typeSize.isAccessibilitySize {
            // Lista (texto grande): não há cena, só o dado muda.
            cardsVm.groups.merge(other.id, into: payer.id)
            Haptics.cardMerged()
        } else {
            // A cena anima o card entrando no outro e atualiza o grupo.
            cardsVm.mergeCards?(other.id, payer.id)
        }
        AccessibilityAnnouncer.announce(
            String(localized: "\(payer.name) vai pagar também o consumo de \(other.name)")
        )
    }

    /// `other` volta a pagar só o dele.
    private func split(_ other: User) {
        // Animado: o card da pessoa some do topo da sheet e os outros se
        // reorganizam.
        withAnimation(animationsOn ? .spring(response: 0.4, dampingFraction: 0.85) : nil) {
            if typeSize.isAccessibilitySize {
                cardsVm.groups.split(other.id)
            } else {
                cardsVm.splitCard?(other.id)
            }
        }
        AccessibilityAnnouncer.announce(
            String(localized: "\(other.name) vai pagar só o próprio consumo")
        )
    }

    // MARK: - Actions

    private func handleUserTap(userID: UUID) {
        selectedUser = billVm.bill.users.first {
            $0.id == userID
        }
    }

    /// Toque num card da cena: a cópia do card sai do lugar dele, cresce e
    /// fica em destaque acima da sheet; o resto da tela é esmaecido.
    private func handleCardTap(userID: UUID, avatarCenter: CGPoint) {
        guard
            spotlightUser == nil,
            !cardsVm.isPayingAll,
            let user = billVm.bill.users.first(where: { $0.id == userID })
        else {
            return
        }

        spotlightOrigin = avatarCenter
        isSpotlightLifted = false
        spotlightUser = user
        cardsVm.setCardHidden?(userID, true)
        selectedUser = user

        // Deixa a cópia aparecer primeiro no lugar do card, depois sobe.
        DispatchQueue.main.async {
            withAnimation(animationsOn ? .spring(response: 0.45, dampingFraction: 0.8) : nil) {
                isSpotlightLifted = true
            }
        }
    }

    /// Sheet fechou: o card volta para o lugar dele na cena.
    private func dropSpotlight() {
        guard let user = spotlightUser else { return }

        guard animationsOn else {
            isSpotlightLifted = false
            cardsVm.setCardHidden?(user.id, false)
            spotlightUser = nil
            return
        }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            isSpotlightLifted = false
        } completion: {
            cardsVm.setCardHidden?(user.id, false)
            spotlightUser = nil
        }
    }

    private func handleCompletion(_ isCompleted: Bool) {
        guard isCompleted else {
            return
        }

        path.append(Rota.card)
    }

    private func goBack() {
        guard !path.isEmpty else {
            return
        }

        path.removeLast()
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()

            if typeSize.isAccessibilitySize {
                // Texto grande: o círculo de tamanho fixo e os cards em
                // SpriteKit não crescem com o texto — vira uma lista.
                TotalLargeTextView(
                    // Quem está coberto aparece dentro do consumo de quem paga.
                    users: payers,
                    userTotals: groupTotals,
                    paidUserIDs: cardsVm.paidUserIDs,
                    onSelect: { handleUserTap(userID: $0.id) },
                    onMarkAsPaid: markAsPaid,
                    onPayAll: { showsPayAllAlert = true }
                )
            } else {
                VStack(spacing: 0) {
                    Spacer()

                    TotalCircle(
                        progress: progress,
                        formattedTotal: cardsVm.formattedTotal,
                        formattedTarget: cardsVm.formattedTarget,
                        totalAmount: cardsVm.totalAmount,
                        isCompleted: cardsVm.isCompleted,
                        isPayingAll: cardsVm.isPayingAll
                    )
                }
                .padding(.bottom, 20)

                if !cardsVm.isCompleted {
                    SpriteView(
                        scene: makeScene(),
                        options: [.allowsTransparency]
                    )
                    .ignoresSafeArea()
                    // O VoiceOver não enxerga os cards do SpriteKit nem consegue
                    // arrastá-los: para ele, cada pessoa que falta pagar vira um
                    // botão (abre o consumo) com a ação "Marcar como pago".
                    .accessibilityRepresentation {
                        accessibleUnpaidUsers
                    }
                    .id(sceneId)
                    .transition(.opacity)

                    // Fica acima da SpriteView para receber o toque.
                    VStack {
                        Spacer()

                        HStack {
                            payAllButton
                            Spacer(minLength: 0)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 5)
                    .transition(.scale.combined(with: .opacity))
                }
            }

            if let spotlightUser {
                spotlightLayer(for: spotlightUser)
            }
        }
        .coordinateSpace(name: "cardsSpace")
        .onPreferenceChange(HeaderBottomYKey.self) {
            headerBottomY = $0
        }
        .onChange(of: selectedUser) { _, newValue in
            if newValue == nil {
                dropSpotlight()
            }
        }
        .onChange(of: cardsVm.isCompleted) { _, isCompleted in
            handleCompletion(isCompleted)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: goBack) {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel("Voltar")
            }

            // "Total a pagar" na mesma altura do botão voltar
            ToolbarItem(placement: .principal) {
                header
                    // A barra de navegação tem altura fixa: igual aos
                    // títulos do sistema, o texto para de crescer aqui.
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            }
        }
        .onAppear {
            UINavigationController.disableSwipeBack()
        }
        .onDisappear {
            UINavigationController.enableSwipeBack()
        }
        .alert("Pagamento completo", isPresented: $showsPayAllAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Confirmar pagamento") { payAll() }
        } message: {
            Text("Você está prestes a concluir o pagamento de todos os selecionados. Deseja continuar?")
        }
        .sheet(item: $selectedUser) { user in
            UserConsumeSheet(
                user: user,
                coveredUsers: coveredUsers(of: user),
                coverCandidates: coverCandidates(for: user),
                onCover: { merge($0, into: user) },
                onSplit: { split($0) },
                onMarkAsPaid: { markAsPaid(user) },
                showsTitle: spotlightUser == nil
            )
            .adaptivePresentationDetents([.height(consumeSheetHeight)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(34)
            // Com o card em destaque, o esmaecido é nosso (branco, como no
            // protótipo) e não o cinza do sistema; tocar nele fecha a sheet.
            .presentationBackgroundInteraction(
                spotlightUser == nil
                    ? .disabled
                    : .enabled(upThrough: .height(consumeSheetHeight))
            )
            .presentationBackground(.regularMaterial)
        }
    }
    // MARK: - Card em destaque

    private func spotlightLayer(for user: User) -> some View {
        GeometryReader { geometry in
            let screen = geometry.size
            let bottomInset = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
                .keyWindow?.safeAreaInsets.bottom ?? 0
            let sheetTop = screen.height - consumeSheetHeight - bottomInset

            // Onde a bolinha (avatar) fica quando o card está em destaque:
            // card centralizado, logo acima da sheet.
            let liftedAvatar = CGPoint(
                x: screen.width / 2 - SpotlightCardView.avatarToCenter * spotlightScale,
                y: sheetTop - 95
            )
            let avatar = isSpotlightLifted ? liftedAvatar : spotlightOrigin
            let members = [user] + coveredUsers(of: user)

            ZStack {
                Color(UIColor.systemBackground)
                    .opacity(isSpotlightLifted ? 0.75 : 0)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedUser = nil
                    }
                    .accessibilityHidden(true)

                if members.count > 1 {
                    groupSpotlightCards(
                        members: members,
                        screen: screen,
                        sheetTop: sheetTop
                    )
                } else {
                SpotlightCardView(
                    user: user,
                    value: groupTotals[user.id] ?? userTotals[user.id] ?? 0,
                    covered: coveredUsers(of: user)
                )
                .scaleEffect(
                    isSpotlightLifted ? spotlightScale : 1,
                    anchor: SpotlightCardView.avatarAnchor
                )
                .shadow(
                    color: .black.opacity(isSpotlightLifted ? 0.12 : 0),
                    radius: 12, y: 6
                )
                .position(
                    x: avatar.x + SpotlightCardView.avatarToCenter,
                    y: avatar.y
                )
                .accessibilityHidden(true)
                }
            }
        }
        .ignoresSafeArea()
    }

    /// Cards juntados: cada pessoa do grupo aparece separada acima da
    /// sheet, com o total original dela, em zigue-zague. Saem de dentro do
    /// card do grupo (`spotlightOrigin`) e voltam para ele quando a sheet
    /// fecha.
    private func groupSpotlightCards(
        members: [User],
        screen: CGSize,
        sheetTop: CGFloat
    ) -> some View {
        let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow
        let safeTop = window?.safeAreaInsets.top ?? 0

        // Área livre entre o "Total a pagar" e a sheet.
        let top = safeTop + 64
        let bottom = sheetTop - 12
        let available = max(bottom - top, 70)

        let count = CGFloat(members.count)
        let isTwoColumns = members.count >= groupSpotlightTwoColumnsFrom
        let gap = groupSpotlightGap

        // Tamanho do card (SpotlightCardView): 156 x 70, bolinha a 35 da esquerda.
        let cardWidth: CGFloat = 156
        let cardHeight: CGFloat = 70

        let scale: CGFloat
        let step: CGFloat
        if isTwoColumns {
            // Cards da mesma coluna ficam a 2 passos de distância, então
            // o passo é meio card (+ meio espaço).
            let fitHeight = (available - gap / 2 * (count - 1))
                / (cardHeight + cardHeight / 2 * (count - 1))
            let fitWidth = (screen.width - 32 - gap) / (cardWidth * 2)
            scale = min(groupSpotlightMaxScale, fitHeight, fitWidth)
            step = (cardHeight * scale + gap) / 2
        } else {
            // 2 ou 3 pessoas: zigue-zague; com pouca altura os cards diminuem.
            let stackHeight = cardHeight + groupSpotlightStep * (count - 1)
            scale = min(1, available / stackHeight)
            step = groupSpotlightStep * scale
        }

        let stackHeight = cardHeight * scale + step * (count - 1)
        let firstY = top + (available - stackHeight) / 2 + cardHeight / 2 * scale

        /// Centro da bolinha de cada card quando está em destaque.
        func liftedPoint(_ index: Int) -> CGPoint {
            let y = firstY + step * CGFloat(index)

            guard isTwoColumns else {
                let column = groupSpotlightColumns[index % groupSpotlightColumns.count]
                return CGPoint(x: screen.width * column, y: y)
            }

            // Par de colunas centralizado na tela.
            let pairLeft = (screen.width - (cardWidth * 2 * scale + gap)) / 2
            let isLeft = index.isMultiple(of: 2)
            let cardLeft = isLeft ? pairLeft : pairLeft + cardWidth * scale + gap
            return CGPoint(x: cardLeft + 35 * scale, y: y)
        }

        return ForEach(members) { member in
            let index = members.firstIndex(where: { $0.id == member.id }) ?? 0
            let lifted = liftedPoint(index)
            let point = isSpotlightLifted ? lifted : spotlightOrigin

            SpotlightCardView(
                user: member,
                // Total original da pessoa (sem somar o grupo).
                value: userTotals[member.id] ?? 0
            )
            .scaleEffect(
                isSpotlightLifted ? scale : 0.4,
                anchor: SpotlightCardView.avatarAnchor
            )
            .opacity(isSpotlightLifted ? 1 : 0)
            .shadow(
                color: .black.opacity(isSpotlightLifted ? 0.08 : 0),
                radius: 8, y: 4
            )
            .position(
                x: point.x + SpotlightCardView.avatarToCenter,
                y: point.y
            )
            // O primeiro fica por cima, como no protótipo.
            .zIndex(Double(members.count - index))
            .transition(.scale(scale: 0.4).combined(with: .opacity))
            .accessibilityHidden(true)
        }
    }

    // MARK: - Pagar todos

    /// Mesma aparência do botão "mover todos" da SplitView.
    private var payAllButton: some View {
        Button {
            showsPayAllAlert = true
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(Color("grayblue84"), lineWidth: 2)

                Image(systemName: "circle.hexagongrid")
                    .font(.system(size: payAllIconSize, weight: .regular))
                    .foregroundStyle(Color("grayblue84"))
            }
            .frame(width: payAllButtonSize, height: payAllButtonSize)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(cardsVm.isPayingAll || unpaidUsers.isEmpty)
        .accessibilityLabel("Concluir pagamento de todos")
        .accessibilityHint("Marca como pago quem ainda falta pagar.")
    }

    /// Leva todos os cards para o círculo de "Pago". O último a chegar
    /// conclui a etapa (o onChange de isCompleted leva para o cartão).
    private func payAll() {
        if typeSize.isAccessibilitySize {
            // Texto grande: não há cena SpriteKit para levar os cards,
            // então cada pagamento é registrado direto.
            let pending = unpaidUsers
            pending.forEach(registerPaymentWithoutScene)
        } else {
            cardsVm.payAllUsers?(animationsOn)
        }
        AccessibilityAnnouncer.announce(String(localized: "Pagamento de todos concluído"))
    }

    // MARK: - Acessibilidade (VoiceOver)

    /// Marca a pessoa como paga sem arrasto: fecha a sheet (se estiver
    /// aberta), some com o card e o VoiceOver confirma em voz alta.
    private func markAsPaid(_ user: User) {
        let sheetWasOpen = selectedUser != nil
        selectedUser = nil

        // Espera a sheet fechar para o anúncio não ser cortado pela
        // mudança de foco do VoiceOver.
        DispatchQueue.main.asyncAfter(deadline: .now() + (sheetWasOpen ? 0.5 : 0)) {
            if typeSize.isAccessibilitySize {
                registerPaymentWithoutScene(user)
            } else {
                cardsVm.markUserAsPaid?(user.id)
            }
            AccessibilityAnnouncer.announce(String(localized: "\(user.name) pagou"))
        }
    }

    /// Versão em lista (texto grande): não há cena SpriteKit para somar o
    /// valor e sumir com o card, então o pagamento é registrado aqui.
    private func registerPaymentWithoutScene(_ user: User) {
        guard !cardsVm.paidUserIDs.contains(user.id) else { return }

        cardsVm.targetAmount = userTotals.values.reduce(0, +)
        // Paga o grupo inteiro (ela + quem ela cobre).
        cardsVm.totalAmount += groupTotals[user.id] ?? userTotals[user.id] ?? 0
        cardsVm.markGroupAsPaid(payerID: user.id)
        Haptics.cardPaid()

        // Último a pagar: conclui a etapa (o onChange leva para o cartão).
        if billVm.bill.users.allSatisfy({ cardsVm.paidUserIDs.contains($0.id) }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                Haptics.allPaid()
                cardsVm.isCompleted = true
            }
        }
    }

    /// Quem falta pagar e tem card próprio (quem está coberto paga junto
    /// com a pessoa que o cobre).
    private var unpaidUsers: [User] {
        payers.filter {
            !cardsVm.paidUserIDs.contains($0.id)
        }
    }

    private var accessibleUnpaidUsers: some View {
        VStack {
            ForEach(unpaidUsers) { user in
                Button {
                    handleUserTap(userID: user.id)
                } label: {
                    Text(user.accessibilityName)
                }
                .accessibilityValue(CurrencyHelper.accessibilityFormat(groupTotals[user.id] ?? 0))
                .accessibilityHint("Toque duas vezes para ver o consumo e marcar como pago.")
                // Atalho para quem já conhece as ações do VoiceOver
                // (deslizar para cima ou para baixo).
                .accessibilityAction(named: "Marcar como pago") {
                    markAsPaid(user)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Falta pagar")
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text("Total a pagar")
                .font(.app(.subheadline))

            Text(
                billVm.totalWithServiceFeeForBill,
                format: CurrencyHelper.formatStyle
            )
            .font(.app(.title3))
            .bold()
        }
        .foregroundColor(Color("textSecondary"))
        .transition(.move(edge: .top).combined(with: .opacity))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}


/// Versão SwiftUI do card da CardsScene (tamanho `.regular`): bolinha
/// com emoji + retângulo branco com nome e valor.
private struct SpotlightCardView: View {
    let user: User
    let value: Double
    /// Quem esse card cobre (cards juntados). Com alguém aqui, a bolinha
    /// vira o círculo branco do grupo, igual ao da cena.
    var covered: [User] = []

    private var members: [User] { [user] + covered }

    /// Quanto a cápsula anda para a direita quando o círculo cresce.
    private var capsuleShift: CGFloat {
        // Raio da bolinha normal (70 / 2) × quanto o círculo cresceu.
        35 * (GroupAvatarLayout.circleScale - 1)
    }
    private var isGroup: Bool { !covered.isEmpty }

    // Medidas iguais às de CardMetrics.regular.
    private static let size = CGSize(width: 156, height: 70)
    private static let avatarCenter = CGPoint(x: 35, y: 35)
    private static let backgroundCenter = CGPoint(x: 96, y: 38)
    private static let backgroundSize = CGSize(width: 120, height: 50)

    /// Distância horizontal entre a bolinha e o centro do card.
    static let avatarToCenter: CGFloat = size.width / 2 - avatarCenter.x

    /// Ponto da bolinha, usado como âncora do zoom.
    static let avatarAnchor = UnitPoint(
        x: avatarCenter.x / size.width,
        y: avatarCenter.y / size.height
    )

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(UIColor.systemBackground))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                }
                .frame(width: Self.backgroundSize.width, height: Self.backgroundSize.height)
                .overlay(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 1) {
                        // No grupo o retângulo mostra só o valor.
                        if !isGroup {
                            Text(user.name)
                                .font(.system(size: 12))
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                                .lineLimit(1)
                        }

                        Text(value, format: CurrencyHelper.formatStyle)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color(UIColor.darkGray))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .padding(.leading, 42)
                    .padding(.trailing, 6)
                }
                // No grupo o círculo é maior: a cápsula anda junto com a
                // borda dele (mesmo deslocamento da CardsScene).
                .position(
                    x: Self.backgroundCenter.x + (isGroup ? capsuleShift : 0),
                    y: Self.backgroundCenter.y
                )

            avatar
                .position(Self.avatarCenter)
        }
        .frame(width: Self.size.width, height: Self.size.height)
        // O tamanho segue o card da cena, que não cresce com o texto.
        .dynamicTypeSize(.large)
    }

    @ViewBuilder
    private var avatar: some View {
        let diameter: CGFloat = 70

        if isGroup {
            // Círculo do grupo maior que a bolinha normal.
            let radius = diameter * GroupAvatarLayout.circleScale / 2
            // Mesmo desenho da CardsScene (ver GroupAvatarLayout).
            let slots = GroupAvatarLayout.slots(for: members.count)
            let badgeRadius = GroupAvatarLayout.badgeRadius * radius

            ZStack {
                Circle()
                    .fill(Color(UIColor.systemBackground))
                    .shadow(
                        color: .black.opacity(GroupAvatarLayout.shadowOpacity),
                        radius: GroupAvatarLayout.shadowRadius,
                        x: GroupAvatarLayout.shadowOffset.width,
                        y: GroupAvatarLayout.shadowOffset.height
                    )

                ForEach(0..<min(members.count, slots.count), id: \.self) { index in
                    let member = members[index]
                    let slot = slots[index]
                    let size = slot.diameter * radius
                    Circle()
                        .fill(member.color)
                        .frame(width: size, height: size)
                        .overlay {
                            Text(member.emoji)
                                .font(.system(size: size * GroupAvatarLayout.emojiScale))
                        }
                        .offset(x: slot.center.x * radius, y: slot.center.y * radius)
                }

                Text(verbatim: "\(members.count)")
                    .font(Font(GroupAvatarLayout.badgeFont(size: badgeRadius * 1.25)))
                    .foregroundStyle(.white)
                    .frame(width: badgeRadius * 2, height: badgeRadius * 2)
                    .background(Color(uiColor: GroupAvatarLayout.badgeColor), in: Circle())
                    .offset(
                        x: GroupAvatarLayout.badgeCenter.x * radius,
                        y: GroupAvatarLayout.badgeCenter.y * radius
                    )
            }
            .frame(width: radius * 2, height: radius * 2)
        } else {
            Circle()
                .fill(user.color)
                .frame(width: diameter, height: diameter)
                .overlay {
                    Text(user.emoji)
                        .font(.system(size: 43))
                }
        }
    }
}

struct HeaderBottomYKey: PreferenceKey {
    static var defaultValue: CGFloat = 100

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


#if DEBUG
#Preview("Total - Dados Mockados") {
    @Previewable @State var billVm = makeTotalPreviewBill()

    NavigationStack {
        TotalView(path: .constant(NavigationPath()))
    }
    .environment(billVm)
}

/// Conta mockada para o preview da TotalView. Fica fora do `#Preview` e
/// sem `private`: símbolos privados usados pelo preview costumam causar
/// "Runtime linking failure" no Canvas.
///
/// Pessoas com itens atribuídos — sem isso todos devem R$ 0 e o anel
/// de progresso nunca anda no preview.
func makeTotalPreviewBill() -> BillViewModel {
    let billVm = BillViewModel()
    billVm.bill.users = [
        User(name: "Thais", emoji: "🌈", color: .yellow),
        User(name: "Motta", emoji: "🎈", color: .green),
        User(name: "Beatriz", emoji: "🌸", color: .blue),
        User(name: "Lucas", emoji: "😎", color: .orange),
        User(name: "Marina", emoji: "✨", color: .pink)
    ]

    let users = billVm.bill.users
    billVm.bill.items = [
        Product(name: "Cerveja", price: 16.50, quantity: 6,
                assignedUserIDs: Set(users.map(\.id))),
        Product(name: "Batata frita", price: 42.00, quantity: 1,
                assignedUserIDs: [users[0].id, users[1].id]),
        Product(name: "Pizza", price: 68.00, quantity: 1,
                assignedUserIDs: [users[2].id, users[3].id, users[4].id]),
        Product(name: "Refrigerante", price: 8.00, quantity: 2,
                assignedUserIDs: [users[4].id])
    ]

    return billVm
}
#endif
