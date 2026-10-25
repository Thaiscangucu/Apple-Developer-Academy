import SwiftUI

/// Tela responsável por exibir a comanda/recibo interativo de itens da conta.
struct BillView: View {
    @Binding var path: NavigationPath
    @Environment(BillViewModel.self) private var billVm

    // MARK: - ViewModels

    @State private var receiptVm = ReceiptOrderViewModel()
    /// Preferência global de animações & haptics.
    @AppStorage(AppSettings.animationsOn) private var animationsOn = true
    @State private var scanVm = ScanViewModel()
    @State private var editingItem: Product?
    @State private var showForm: Bool
    @State private var showEmptyItemsAlert = false
    @State private var isEditingServiceFee = false
    /// Controla o aviso de confirmação ao voltar para o escaneamento.
    @State private var showClearItemsAlert = false
    /// Caminho "Adicionar manualmente": a notinha fica guardada na impressora
    /// e só desce depois que a pessoa adiciona o primeiro item.
    @State private var waitingForFirstItem: Bool
    
    init(path: Binding<NavigationPath>, autoOpenForm: Bool = false) {
            self._path = path
            self._showForm = State(initialValue: autoOpenForm)
            self._waitingForFirstItem = State(initialValue: autoOpenForm)
        }

    /// Libera o botão de adicionar enquanto a notinha espera o primeiro item
    /// (senão a pessoa ficaria presa se fechasse o formulário sem adicionar).
    private var canAddItems: Bool {
        receiptVm.animationFinished || waitingForFirstItem
    }

    /// Imprime a notinha, a não ser que ainda esteja esperando o 1º item.
    private func startPrintingIfReady() {
        if waitingForFirstItem {
            guard !billVm.bill.items.isEmpty else { return }
            waitingForFirstItem = false
        }
        receiptVm.startPrintAnimation(animated: animationsOn)
    }

    /// Soma do valor total de todos os itens cadastrados.
    private var subtotal: Double {
        billVm.bill.items.reduce(0) { $0 + $1.total }
    }

    /// Binding bidirecional para atualizar a lista de itens diretamente no BillViewModel.
    private var itemsBinding: Binding<[Product]> {
        Binding(
            get: { billVm.bill.items },
            set: { billVm.bill.items = $0 }
        )
    }

    /// Binding da porcentagem da taxa de serviço armazenada na Bill.
    private var serviceFeePercentageBinding: Binding<Double> {
        Binding(
            get: { billVm.bill.serviceFeePercentage },
            set: { billVm.bill.serviceFeePercentage = $0 }
        )
    }

    /// Valor da taxa de serviço calculado sobre o subtotal.
    /// Retorna 0 quando a taxa foi removida via swipe na comanda.
    private var serviceFee: Double {
        guard !billVm.bill.isServiceFeeRemoved else { return 0 }
        return subtotal * (billVm.bill.serviceFeePercentage / 100)
    }

    /// Valor total da conta incluindo a taxa de serviço.
    private var grandTotal: Double {
        subtotal + serviceFee
    }

    /// Remove a linha da taxa de serviço da comanda, com animação, e
    /// zera a taxa considerada no cálculo do total a partir daí.
    private func removeServiceFee() {
        withAnimation(.easeInOut(duration: 0.25)) {
            billVm.removeServiceFee()
        }
    }

    /// Abre a sheet de edição da taxa de serviço.
    private func editServiceFee() {
        isEditingServiceFee = true
    }

    /// Ao tocar em voltar: se houver itens na comanda, pede confirmação
    /// antes de apagá-los; se estiver vazia, apenas volta.
    private func handleBack() {
        if billVm.bill.items.isEmpty {
            goBack()
        } else {
            showClearItemsAlert = true
        }
    }

    /// Limpa os itens da comanda e volta para a tela de escaneamento.
    private func clearItemsAndGoBack() {
        billVm.clearItems()
        goBack()
    }

    private func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    var body: some View {
        ZStack {
            // Fundo da tela
            Color("background")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Área Superior (Animação do Recibo e Impressora)

                ZStack(alignment: .top) {
                    // Comanda/Papel de Recibo contendo os itens e os totais
                    
                    ReceiptPaper(
                        items: itemsBinding,
                        serviceFeePercentage: serviceFeePercentageBinding,
                        serviceFee: serviceFee,
                        grandTotal: grandTotal,
                        isServiceFeeRemoved: billVm.bill.isServiceFeeRemoved,
                        onDelete: billVm.removeItem,
                        onEdit: { editingItem = $0 },
                        onEditServiceFee: editServiceFee,
                        onRemoveServiceFee: removeServiceFee
                    )
                    // Desabilita toques e ações na comanda até a animação de impressão concluir
                    .disabled(!receiptVm.animationFinished)
//                    .padding(.top, 40)
                    // Efeitos visuais da animação de saída da impressora
                    .offset(y: receiptVm.isPrinted ? 0 : -510)
                    .offset(x: receiptVm.printerShake)
                    .opacity(receiptVm.isPrinted ? 1.0 : 0.0)
                    // Achata offset + opacity numa única camada antes da máscara.
                    // Sem isso, em algumas versões do iOS o .mask() só renderiza
                    // o quadro final da animação (o papel "aparece" em vez de
                    // "descer deslizando"), porque o mask e o conteúdo animado
                    // acabam sendo compostos em camadas separadas.
                    .compositingGroup()
                    // Máscara para simular o papel saindo da fenda da impressora
                    .mask(
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: PrinterBar.paperExitY)

                            Rectangle()
                                .fill(Color.white)

                            Spacer(minLength: 0)
                        }
                    )
                    .zIndex(9)

                    // Barra gráfica representando a boca da impressora
                    PrinterBar()
                        .zIndex(1)
                        .accessibilityHidden(true)

                    // Sombra no topo para dar profundidade ao papel saindo da impressora
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 0.16, green: 0.25, blue: 0.28), location: 0.00),
                            Gradient.Stop(color: Color(red: 0.4, green: 0.6, blue: 0.68).opacity(0), location: 1.00),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 34)
                    .clipShape(RoundedRectangle(cornerRadius: 1))
                    .accessibilityHidden(true)
                    // Mesma largura do papel da notinha.
                    .padding(.horizontal, ReceiptPaper.paperHorizontalInset)
                    .padding(.top, PrinterBar.paperExitY)
                    .allowsHitTesting(false)
                    .zIndex(10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // MARK: - Área Inferior (Botões de Ação)

                // Esconde os botões caso o teclado esteja aberto na tela
                if !receiptVm.isKeyboardVisible {
                    VStack(spacing: 12) {
                        // Botão para adicionar mais itens manualmente
                        RecButton(
                            title: "Adicionar mais itens",
                            backgroundColor: .white,
                            foregroundColor: .black
                        ) {
                            showForm.toggle()
                        }
                        .disabled(!canAddItems)
                        .opacity(canAddItems ? 1.0 : 0.6)

                        // Botão para avançar para a próxima etapa
                        RecButton(
                            title: "Próximo",
                            backgroundColor: Color("accentSlate"),
                            foregroundColor: .white
                        ) {
                            guard receiptVm.animationFinished else { return }

                            if billVm.bill.items.isEmpty {
                                showEmptyItemsAlert = true
                            } else {
                                path.append(Rota.split)
                            }
                        }
                        .disabled(!receiptVm.animationFinished)
                        .opacity(receiptVm.animationFinished ? 1.0 : 0.6)
                        .alert("Atenção!", isPresented: $showEmptyItemsAlert) {
                            Button("OK", role: .cancel) {}
                        } message: {
                            Text("Adicione ao menos um item para continuar.")
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                    .padding(.top, 8)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        // Esconde o voltar padrão para poder exibir o aviso de confirmação
        .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: handleBack) {
                            Image(systemName: "chevron.left")
                        }
                        .accessibilityLabel("Voltar")
                        .accessibilityHint("Volta para o escaneamento e apaga os itens da notinha.")
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Aqui está sua **notinha!**")
                          .font(.app(.body, weight: .medium))
                          .accessibilityAddTraits(.isHeader)
                          // A barra de navegação tem altura fixa: igual aos
                          // títulos do sistema, o texto para de crescer aqui.
                          .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    }
                }
        
        // Confirmação antes de apagar os itens ao voltar
        .alert("Voltar para o escaneamento?", isPresented: $showClearItemsAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Apagar e voltar", role: .destructive) {
                clearItemsAndGoBack()
            }
        } message: {
            Text("Todos os itens da notinha serão apagados.")
        }

        // MARK: - Sheets

        // Form para editar item existente na comanda
        .sheet(item: $editingItem) { item in
            EditableProductForm(item: item) { updated in
                billVm.updateItem(updated)
            }
        }
        // Form para adicionar novo item manualmente
        .sheet(isPresented: $showForm) {
            AddItensManualForm { newItem in
                billVm.addScannedItems([newItem])
                // Só no item manual: os itens escaneados já têm o haptic de
                // "impressora" da notinha descendo.
                Haptics.itemAdded()
            }
        }
        // Form para editar a porcentagem da taxa de serviço
        .sheet(isPresented: $isEditingServiceFee) {
            EditServiceFeeForm(
                percentage: billVm.bill.serviceFeePercentage,
                subtotal: subtotal
            ) { newPercentage in
                billVm.bill.serviceFeePercentage = newPercentage
            }
        }
        // MARK: - Ciclo de Vida e Observadores de Teclado

        .onAppear {
            startPrintingIfReady()
            // Bloqueia o voltar arrastando, para não pular o aviso de confirmação.
            // Async para rodar depois do onDisappear da SplitView (que reabilita o gesto).
            DispatchQueue.main.async {
                UINavigationController.disableSwipeBack()
            }
        }
        .onDisappear {
            UINavigationController.enableSwipeBack()
            receiptVm.stopPrintHaptics()
        }
        // Caminho manual: quando o formulário fecha com um item adicionado,
        // a notinha desce (já com o item). Fechou sem adicionar: continua
        // esperando, com o botão "Adicionar mais itens" liberado.
        .onChange(of: showForm) { _, isShowing in
            guard !isShowing, waitingForFirstItem else { return }
            startPrintingIfReady()
        }
        // Avisa o VoiceOver quando a comanda termina de "imprimir"
        // (antes disso os botões ficam desabilitados).
        .onChange(of: receiptVm.animationFinished) { _, finished in
            guard finished else { return }
            AccessibilityAnnouncer.announce(
                String(localized: "Notinha pronta, \(billVm.bill.items.count) itens. Total \(CurrencyHelper.accessibilityFormat(grandTotal))")
            )
        }
        // Monitora quando o teclado aparece para esconder a barra de botões
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                receiptVm.isKeyboardVisible = true
            }
        }
        // Monitora quando o teclado fecha para reexibir a barra de botões
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                receiptVm.isKeyboardVisible = false
            }
        }
    }
}

#Preview("Notinha com itens") {
    let vm = BillViewModel()
    vm.bill.items = [
        Product(name: "Cerveja Original 1L", price: 9.00, quantity: 2),
        Product(name: "Batata frita", price: 70.00, quantity: 1),
        Product(name: "Caipirinha", price: 28.00, quantity: 3),
        Product(name: "Água com gás", price: 8.00, quantity: 2)
    ]

    return NavigationStack {
        BillView(path: .constant(NavigationPath()))
    }
    .environment(vm)
}
