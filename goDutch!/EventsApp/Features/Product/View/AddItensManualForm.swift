import SwiftUI
import UIKit

/// Erros de validação que podem ocorrer durante o preenchimento dos formulários.
/// Cada caso representa uma situação que impede o cadastro e possui uma mensagem
/// amigável para ser exibida ao usuário.
enum FormError: LocalizedError {

    /// O nome do item está vazio ou contém apenas espaços.
    case emptyName

    /// O preço informado é inválido ou menor/igual a zero.
    case invalidPrice

    /// A quantidade informada é inválida ou menor/igual a zero.
    case invalidQuantity

    /// O nome do usuário está vazio ou contém apenas espaços.
    case emptyUserName

    /// Mensagem correspondente ao erro, pronta para ser exibida ao usuário.
    var errorDescription: String {
        switch self {
        case .emptyName:
            return String(localized: "Por favor, digite o nome do item.")

        case .invalidPrice:
            return String(localized: "O preço do item deve ser maior que zero.")

        case .invalidQuantity:
            return String(localized: "A quantidade deve ser maior que zero.")

        case .emptyUserName:
            return String(localized: "Por favor, adicione um nome para este usuário.")
        }
    }
}

/// Formulário utilizado para adicionar manualmente um novo item à conta.
struct AddItensManualForm: View {

    @Environment(\.dismiss) private var dismiss

    // MARK: - Dados do formulário

    @State private var name: String = ""
    @State private var quantity: Int = 1

    /// Valor do preço guardado em centavos (inteiro). É a partir dele que o
    /// campo de texto é formatado — assim como no Nubank, o número sempre
    /// começa em "0,00" e cada dígito novo entra pela direita, empurrando
    /// os demais para a esquerda.
    @State private var priceInCents: Int = 0

    // Controlam a exibição e o conteúdo do alerta de validação.
    @State var showAlert = false
    @State private var alertMessage = ""

    /// Executado quando o item é validado e salvo com sucesso.
    let onSave: (Product) -> Void

    var body: some View {
        ItemFormSheet(
            headerAccessibilityLabel: "Novo item",
            leadingAction: .cancel,
            confirmAccessibilityLabel: "Adicionar item",
            onConfirm: save
        ) {
            ItemNameField(name: $name)

            ItemFormRow("Quantidade") {
                QuantityStepper(quantity: $quantity)
            }

            ItemFormRow("Valor") {
                CurrencyAmountField(cents: $priceInCents)
            }
        }
        // Exibe mensagens de erro quando os dados preenchidos são inválidos.
        .alert("Atenção", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    /// Valida os dados preenchidos, cria o novo produto e o devolve
    /// para a tela responsável por adicioná-lo à conta.
    private func save() {

        // Remove espaços extras antes de validar o nome.
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        // O item não pode ser salvo sem um nome.
        guard !trimmedName.isEmpty else {
            alertMessage = FormError.emptyName.errorDescription
            showAlert = true
            return
        }

        // O preço vem direto dos centavos digitados no campo estilo Nubank.
        let price = Double(priceInCents) / 100

        // Impede o cadastro caso o preço seja zero.
        guard price > 0 else {
            alertMessage = FormError.invalidPrice.errorDescription
            showAlert = true
            return
        }

        // Cria o produto somente depois que todos os dados obrigatórios foram validados.
        let newItem = Product(
            name: trimmedName,
            price: price,
            quantity: quantity
        )

        // Entrega o novo produto para a View que apresentou este formulário.
        onSave(newItem)

        // Fecha a sheet após o cadastro.
        dismiss()
    }
}

#Preview {
    AddItensManualForm { newItem in
        print("Item salvo: \(newItem.name)")
    }
}
