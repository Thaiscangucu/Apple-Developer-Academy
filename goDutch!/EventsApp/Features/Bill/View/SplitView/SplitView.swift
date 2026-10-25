//
//  ContentView.swift
//  EventsApp
//

//TODO: remove only the middle circle

import SwiftUI
import SpriteKit

struct SplitView: View {
    
    @Binding var path: NavigationPath
    @Environment(BillViewModel.self) private var billViewModel
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion)
    private var accessibilityReduceMotion
    @AppStorage(AppSettings.animationsOn) private var animationsOn = true
    
    @State private var honeycombFrame: CGRect = .zero
    @State private var cardClusterFrame: CGRect = .zero
    
    @State private var viewModel = SplitViewModel()
    
    @State private var isUserFlying = false
    /// Usuários voando do honeycomb para o card (vários ao mesmo tempo).
    @State private var flyingToCardUserIDs: Set<User.ID> = []
    @State private var centeredUserIDByProduct: [Product.ID: User.ID] = [:]
    @State private var returningUserID: User.ID?
    @State private var returningAllUserIDs: Set<User.ID> = []
    /// Mostra a SplitLoadingView entre "Concluir" e a tela dos cartões.
    @State private var showsSplitLoading = false
    
    @State private var flightScene: UserFlightScene = {
        let scene = UserFlightScene()
        
        scene.scaleMode = .resizeFill
        scene.anchorPoint = .zero
        scene.backgroundColor = .clear
        
        return scene
    }()
    
    @State private var honeycombScene = UserPhysicsClusterScene()
    
    @State private var honeycombCenteredUserID: User.ID?
    @State private var cardPhysicsScenes = SplitCardPhysicsScenes()
    
    @Namespace private var circleAnimation
    
    //deixar responsivo
    private let honeycombDiameter: CGFloat = 270
    
    private let individualLayoutDuration: TimeInterval = 0.10
    private let userFlightDuration: TimeInterval = 0.15
    private let allUsersFlightDuration: TimeInterval = 0.25
    private let allUsersFlightTargetScale: CGFloat = 0.55
    private let allUsersReturnTargetScale: CGFloat = 1.15
    
    private let honeycombCenterCircleDiameter: CGFloat = 80 * 1.15
    
    private let expandedCardAnchor: UnitPoint = .bottom
    private let cardToHoneycombSpacing: CGFloat = 20
    
    var body: some View {
        
        @Bindable var screenViewModel = viewModel
        
        Group {
            if typeSize.isAccessibilitySize {
                // Texto grande: o honeycomb e os cards não crescem com o
                // texto, então a divisão vira uma lista de marcar pessoas.
                SplitLargeTextView {
                    screenViewModel.showsCompletionAlert = true
                }
            } else {
                GeometryReader { geometry in
            
                    let metrics = SplitLayoutMetrics(containerSize: geometry.size)
                    let responsiveHoneycombDiameter = metrics.scaled(honeycombDiameter)
                    let checkButtonSize = max(44, metrics.scaled(54))
                    let moveAllUsersIconSize = metrics.scaled(28)
                    let responsiveCardToHoneycombSpacing = metrics.scaled(cardToHoneycombSpacing)
            
                    ZStack(alignment: .bottom) {
                        ZStack(alignment: .bottom) {
                            ScrollViewReader { proxy in
                                ScrollView {
                                    VStack(spacing: metrics.scaled(12)) {
                                
                                        VStack(alignment: .leading, spacing: metrics.scaled(8)){
                                            Text("Hora de **dividir**")
                                            Text("os valores!")
                                        }
                                        .accessibilityElement(children: .combine)
                                        .accessibilityAddTraits(.isHeader)
                                        .frame(width: metrics.cardWidth, alignment: .leading)
                                        .frame(maxWidth: .infinity)
                                        .padding(.top, 22)
                                        .padding(.bottom, 15)
                                        .font(.app(.title))
                                
                                        let expandedIndex = billViewModel.bill.items.firstIndex {
                                            $0.id == viewModel.expandedProductID
                                        }
                                
                                        ForEach(Array(billViewModel.bill.items.enumerated()), id: \.element.id) { indexedProduct in
                                    
                                            let index = indexedProduct.offset
                                            let product = indexedProduct.element
                                            let shouldDim = expandedIndex.map { index > $0 } ?? false
                                    
                                            ItemCardView(
                                                product: product,
                                                productNumber: index + 1,
                                                users: billViewModel.bill.users,
                                                centeredUserID: centeredUserIDByProduct[product.id],
                                                returningUserID: returningUserID,
                                                returningAllUserIDs: returningAllUserIDs,
                                                isExpanded: viewModel.expandedProductID == product.id,
                                                physicsScene: cardPhysicsScenes.scene(for: product.id),
                                                animation: circleAnimation,
                                                onRemoveUser: { selection in
                                                    _ = beginUserReturnFlight(selection, from: product, layoutScale: metrics.scale, viewportSize: geometry.size)
                                                },
                                                onRemoveAllUsers: {
                                                    guard
                                                        !isUserFlying,
                                                        !flightScene.isFlying
                                                    else {
                                                        return
                                                    }
                                            
                                                    if !product.assignedUserIDs.isEmpty {
                                                        playRemoveHaptic()
                                                    }
                                            
                                                    let didStart = beginAllUsersReturnFlight(
                                                        from: product,
                                                        layoutScale: metrics.scale,
                                                        viewportSize: geometry.size
                                                    )
                                            
                                                    if !didStart {
                                                        animate(.spring(response: 0.45, dampingFraction: 0.75)) {
                                                            centeredUserIDByProduct.removeValue(forKey: product.id)
                                                            billViewModel.unassignAllUsers(fromProductID: product.id)
                                                        }
                                                    }
                                                },
                                                onTap: {
                                                    guard
                                                        !isUserFlying,
                                                        flyingToCardUserIDs.isEmpty,
                                                        !flightScene.isFlying
                                                    else {
                                                        return
                                                    }
                                                    animate(.smooth(duration: 0.3, extraBounce: 0)){
                                                        viewModel.toggleCard(product.id)
                                                    }
                                                }
                                            )
                                            .id(product.id)
                                            .opacity(shouldDim ? 0.34 : 1)
                                        }
                                
                                        if viewModel.expandedProductID != nil {
                                            Color.clear
                                                .frame(height: geometry.size.height)
                                                .allowsHitTesting(false)
                                        }
                                    }
                                    .padding(metrics.scaled(16))
                                }
                                .safeAreaInset(edge: .bottom, spacing: 0) {
                                    if viewModel.expandedProductID != nil {
                                        Color.clear
                                            .frame(height: responsiveHoneycombDiameter + responsiveCardToHoneycombSpacing)
                                            .allowsHitTesting(false)
                                    }
                                }
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .scrollDisabled(isUserFlying || !flyingToCardUserIDs.isEmpty)
                                .onChange(of: viewModel.expandedProductID) { _, newValue in
                                    honeycombCenteredUserID = nil
                                    honeycombScene.cancelInteractions()
                                    honeycombScene.resetCamera()
                                    
                                    guard let newValue else {
                                        return
                                    }
                                    DispatchQueue.main.asyncAfter (deadline: .now() + 0.35) {
                                        guard viewModel.expandedProductID == newValue else {
                                            return
                                        }
                                
                                        animate(.smooth(duration: 0.4, extraBounce: 0)) {
                                            proxy.scrollTo(newValue, anchor: expandedCardAnchor)
                                        }
                                    }
                                }
                            }
                    
                            if let expandedProduct {
                                SplitPhysicsClusterView(
                                    users: billViewModel.bill.users.filter {
                                        !expandedProduct.assignedUserIDs.contains($0.id)
                                    },
                                    centeredUserID: honeycombCenteredUserID,
                                    hiddenUserIDs: flyingToCardUserIDs,
                                    mode: .honeycomb,
                                    circleRadius: metrics.scaled(40),
                                    scene: honeycombScene,
                                    onTapSelect: { selection in
                                        beginUserFlight(selection, to: expandedProduct, layoutScale: metrics.scale, viewportSize: geometry.size)
                                    },
                                    onLongPressUsers: { userIDs in
                                        guard
                                            !isUserFlying,
                                            !flightScene.isFlying
                                        else {
                                            return
                                        }
                                
                                        let userIDSet = Set(userIDs)
                                
                                        let usersToMove = billViewModel.bill.users.filter { user in
                                            userIDSet.contains(user.id) && !expandedProduct.assignedUserIDs.contains(user.id)
                                        }
                                
                                        let didStart = beginAllUsersFlight(
                                            users: usersToMove,
                                            to: expandedProduct,
                                            viewportSize: geometry.size
                                        )
                                
                                        if !didStart {
                                            if !usersToMove.isEmpty { playAssignHaptic() }
                                            animate(.spring(response: 0.45, dampingFraction: 0.75)) {
                                                for user in usersToMove {
                                                    billViewModel.assignUser(user.id, toProductID: expandedProduct.id)
                                                }
                                            }
                                            synchronizePhysics(for: expandedProduct.id)
                                        }
                                    }
                                ) {
                                    LiquidGlassCircle()
                                }
                                .frame(width: responsiveHoneycombDiameter, height: responsiveHoneycombDiameter)
                                .background {
                                    GeometryReader { proxy in
                                        Color.clear.preference(key: HoneycombFramePreferenceKey.self, value: proxy.frame(in: .named(SplitFlightCoordinateSpace.name)))
                                    }
                                }
                                .transition(animationsOn ? AnyTransition.move(edge: .bottom).combined(with: .opacity) : AnyTransition.identity)
                                .zIndex(1)
                            }
                        }
                
                        HStack {
                    
                            if expandedProduct != nil {
                                moveAllUsersButton(buttonSize: checkButtonSize, iconSize: moveAllUsersIconSize, layoutScale: metrics.scale, viewportSize: geometry.size)
                                    .transition(animationsOn ? AnyTransition.scale.combined(with: .opacity) : AnyTransition.identity)
                            }
                    
                            Spacer(minLength: 0)
                    
                            Button{
                                handleCheckButton()
                            }
                            label:{
                                ZStack {
                                    Circle()
                                        .fill(Color("grayblue84"))
                                        .frame(width: checkButtonSize, height: checkButtonSize)
                            
                                    Image(systemName: "checkmark")
                                        .font(.system(size: metrics.scaled(25), weight: .medium))
                                        .foregroundStyle(.white)
                                }
                                .frame(width: checkButtonSize, height: checkButtonSize)
                                .contentShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(isLastDivisionStep ? Text("Concluir divisão") : Text("Próximo item"))
                        }
                        .padding(.horizontal, metrics.scaled(24))
                        .padding(.bottom, metrics.scaled(5))
                        .zIndex(2)
                
                        if isUserFlying {
                            Color.clear
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                                .zIndex(9)
                        }
                
                        TransparentSpriteView(scene: flightScene)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                            .zIndex(10)
                
                    }
                    .environment(\.splitLayoutScale, metrics.scale)
                    .environment(\.splitCardWidth, metrics.cardWidth)
                    .coordinateSpace(name: SplitFlightCoordinateSpace.name)
                    .onPreferenceChange(HoneycombFramePreferenceKey.self) {
                        honeycombFrame = $0
                    }
                    .onPreferenceChange(CardClusterFramePreferenceKey.self) {
                        cardClusterFrame = $0
                    }
                }
            }
        }
        // Ocupa a tela toda para o overlay de carregamento encostar nas bordas.
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // MARK: - Carregamento da divisão
        .overlay {
            if showsSplitLoading {
                SplitLoadingView {
                    // Navega com o carregamento ainda na tela; ele só some
                    // no onDisappear, quando a próxima tela já cobriu esta.
                    path.append(Rota.total)
                }
                .ignoresSafeArea()
                .accessibilityElement(children: .ignore)
                .accessibilityAddTraits(.isModal)
                .accessibilityLabel("Dividindo a conta")
                .onAppear { AccessibilityAnnouncer.screenChanged() }
                .transition(.opacity)
            }
        }
        // A barra de navegação (botão voltar) fica acima de qualquer conteúdo,
        // então some enquanto carrega.
        .toolbar(showsSplitLoading ? .hidden : .visible, for: .navigationBar)
        .animation(.easeInOut(duration: 0.25), value: showsSplitLoading)
        .alert("Concluir divisão?", isPresented: $screenViewModel.showsCompletionAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Concluir") { handleCompletionConfirmation() }
        } message: {
            Text("Deseja concluir a divisão de valores?")
        }
        .alert("Divisão Incompleta!", isPresented: $screenViewModel.showMissingAssigmentAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("É necessário selecionar pelo menos uma pessoa para cada item antes de concluir a divisão.")
        }
        .navigationDestination(isPresented: $screenViewModel.showsCompletedScreen) {
            DivisionCompletedView()
        }
        // Bloqueia a ação de voltar a tela arrastando com o dedo
        .navigationBarBackButtonHidden(true)
        
        // MARK: - Botão de voltar
        
        .toolbar {
            
            ToolbarItem(placement: .topBarLeading) {
                
                Button {
                    
                    if !path.isEmpty {
                        path.removeLast()
                    }
                    
                } label: {
                    
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel("Voltar")
            }
        }
        .onAppear {
            UINavigationController.disableSwipeBack()
            
            guard viewModel.expandedProductID == nil, let firstProductID = billViewModel.bill.items.first?.id else {
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                guard viewModel.expandedProductID == nil else {
                    return
                }
                
                animate(.smooth(duration: 0.5, extraBounce: 0)) {
                    viewModel.expandedProductID = firstProductID
                }
            }
        }
        .onDisappear {
            UINavigationController.enableSwipeBack()
            // A tela dos cartões já cobriu esta: pode tirar o carregamento.
            showsSplitLoading = false
        }
    }
    
    /// Mesmo haptic de quando um participante entra na bolha na AddUsersView
    /// (impacto médio). Respeita "Animações & haptics" dos Ajustes.
    private func playAssignHaptic() {
        guard animationsOn else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    /// Mesmo haptic de quando um participante é removido da bolha na
    /// AddUsersView (impacto seco, no momento do toque).
    /// Respeita "Animações & haptics" dos Ajustes.
    private func playRemoveHaptic() {
        guard animationsOn else { return }
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 1.0)
    }

    /// Executa `body` com animação apenas se `animationsOn` estiver ativo;
    /// caso contrário, aplica a mudança de estado imediatamente.
    @discardableResult
    private func animate<Result>(_ animation: Animation?, _ body: () throws -> Result) rethrows -> Result {
        if animationsOn {
            return try withAnimation(animation, body)
        } else {
            return try body()
        }
    }
    
    private var expandedProduct: Product? {
        guard let expandedProductID = viewModel.expandedProductID else {
            return nil
        }
        
        return billViewModel.bill.items.first {
            $0.id == expandedProductID
        }
    }
    
    /// Se o botão de check vai concluir a divisão (último item ou nenhum
    /// aberto) em vez de só avançar para o próximo item.
    private var isLastDivisionStep: Bool {
        guard let expandedProduct else {
            return true
        }

        return billViewModel.bill.items.last?.id == expandedProduct.id
    }
    
    private var shoulMoveAllUsersToCard: Bool {
        guard let expandedProduct else {
            return false
        }
        
        let usersInCardCount = billViewModel.bill.users.filter {
            expandedProduct.assignedUserIDs.contains($0.id)
        }.count
        
        let usersInHoneycombCount = billViewModel.bill.users.count - usersInCardCount
        
        return usersInHoneycombCount >= usersInCardCount
    }
    
    private var moveAllUsersSymbolName: String {
        shoulMoveAllUsersToCard ? "circle.hexagongrid.fill" : "circle.hexagongrid"
    }
    
    private func moveAllUsersButton(buttonSize: CGFloat, iconSize: CGFloat, layoutScale: CGFloat, viewportSize: CGSize) -> some View {
        Button {
            handleMoveAllUsersButton(layoutScale: layoutScale, viewportSize: viewportSize)
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(Color("grayblue84"), lineWidth: 2)
                
                Image(systemName: moveAllUsersSymbolName)
                    .font(.system(size: iconSize, weight: .regular))
                    .foregroundStyle(Color("grayblue84"))
            }
            .frame(width: buttonSize, height: buttonSize)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(shoulMoveAllUsersToCard ? Text("Adicionar todas as pessoas ao item") : Text("Remover todas as pessoas do item"))
    }
    
    private func handleMoveAllUsersButton(layoutScale: CGFloat, viewportSize: CGSize) {
        guard
            !isUserFlying,
            !flightScene.isFlying,
            let expandedProduct
        else {
            return
        }
        
        let usersInHoneycomb = billViewModel.bill.users.filter {
            !expandedProduct.assignedUserIDs.contains($0.id)
        }
        
        let usersInCard = billViewModel.bill.users.filter {
            expandedProduct.assignedUserIDs.contains($0.id)
        }
        
        let shouldMoveToCard = usersInHoneycomb.count >= usersInCard.count
        
        if shouldMoveToCard {
            let didStart = beginAllUsersFlight(users: usersInHoneycomb, to: expandedProduct, viewportSize: viewportSize)
            
            if !didStart {
                if !usersInHoneycomb.isEmpty { playAssignHaptic() }
                animate(.easeInOut(duration: 0.25)) {
                    for user in usersInHoneycomb {
                        billViewModel.assignUser(user.id, toProductID: expandedProduct.id)
                    }
                }
                synchronizePhysics(for: expandedProduct.id)
            }
            return
        }
        
        // Haptic no momento do toque, igual à remoção na AddUsersView.
        if !usersInCard.isEmpty { playRemoveHaptic() }
        
        let didStart = beginAllUsersReturnFlight(from: expandedProduct, layoutScale: layoutScale, viewportSize: viewportSize)
        
        if !didStart {
            animate(.easeInOut(duration: 0.25)) {
                centeredUserIDByProduct.removeValue(forKey: expandedProduct.id)
                billViewModel.unassignAllUsers(fromProductID: expandedProduct.id)
            }
            synchronizePhysics(for: expandedProduct.id)
        }
    }
    
    private func handleCheckButton() {
        guard
            !isUserFlying,
            flyingToCardUserIDs.isEmpty,
            !flightScene.isFlying
        else {
            return
        }
        
        animate(.smooth(duration: 0.3, extraBounce: 0)) {
            viewModel.advanceOrRequestCompletion(in: billViewModel.bill.items)
        }
    }
    
    private func handleCompletionConfirmation() {
        let products = billViewModel.bill.items
        
        if viewModel.canCompleteDivision(with: products) {
            // A navegação acontece quando a SplitLoadingView termina (onFinished).
            showsSplitLoading = true
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                viewModel.showMissingAssigmentAlert = true
            }
        }
    }
    
    @discardableResult
    private func beginUserFlight(_ selection: PhysicsUserSelection, to product: Product, layoutScale: CGFloat, viewportSize: CGSize) -> Bool {
        guard
            !isUserFlying,
            !flyingToCardUserIDs.contains(selection.userID),
            let user = billViewModel.bill.users.first(where: {
                $0.id == selection.userID
            }),
            !product.assignedUserIDs.contains(user.id)
        else {
            return false
        }
        
        // Sem animações: move o usuário direto, sem o voo.
        if !animationsOn {
            centeredUserIDByProduct[product.id] = user.id
            billViewModel.assignUser(user.id, toProductID: product.id)
            synchronizePhysics(for: product.id)
            return true
        }
        
        let startPoint: CGPoint
        
        if honeycombFrame.isEmpty {
            startPoint = CGPoint(x: viewportSize.width / 2, y: viewportSize.height - 150)
        } else {
            startPoint = CGPoint(x: honeycombFrame.minX + selection.centerInView.x, y: honeycombFrame.minY + selection.centerInView.y)
        }
        
        let endPoint = cardClusterFrame.isEmpty
            ? CGPoint(x: viewportSize.width / 2, y: viewportSize.height * 0.30)
            : CGPoint(x: cardClusterFrame.midX, y: cardClusterFrame.midY)
        
        flyingToCardUserIDs.insert(user.id)
        
        let didStart = flightScene.fly(
            user: user,
            from: startPoint,
            to: endPoint,
            viewportSize: viewportSize,
            sourceDiameter: max(selection.diameter, 1),
            targetDiameter: ClusterLayout.circleSize * layoutScale,
            duration: userFlightDuration,
            allowsConcurrentFlights: true,
            onArrival: {
                playAssignHaptic()
                animate(.smooth(duration: individualLayoutDuration, extraBounce: 0)) {
                    centeredUserIDByProduct[product.id] = user.id
                    billViewModel.assignUser(user.id, toProductID: product.id)
                }
                synchronizePhysics(for: product.id)
            },
            onFinished: {
                flyingToCardUserIDs.remove(user.id)
            })
        
        guard didStart else {
            flyingToCardUserIDs.remove(user.id)
            return false
        }
        return true
    }
    
    @discardableResult
    private func beginAllUsersFlight(users: [User], to product: Product, viewportSize: CGSize) -> Bool {
        guard
            animationsOn,
            !isUserFlying,
            !flightScene.isFlying,
            !users.isEmpty,
            !honeycombFrame.isEmpty
        else {
            return false
        }
        
        let userIDs = Set(users.map(\.id))
        let selections = honeycombScene.flightSelections(for: userIDs)
        
        let usersByID = Dictionary(uniqueKeysWithValues: users.map {
            ($0.id, $0)
        })
        
        let flightItems = selections.compactMap {
            selection -> UserGroupFlightItem? in
            
            guard let user = usersByID[selection.userID] else {
                return nil
            }
            
            return UserGroupFlightItem(
                user: user,
                centerInView: CGPoint(x: honeycombFrame.minX + selection.centerInView.x, y: honeycombFrame.minY + selection.centerInView.y),
                diameter: max(selection.diameter, 1)
            )
        }
        
        guard !flightItems.isEmpty else {
            return false
        }
        
        let endPoint: CGPoint
        
        if cardClusterFrame.isEmpty {
            endPoint = CGPoint(x: viewportSize.width / 2, y: viewportSize.height * 0.30)
        } else {
            endPoint = CGPoint(x: cardClusterFrame.midX, y: cardClusterFrame.midY)
        }
        
        let animatedUserIDs = Set(flightItems.map { $0.user.id })
        
        isUserFlying = true
        
        let didStart = flightScene.flyGroup(
            items: flightItems,
            to: endPoint,
            viewportSize: viewportSize,
            targetScale: allUsersFlightTargetScale,
            duration: allUsersFlightDuration,
            onArrival: {
                honeycombScene.removeCirclesImmediately(for: animatedUserIDs)
                playAssignHaptic()
                animate(.spring(response: 0.45, dampingFraction: 0.75)) {
                    centeredUserIDByProduct.removeValue(forKey: product.id)
                    
                    for user in users {
                        billViewModel.assignUser(user.id, toProductID: product.id)
                    }
                }
                
                synchronizePhysics(for: product.id)
            },
            onFinished: {
                flyingToCardUserIDs.subtract(animatedUserIDs)
                isUserFlying = false
            }
        )
        
        guard didStart else {
            isUserFlying = false
            return false
        }
        
        flyingToCardUserIDs.formUnion(animatedUserIDs)
        
        honeycombScene.setCirclesHidden(true, for: animatedUserIDs)
        
        return true
    }
    
    private func displayedUsersForFlight(in product: Product) -> [User] {
        Array(
            billViewModel.bill.users.filter {
                product.assignedUserIDs.contains($0.id)
            }
            .prefix(CirclePatternLayout.maximumCount)
        )
    }
    
    @discardableResult
    private func beginAllUsersReturnFlight(from product: Product, layoutScale: CGFloat, viewportSize: CGSize) -> Bool {
        guard
            animationsOn,
            !isUserFlying,
            !flightScene.isFlying,
            !cardClusterFrame.isEmpty
        else {
            return false
        }
        
        let displayedUsers = displayedUsersForFlight(in: product)
        
        guard !displayedUsers.isEmpty else {
            return false
        }
        
        let sourceScene = cardPhysicsScenes.scene(for: product.id)
        
        let flightItems = displayedUsers.compactMap {
            user -> UserGroupFlightItem? in
            
            guard let selection = sourceScene.selection(for: user.id) else {
                return nil
            }
            
            return UserGroupFlightItem(
                user: user,
                centerInView: CGPoint(x: cardClusterFrame.minX + selection.centerInView.x, y: cardClusterFrame.minY + selection.centerInView.y),
                diameter: max(selection.diameter, 1)
            )
        }
        
        guard flightItems.count == displayedUsers.count else {
            return false
        }
        
        let endPoint: CGPoint
        
        if honeycombFrame.isEmpty {
            endPoint = CGPoint(x: viewportSize.width / 2, y: viewportSize.height * 0.75)
        } else {
            endPoint = CGPoint(x: honeycombFrame.midX, y: honeycombFrame.midY)
        }
        
        let animatedUserIDs = Set(displayedUsers.map(\.id))
        
        returningAllUserIDs = animatedUserIDs
        isUserFlying = true
        
        let didStart = flightScene.flyGroup(
            items: flightItems,
            to: endPoint,
            viewportSize: viewportSize,
            targetScale: allUsersFlightTargetScale,
            duration: allUsersFlightDuration,
            onArrival: {
                animate(.easeInOut(duration: 0.25)) {
                    honeycombCenteredUserID = displayedUsers.first?.id
                    centeredUserIDByProduct.removeValue(forKey: product.id)
                    billViewModel.unassignAllUsers(fromProductID: product.id)
                }
                
                synchronizePhysics(for: product.id)
                honeycombScene.resetCamera()
            },
            onFinished: {
                returningAllUserIDs = []
                isUserFlying = false
            }
        )
        
        guard didStart else {
            returningAllUserIDs = []
            isUserFlying = false
            return false
        }
        
        sourceScene.setCirclesHidden(true, for: animatedUserIDs)
        return true
    }
    
    @discardableResult
    private func beginUserReturnFlight(_ selection: CardUserSelection, from product: Product, layoutScale: CGFloat, viewportSize: CGSize) -> Bool {
        guard !isUserFlying, !flightScene.isFlying else {
            return false
        }
        
        guard selection.totalCount > 0 else {
            return false
        }
        
        guard let user = billViewModel.bill.users.first(where: {
            $0.id == selection.userID
        }) else {
            return false
        }
        
        guard product.assignedUserIDs.contains(user.id) else {
            return false
        }
        
        // Haptic no momento do toque, igual à remoção na AddUsersView.
        playRemoveHaptic()
        
        // Sem animações: devolve o usuário direto, sem o voo.
        if !animationsOn {
            honeycombCenteredUserID = user.id
            if centeredUserIDByProduct[product.id] == user.id {
                centeredUserIDByProduct.removeValue(forKey: product.id)
            }
            billViewModel.unassignUser(user.id, fromProductID: product.id)
            synchronizePhysics(for: product.id)
            return true
        }
        
        let sourceScene = cardPhysicsScenes.scene(for: product.id)
        
        guard let sourceSelection = sourceScene.selection(for: user.id) else {
            return false
        }
        
        let startPoint = cardClusterFrame.isEmpty
            ? CGPoint(x: viewportSize.width / 2, y: viewportSize.height * 0.30)
            : CGPoint(x: cardClusterFrame.minX + sourceSelection.centerInView.x, y: cardClusterFrame.minY + sourceSelection.centerInView.y)
        
        let endPoint: CGPoint
        
        if honeycombFrame.isEmpty {
            endPoint = CGPoint(x: viewportSize.width / 2, y: viewportSize.height - 150)
        } else {
            endPoint = CGPoint(x: honeycombFrame.midX, y: honeycombFrame.midY)
        }
        
        returningUserID = user.id
        isUserFlying = true
        
        let didStart = flightScene.fly(
            user: user,
            from: startPoint,
            to: endPoint,
            viewportSize: viewportSize,
            sourceDiameter: max(sourceSelection.diameter, 1),
            targetDiameter: honeycombCenterCircleDiameter * layoutScale,
            duration: userFlightDuration,
            onArrival: {
                animate(.smooth(duration: individualLayoutDuration, extraBounce: 0)) {
                    honeycombCenteredUserID = user.id
                    
                    if centeredUserIDByProduct[product.id] == user.id {
                        centeredUserIDByProduct.removeValue(forKey: product.id)
                    }
                    
                    billViewModel.unassignUser(user.id, fromProductID: product.id)
                }
                
                synchronizePhysics(for: product.id)
                honeycombScene.resetCamera()
            },
            onFinished: {
                returningUserID = nil
                isUserFlying = false
            })
        guard didStart else {
            returningUserID = nil
            isUserFlying = false
            return false
        }
        
        sourceScene.setCirclesHidden(true, for: [user.id])
        return true
    }
    
    private func synchronizePhysics(for productID: Product.ID) {
        guard let product = billViewModel.bill.items.first(where: { $0.id == productID }) else {
            return
        }
        
        var hiddenCardIDs = returningAllUserIDs
        
        if let returningUserID {
            hiddenCardIDs.insert(returningUserID)
        }
        
        cardPhysicsScenes.scene(for: productID).apply(
            users: displayedUsersForFlight(in: product),
            centeredUserID: centeredUserIDByProduct[productID],
            hiddenUserIDs: hiddenCardIDs
        )
        
        guard viewModel.expandedProductID == productID else {
            return
        }
        
        honeycombScene.apply(
            users: billViewModel.bill.users.filter {
                !product.assignedUserIDs.contains($0.id)
            },
            centeredUserID: honeycombCenteredUserID,
            hiddenUserIDs: flyingToCardUserIDs
        )
    }
}

@MainActor
private final class SplitCardPhysicsScenes {
    private var scenes: [Product.ID: UserPhysicsClusterScene] = [:]
    
    func scene(for productID: Product.ID) -> UserPhysicsClusterScene {
        if let scene = scenes[productID] {
            return scene
        }
        
        let scene = UserPhysicsClusterScene()
        
        scene.scaleMode = .resizeFill
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.backgroundColor = .clear
        scene.mode = .maxCard
        scene.usesRectangularBoundary = true
        
        scenes[productID] = scene
        return scene
    }
}

