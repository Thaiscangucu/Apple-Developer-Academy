import SwiftUI


/// Tela responsável por cadastrar e exibir os participantes da conta
/// antes de iniciar o processo de escaneamento e divisão.
struct AddUsersView: View {
    
    // MARK: - ViewModels
    @Environment(BillViewModel.self) private var vm
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.scenePhase) private var scenePhase
    @State private var scanVm = ScanViewModel()
    @State private var addUserVm = AddUserViewModel()
    /// Preferência global de animações & haptics.
    @AppStorage(AppSettings.animationsOn) private var animationsOn = true
    
    @Binding var path: NavigationPath
    //    private let honeycombDiameter: CGFloat = 346
    
    private let persistedUserFlightDuration: TimeInterval = 0.15
    private let honeycombCenterCircleDiameter: CGFloat = 80 * 1.15
    
    // MARK: - Elevação quando a sheet sobe
    /// Frame da bolha na tela (medido em repouso, sem deslocamento).
    @State private var bubbleFrame: CGRect = .zero
    @State private var addUserButtonFrame: CGRect = .zero
    /// Quanto a tela sobe enquanto o formulário está aberto.
    @State private var sheetLift: CGFloat = 0
    /// Escala da bolha para caber no espaço visível acima da sheet.
    @State private var bubbleScale: CGFloat = 1
    
    @State private var persistedUserFlightOverlay = UserFlightWindowOverlay()
    @State private var flyingPersistedUserID: User.ID?
    
    // MARK: - Física da bolha
    /// Mesma cena de física do honeycomb da SplitView.
    @State private var bubbleScene = UserPhysicsClusterScene()
    /// Quem fica no centro da bolha (o último participante que entrou).
    @State private var bubbleCenteredUserID: User.ID?
    /// Participantes saindo da bolha (voando até o botão de adicionar).
    @State private var removingUserIDs: Set<User.ID> = []
    
    var body: some View {
        ZStack{
            VStack {
                // MARK: - Cabeçalho
                header
                // Some enquanto a sheet está aberta, dando espaço à bolha.
                    .opacity(sheetLift > 0 ? 0 : 1)
                // Some rápido, antes da bolha passar por cima dele.
                    .animation(animationsOn ? .easeOut(duration: 0.15) : nil, value: sheetLift > 0)
                //                    .padding(.top, 56)
                    .padding(.bottom, 28)
                
                // MARK: - Bolha
                SplitPhysicsClusterView(
                    users: vm.bill.users,
                    centeredUserID: bubbleCenteredUserID,
                    hiddenUserIDs: removingUserIDs,
                    mode: .honeycomb,
                    circleRadius: 40,
                    scene: bubbleScene,
                    // Tocar: excluir da conta.
                    onTapSelect: { selection in
                        beginUserRemovalFlight(selection)
                    },
                    // Segurar: editar o participante.
                    onLongPressUser: { userID in
                        addUserVm.startEditingBillUser(id: userID, in: vm)
                    },
                    voiceOverRole: .billParticipants
                ){
                    Image("Bubble")
                        .resizable()
                        .scaledToFit()
                }
                .containerRelativeFrame(.horizontal) { width, _ in
                    width * 0.9
                }
                // Quem acabou de entrar vai para o centro da bolha.
                .onChange(of: vm.bill.users.map(\.id)) { oldIDs, newIDs in
                    if let addedID = newIDs.last(where: { !oldIDs.contains($0) }) {
                        bubbleCenteredUserID = addedID
                        bubbleScene.resetCamera()
                    } else if let centered = bubbleCenteredUserID, !newIDs.contains(centered) {
                        bubbleCenteredUserID = nil
                    }
                    removingUserIDs.formIntersection(newIDs)
                }
                // Mede a bolha só em repouso (sem lift) para calcular o deslocamento.
                .onGeometryChange(for: CGRect.self) { proxy in
                    proxy.frame(in: .global)
                } action: { frame in
                    if !addUserVm.showForm && sheetLift == 0 { bubbleFrame = frame }
                }
                .scaleEffect(bubbleScale)
                .animation(liftAnimation, value: bubbleScale)
                
                // MARK: - Botões
                ZStack {
                    // Histórico
                    Button{
                        path.append(Rota.history)
                    }
                    label: {
                        CircleButton(text: "", symbol: "list.bullet.clipboard", CircleSize: 65, SymbolFont: 30)
                    }
                    .padding(.trailing, 250)
                    .accessibilityLabel("Histórico de contas")
                    .accessibilityHint("Mostra as contas já fechadas.")
                    
                    // Adicionar Participante
                    Button {
                        addUserVm.openForm()
                    }
                    label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 36, style: .continuous)
                                .fill(.accentSlateLight)
                                .cornerRadius(70)
                                .shadow(color: Color("shadowSoft").opacity(0.25), radius: 2, x: 0, y: -1)
                                .shadow(color: Color("shadowSoft").opacity(0.25), radius: 2, x: 0, y: 3)
                                .frame(width: 138, height: 138)
                                .adaptiveGlass(clear: true, in: .circle)
                                .largeTextStroke(diameter: 138)
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                                .fontWeight(.semibold)
                                .tint(.accentSlate)
                        }
                    }
                    
                    .accessibilityLabel("Adicionar participante")
                    .accessibilityHint("Abre o formulário para incluir uma pessoa na conta.")
                    .onGeometryChange(for: CGRect.self) { proxy in
                        proxy.frame(in: .global)
                    } action: { frame in
                        addUserButtonFrame = frame
                    }
                    // Escanear
                    Button {
                        addUserVm.continueToScan(billViewModel: vm, scanViewModel: scanVm)
                    }
                    label: {
                        CircleButton(text: "", symbol: "checkmark", CircleSize: 65, SymbolFont: 30)
                    }
                    .padding(.leading, 250)
                    .accessibilityLabel("Continuar")
                    .accessibilityHint("Abre a câmera para escanear a nota.")
                    
                }
                .padding(.top, 57)
                
            }
            // Sobe a tela inteira para a bolha ficar visível acima da sheet.
            .offset(y: -sheetLift)
            // Animação só nesta camada (antes era withAnimation, que vazava
            // para a apresentação da sheet e atrapalhava o TextField).
            .animation(liftAnimation, value: sheetLift)
            // Texto grande (acessibilidade): título + bolha + botões não
            // cabem na tela, então a tela passa a rolar.
            .scrollsAtAccessibilitySizes(showsIndicators: false)
            
            .toolbar{
                ToolbarItem{
                    Button{
                        addUserVm.toggleSettings()
                    }label:{
                        Image(systemName: "gear")
                            .foregroundStyle(.accentSlate)
                    }
                    .accessibilityLabel("Ajustes")
                    .accessibilityValue(addUserVm.settingsView ? Text("Aberto") : Text("Fechado"))
                }
            }
        }
        // O teclado do formulário não deve redimensionar a tela de fundo.
        .ignoresSafeArea(.keyboard)
        .onDisappear {
            persistedUserFlightOverlay.detach()
            // A comanda já cobriu esta tela: pode tirar o carregamento sem
            // a AddUsersView aparecer de novo no meio do caminho.
            scanVm.finishProcessing()
        }
        // MARK: - Settings
        // Fica num overlay (e não dentro do ZStack) para não mudar o tamanho
        // do layout de fundo quando aparece — era isso que causava o glitch.
        .overlay {
            if addUserVm.settingsView {
                ZStack {
                    // Camada invisível: tocar fora da SettingsView fecha.
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            addUserVm.closeSettings()
                        }
                        .accessibilityHidden(true)
                    
                    SettingsView(
                        notifications: $addUserVm.notificationsOn,
                        animation: $animationsOn
                    )
                }
                // VoiceOver: fica "preso" nos ajustes enquanto estão abertos
                // e o gesto de esfregar (dois dedos em Z) fecha o painel.
                .accessibilityAddTraits(.isModal)
                .accessibilityAction(.escape) {
                    addUserVm.closeSettings()
                }
            }
        }
        
        .containerRelativeFrame(.horizontal) { width, _ in
            width * 0.9
        }
        // Ocupa a tela toda (o conteúdo continua centralizado), para o
        // overlay de carregamento encostar nas bordas e poder ignorar as safe areas.
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // MARK: - Carregamento
        .overlay {
            if scanVm.isProcessing {
                ScanLoadingView(progress: scanVm.progress)
                    .ignoresSafeArea()
                    .accessibilityElement(children: .ignore)
                    .accessibilityAddTraits(.isModal)
                    .accessibilityLabel("Lendo a nota")
                // Quanto da leitura já foi feito (ex.: "45%").
                    .accessibilityValue(Text(scanVm.progress, format: .percent.precision(.fractionLength(0))))
                    .accessibilityAddTraits(.updatesFrequently)
                    .onAppear { AccessibilityAnnouncer.screenChanged() }
                    .transition(.opacity)
            }
        }
        // A barra de navegação (botão de ajustes / voltar) é desenhada pelo
        // sistema acima de qualquer conteúdo, então some enquanto carrega.
        .toolbar(scanVm.isProcessing ? .hidden : .visible, for: .navigationBar)
        .animation(.easeInOut(duration: 0.25), value: scanVm.isProcessing)
        // MARK: - Notificações
        .task {
            await addUserVm.syncNotificationPermission()
        }
        .onChange(of: addUserVm.notificationsOn) { _, isOn in
            addUserVm.notificationsChanged(to: isOn)
        }
        // Ao voltar para o app (ex.: depois de liberar nos Ajustes do iPhone),
        // confere a permissão de novo e atualiza o toggle.
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await addUserVm.syncNotificationPermission() }
        }
        .alert("Notificações desativadas", isPresented: $addUserVm.showNotificationsDeniedAlert) {
            Button("Abrir Ajustes") {
                addUserVm.openNotificationSettings()
            }
            Button("Agora não", role: .cancel) {}
        } message: {
            Text("Para receber lembretes, permita as notificações do app nos Ajustes do iPhone.")
        }
        // MARK: - Sheet
        .onChange(of: addUserVm.showForm) { _, isShowing in
            updateLift(sheetIsShowing: isShowing)
        }
        .sheet(isPresented: $addUserVm.showForm) {
            AddUserFormView(
                addUserVm: addUserVm,
                flyingPersistedUserID: flyingPersistedUserID,
                onAddPersistedUser: { user, sourceFrame in
                    beginPersistedUserFlight(user, from: sourceFrame)
                },
                onAddMyCard: { user, sourceFrame in
                    beginMyCardFlight(user, from: sourceFrame)
                }
            )
            .presentationBackground(Color("surfaceLight"))
        }
        // MARK: - Alerta
        .alert("Atenção!", isPresented: $addUserVm.showEmptyAlert) {
            Button("OK", role: .cancel) { }
        }
        message: {
            Text("Adicione usuários para continuar.")
        }
        // Erro ao escanear (falha real ou nenhum item identificado na nota) —
        // antes isso ficava guardado em scanVm.errorMessage sem nunca aparecer.
        .alert("Não deu pra ler a nota", isPresented: Binding(get: {scanVm.errorMessage != nil },set: { if !$0 { scanVm.errorMessage = nil } })){
            Button("Tentar novamente") {
                scanVm.errorMessage = nil
                vm.restoreServiceFee()
                scanVm.showScanner = true
            }
            Button("Adicionar manualmente") {
                scanVm.errorMessage = nil
                vm.restoreServiceFee()
                path.append(Rota.bill(autoOpenForm: true))
            }
            Button("Cancelar", role: .cancel) {
                scanVm.errorMessage = nil
            }
        }
        message: {Text(scanVm.errorMessage ?? "")}
        
        // Câmera abrindo: já carrega o modelo de IA enquanto a pessoa enquadra.
            .onChange(of: scanVm.showScanner) { _, isShowing in
                if isShowing { scanVm.prewarmModels() }
            }
        // Apresenta o scanner de documentos em uma tela modal.
            .sheet(isPresented: $scanVm.showScanner) {
                DocumentScannerView(
                    path: $path, onScanCompleted: { image in
                        scanVm.showScanner = false
                        processScannedImage(image)
                    },
                    onCancel: {
                        scanVm.showScanner = false
                    }
                )
                .ignoresSafeArea()
            }
    }
    
    // MARK: - Animação da bolha com a sheet
    /// Sheet subindo: a bolha sobe e encolhe com uma mola rápida e sem
    /// quique, para já estar no lugar quando a sheet termina de subir.
    private let liftUpAnimation: Animation = .spring(response: 0.3, dampingFraction: 0.92)
    /// Sheet descendo: a bolha volta um pouco mais devagar e com um quique
    /// leve, como se "respirasse" de volta ao tamanho normal.
    private let liftDownAnimation: Animation = .spring(response: 0.35, dampingFraction: 0.72)

    /// Escolhe a animação pela direção (subindo ou descendo). Sem animação
    /// se "Animações & haptics" estiver desligado.
    private var liftAnimation: Animation? {
        guard animationsOn else { return nil }
        return sheetLift > 0 ? liftUpAnimation : liftDownAnimation
    }

    var header: some View {
        VStack(spacing: 10){
            Text("**Quem** está com você hoje?")
                .font(.app(.title, weight: .medium))
                .lineLimit(typeSize.isAccessibilitySize ? 0 : 2, reservesSpace: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
            Text("Adicione um nome e um emoji para cada pessoa participante da conta!")
                .font(.app(.subheadline))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func beginPersistedUserFlight(_ user: User, from sourceCircleFrame: CGRect) {
        guard
            flyingPersistedUserID == nil,
            !persistedUserFlightOverlay.isFlying
                else {
            return
        }
        
        guard addUserVm.canBeginAddingExistingUser(user, in: vm) else {
            return
        }
        
        guard animationsOn, !bubbleFrame.isEmpty else {
            addUserVm.completeExistingUserAddition(user, in: vm)
            return
        }
        
        let startPoint = CGPoint(x: sourceCircleFrame.midX, y: sourceCircleFrame.midY)
        
        let endPoint = CGPoint(x: bubbleFrame.midX, y: bubbleFrame.midY - sheetLift)
        
        let sourceDiameter = max(min(sourceCircleFrame.width, sourceCircleFrame.height), 1)
        
        let targetDiameter = honeycombCenterCircleDiameter * bubbleScale
        
        flyingPersistedUserID = user.id
        
        let didStart = persistedUserFlightOverlay.fly(
            user: user,
            from: startPoint,
            to: endPoint,
            sourceDiameter: sourceDiameter,
            targetDiameter: targetDiameter,
            duration: persistedUserFlightDuration,
            onArrival: {
                addUserVm.completeExistingUserAddition(user, in: vm)
            },
            onFinished: {
                flyingPersistedUserID = nil
            }
        )
        
        guard didStart else {
            flyingPersistedUserID = nil
            
            addUserVm.completeExistingUserAddition(user, in: vm)
            
            return
        }
    }
    
    private func beginMyCardFlight(_ user: User, from sourceCircleFrame: CGRect) {
        guard
            flyingPersistedUserID == nil,
            !persistedUserFlightOverlay.isFlying
                else {
            return
        }
        
        guard addUserVm.canBeginAddingMyCard(user, in: vm) else {
            return
        }
        
        guard
            animationsOn,
            !sourceCircleFrame.isEmpty,
            !bubbleFrame.isEmpty
                else {
            addUserVm.completeMyCardAddition(user, in: vm)
            return
        }
        
        let startPoint = CGPoint(
            x: sourceCircleFrame.midX,
            y: sourceCircleFrame.midY
        )
        
        let endPoint = CGPoint(
            x: bubbleFrame.midX,
            y: bubbleFrame.midY - sheetLift
        )
        
        let sourceDiameter = max(min(sourceCircleFrame.width, sourceCircleFrame.height), 1)
        
        let targetDiameter = honeycombCenterCircleDiameter * bubbleScale
        
        let circleOnlyUser = User(
            id: user.id,
            name: "",
            emoji: user.emoji,
            color: user.color
        )
        
        flyingPersistedUserID = user.id
        
        let didStart = persistedUserFlightOverlay.fly(
            user: circleOnlyUser,
            from: startPoint,
            to: endPoint,
            sourceDiameter: sourceDiameter,
            targetDiameter: targetDiameter,
            duration: persistedUserFlightDuration,
            onArrival: {
                addUserVm.completeMyCardAddition(user, in: vm)
            },
            onFinished: {
                flyingPersistedUserID = nil
            }
        )
        
        guard didStart else {
            flyingPersistedUserID = nil
            
            addUserVm.completeMyCardAddition(user, in: vm)
            
            return
        }
    }
    
    @discardableResult
    private func beginUserRemovalFlight(_ selection: PhysicsUserSelection) -> Bool {
        guard let user = vm.bill.users.first(where: { $0.id == selection.userID }) else {
            return false
        }
        
        guard !persistedUserFlightOverlay.isFlying else {
            return false
        }
        
        // Haptic no momento do toque.
        addUserVm.playRemoveFeedback()
        
        guard
            animationsOn,
            !bubbleFrame.isEmpty,
            !addUserButtonFrame.isEmpty
                else {
            addUserVm.removeUserFromBill(id: user.id, in: vm)
            return true
        }
        
        let startPoint = CGPoint(
            x: bubbleFrame.minX + selection.centerInView.x,
            y: bubbleFrame.minY + selection.centerInView.y
        )
        
        let endPoint = CGPoint(
            x: addUserButtonFrame.midX,
            y: addUserButtonFrame.midY
        )
        
        let targetDiameter = max(min(addUserButtonFrame.height, 40), 1)
        
        // Esconde o círculo na bolha enquanto ele voa até o botão.
        removingUserIDs.insert(user.id)
        
        let didStart = persistedUserFlightOverlay.fly(
            user: user,
            from: startPoint,
            to: endPoint,
            sourceDiameter: max(selection.diameter, 1),
            targetDiameter: targetDiameter,
            duration: persistedUserFlightDuration,
            occlusionFrame: addUserButtonFrame,
            onArrival: {
                addUserVm.removeUserFromBill(id: user.id, in: vm)
            },
            onFinished: {
                removingUserIDs.remove(user.id)
            }
        )
        
        guard didStart else {
            removingUserIDs.remove(user.id)
            addUserVm.removeUserFromBill(id: user.id, in: vm)
            return true
        }
        
        return true
    }
    
    /// Calcula quanto subir (e reduzir) a bolha para ela ficar centralizada
    /// no espaço que sobra acima da sheet do formulário.
    private func updateLift(sheetIsShowing: Bool) {
        guard sheetIsShowing, bubbleFrame != .zero,
              let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.keyWindow
                else {
            sheetLift = 0
            bubbleScale = 1
            return
        }
        
        let screenHeight = window.bounds.height
        // Topo útil: logo abaixo da barra de navegação (~44pt).
        let visibleTop = window.safeAreaInsets.top + 44
        // Topo da sheet (ela ocupa `AddUserForm.detentFraction` da tela).
        let sheetTop = screenHeight * (1 - AddUserFormView.detentFraction(for: typeSize))
        let visibleHeight = sheetTop - visibleTop
        
        // Sheet quase em tela cheia (texto grande): não sobra espaço para a
        // bolha acima dela, então ela fica parada atrás da sheet.
        guard visibleHeight > 80 else {
            sheetLift = 0
            bubbleScale = 1
            return
        }
        
        // Reduz a bolha se ela não couber no espaço visível.
        bubbleScale = min(1, (visibleHeight - 16) / bubbleFrame.height)
        
        // Centraliza a bolha nesse espaço.
        let targetMidY = visibleTop + visibleHeight / 2
        sheetLift = max(0, bubbleFrame.midY - targetMidY)
    }
    
    /// Processa a imagem escaneada, extrai os produtos e adiciona
    /// os itens encontrados à conta antes de avançar para a comanda.
    /// A lógica fica na ScanViewModel; aqui só navega se deu certo.
    private func processScannedImage(_ image: UIImage) {
        Task {
            let success = await scanVm.processScannedImage(image, billViewModel: vm)
            if success {
                // Deixa a notinha terminar de sair da fenda antes de navegar.
                try? await Task.sleep(for: .seconds(ScanLoadingView.finishDuration + 0.15))
                path.append(Rota.bill(autoOpenForm: false))
            }
        }
    }
}

#Preview {
    AddUsersView(path: .constant(NavigationPath()))
        .environment(BillViewModel())
}
