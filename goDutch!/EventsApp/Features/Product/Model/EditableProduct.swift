import Foundation
import SwiftUI

/// Modelo usado pela UI para permitir edição e identificação estável na lista
/// (`Identifiable`). É separado do `ConsumedItem` (gerado pela IA) porque
/// aquele é um `@Generable` do Foundation Models — não queremos misturar
/// campos de controle de UI (como `id`) com o schema que o modelo preenche.
struct EditableProduct: Identifiable {
    var id = UUID()
    var name: String
    var quantity: Int
    var price: Double

    init(id: UUID = UUID(), name: String, quantity: Int, price: Double) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.price = price
    }

    /// Converte o resultado gerado pela IA (`ConsumedItem`) para o modelo editável da UI.
    @available(iOS 26.0, *)
    init(from generated: ConsumedItem) {
        self.id = UUID()
        self.name = generated.name
        self.quantity = generated.quantity
        self.price = generated.price
    }
}
