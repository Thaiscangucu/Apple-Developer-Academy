import SwiftUI
import SpriteKit

struct CardView: View {
    @Binding var path: NavigationPath
    @Environment(BillViewModel.self) private var billVm
    @State var viewModel = ContentViewModel()
    @State private var cardsVm: ScatteredCardsViewModel?  // se precisar resetar aqui

    var body: some View {
        SpriteView(scene: viewModel.scene)
            .ignoresSafeArea()
            // A cena é toda em SpriteKit (invisível ao VoiceOver) e pede um
            // arrasto do cartão. Para o VoiceOver: título + um botão que
            // faz o mesmo que arrastar o cartão até a maquininha.
            .accessibilityRepresentation {
                VStack {
                    Text("Hora de fechar a conta!")
                        .accessibilityAddTraits(.isHeader)

                    Button("Passar o cartão e fechar a conta") {
                        viewModel.scene.accessibilityCloseAccount()
                        AccessibilityAnnouncer.announce(String(localized: "Conta fechada e salva no histórico"))
                    }
                    .accessibilityHint("Conclui o pagamento e volta para o início.")
                }
            }
            .onChange(of: UIScreen.main.bounds.size) { _, newSize in
                viewModel.updateSceneSize(newSize)
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                viewModel.onAppear()
                UINavigationController.disableSwipeBack()
                viewModel.onPaymentCompleted = {
                    // Guarda a conta finalizada no histórico antes de
                    // limpá-la, para futura consulta/exportação.
                    billVm.saveBillToHistory()
                    billVm.resetBill()
                    path = NavigationPath()
                }
            }
            .onDisappear {
                UINavigationController.enableSwipeBack()
            }
    }
}

#Preview {
    CardView(path: .constant(NavigationPath()))
        .environment(BillViewModel())
}
