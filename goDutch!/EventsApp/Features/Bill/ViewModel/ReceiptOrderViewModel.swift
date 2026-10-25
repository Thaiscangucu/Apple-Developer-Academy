import SwiftUI

@Observable
final class ReceiptOrderViewModel {
    var serviceFeePercentage: Double = 10.0
    var isPrinted: Bool = false
    var animationFinished: Bool = false
    var navigateToNext: Bool = false
    var printerShake: CGFloat = 0
    var isKeyboardVisible = false

    // MARK: Animação da nota (a vibração usa os mesmos valores)
    private let printDelay: TimeInterval = 0.35
    private let printDuration: TimeInterval = 1.3
    /// Vibração contínua enquanto a nota desce.
    @ObservationIgnored private let printHaptics = PrintHaptics()

    func serviceFee(subtotal: Double) -> Double {
        subtotal * (serviceFeePercentage / 100.0)
    }

    func grandTotal(subtotal: Double) -> Double {
        subtotal + serviceFee(subtotal: subtotal)
    }

    /// - Parameter animated: se `false` (animações desligadas nas configurações),
    ///   a nota aparece direto, sem descer e sem haptics.
    func startPrintAnimation(animated: Bool = true) {
        guard !animationFinished else { return }

        guard animated else {
            isPrinted = true
            animationFinished = true
            return
        }

        // Vibração contínua que acompanha a descida (mesma curva easeInOut),
        // com uma batida no fim. Respeita "Animações & haptics" dos Ajustes.
        printHaptics.play(delay: printDelay, duration: printDuration, curve: .easeInOut)

        // IMPORTANTE: a mudança de `isPrinted` precisa acontecer dentro de um
        // `DispatchQueue.main.asyncAfter` (uma transação nova do runloop), e
        // não usando `Animation.delay(...)` como antes. Quando o `withAnimation`
        // roda de forma síncrona dentro do `onAppear`, ele pode acabar
        // agrupado na MESMA transação da transição de push do NavigationStack.
        // Em iOS mais recentes (a transição de "push" ficou mais longa/fluida),
        // isso faz a nota simplesmente "aparecer" no valor final em vez de
        // deslizar — a animação explícita é engolida pela transação da
        // navegação. Adiando a própria chamada do `withAnimation` (e não só a
        // curva) garante que ela rode numa transação isolada, já fora da
        // transição de navegação, o que é consistente em qualquer device/OS.
        DispatchQueue.main.asyncAfter(deadline: .now() + printDelay) { [weak self] in
            guard let self else { return }
            withAnimation(.easeInOut(duration: self.printDuration)) {
                self.isPrinted = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + printDelay + printDuration + 0.05) { [weak self] in
            self?.animationFinished = true
        }
    }

    /// Para a vibração se a tela sair antes da nota terminar de descer.
    func stopPrintHaptics() {
        printHaptics.stop()
    }
}
