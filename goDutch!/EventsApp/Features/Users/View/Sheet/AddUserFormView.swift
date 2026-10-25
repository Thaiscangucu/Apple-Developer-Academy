import SwiftUI
import UIKit
import AudioToolbox
// MARK: - View (Layout Declarativo)

/// Formulário utilizado para adicionar um novo participante à conta.
/// Alterna entre a lista de participantes já usados e o formulário de
/// criação/edição.
struct AddUserFormView: View {
    @Environment(BillViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    /// ViewModel compartilhada com a tela AddUsers (quem abre o formulário).
    @Bindable var addUserVm: AddUserViewModel
    
    var flyingPersistedUserID: User.ID? = nil
    
    var onAddPersistedUser: ((User, CGRect) -> Void)? = nil
    var onAddMyCard: ((User, CGRect) -> Void)? = nil

    /// Altura da sheet (fração da tela), conforme o tamanho de texto.
    /// A AddUsers usa esse valor para saber quanto espaço sobra acima
    /// dela e subir a bolha.
    static func detentFraction(for typeSize: DynamicTypeSize) -> CGFloat {
        // ALTURA DA SHEET (ajuste aqui) — fração da tela que ela ocupa.
        if typeSize.isAccessibilitySize {
            return 0.92   // tamanhos de acessibilidade (AX1–AX5): quase tela cheia
        } else if typeSize > .large {
            return 0.68   // texto maior que o padrão (xLarge–xxxLarge)
        } else {
            return 0.55   // tamanho padrão do iPhone ou menor
        }
    }

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        NavigationStack {
            Group {
                switch addUserVm.currentPage {
                case .existing:
                    ExistingUsersPage(addUserVm: addUserVm, flyingUserID: flyingPersistedUserID, onAddPersistendUser: onAddPersistedUser, onAddMyCard: onAddMyCard)
                        .transition(.opacity)
                case .form:
                    UserFormPage(addUserVm: addUserVm)
                        .transition(.opacity)
                }
            }
            .navigationTitle(addUserVm.formTitle)
            .navigationBarTitleDisplayMode(.inline)
            // Abre na altura de `detentFraction` (que cresce com o texto,
            // senão o conteúdo não cabe) e dá para puxar até a tela cheia.
            .presentationDetents([.fraction(Self.detentFraction(for: typeSize)), .large])
            .presentationDragIndicator(.visible)
            // Arrastar para cima sobe a sheet antes de rolar o conteúdo.
            .presentationContentInteraction(.resizes)
            .toolbar {
                switch addUserVm.currentPage {
                case .existing:
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .tint(.black)
                        .accessibilityLabel("Fechar")
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            addUserVm.startNewUser()
                        } label: {
                            Image(systemName: "plus")

                        }
                        .accessibilityLabel("Novo participante")
                        .adaptiveProminentButtonStyle()
                        .tint(.accentColor)
                    }
                case .form:
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            // Se não há participantes salvos, não existe
                            // pra onde "voltar" — fecha o formulário inteiro.
                            // Se existir lista, volta pra ela normalmente.
                            // Editando pela bolha: não há lista para voltar.
                            if hasExistingPage && addUserVm.editingBillUserID == nil {
                                addUserVm.cancelForm()
                            } else {
                                dismiss()
                            }
                        } label: {
                            Image(systemName: hasExistingPage && addUserVm.editingBillUserID == nil ? "chevron.left" : "xmark")
                        }
                        .tint(.black)
                        .accessibilityLabel(hasExistingPage && addUserVm.editingBillUserID == nil ? Text("Voltar") : Text("Fechar"))
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            addUserVm.submitForm(in: vm)
                        } label: {
                            Image(systemName: "checkmark")
                        }
                        .accessibilityLabel("Salvar participante")
                        .adaptiveProminentButtonStyle()
                        .tint(.accentColor)
                    }
                }
            }
            .alert("Atenção", isPresented: $addUserVm.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(addUserVm.alertMessage)
            }
        }
        // Decide a página inicial FORA do body: se não há participantes
        // salvos, começa direto no formulário. Mutar `currentPage` dentro
        // do body (como estava antes) é undefined behavior no SwiftUI —
        // é por isso que o comportamento estava inconsistente.
        .onAppear {
            if !hasExistingPage {
                addUserVm.currentPage = .form
            }
        }
        // Cobre o caso de o usuário apagar o último participante salvo
        // enquanto está na lista: também deve cair pro formulário.
        .onChange(of: vm.oldUsers) { _, _ in
            goToFormIfListIsEmpty()
        }
        // Mesmo caso ao apagar o "Meu Card".
        .onChange(of: addUserVm.myCard) { _, _ in
            goToFormIfListIsEmpty()
        }
    }

    /// A lista só existe se houver participantes salvos ou um "Meu Card".
    private var hasExistingPage: Bool {
        !vm.oldUsers.isEmpty || addUserVm.myCard != nil
    }

    private func goToFormIfListIsEmpty() {
        if !hasExistingPage && addUserVm.currentPage == .existing {
            withAnimation {
                addUserVm.currentPage = .form
            }
        }
    }
}

#Preview {
    AddUserFormView(addUserVm: AddUserViewModel())
        .environment(BillViewModel())
}
