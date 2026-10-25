import SwiftUI

/// Sheet responsável por editar um produto que já pertence à conta.
/// Permite alterar nome, quantidade e preço, mantendo os demais dados
/// do produto original, como os usuários já associados ao item.
struct EditableProductForm: View {

    @Environment(\.dismiss) private var dismiss
    /// ViewModel da conta, usado para excluir o item.
    @Environment(BillViewModel.self) private var billVm

    // MARK: - Dados do formulário

    @State private var name: String
    @State private var quantity: Int

    /// Valor do preço guardado em centavos (inteiro). É a partir dele que o
    /// campo de texto é formatado — mesmo comportamento do AddItensManualForm:
    /// o número é preenchido da direita para a esquerda, como no Nubank.
    @State private var priceInCents: Int

    /// Controla o alerta de confirmação antes de excluir o item.
    @State private var showDeleteAlert = false

    /// Produto original que será editado.
    /// É utilizado como base para preservar informações que não fazem
    /// parte deste formulário, como os usuários associados ao item.
    let originalItem: Product

    /// Retorna o produto atualizado para a View responsável pelo formulário.
    let onSave: (Product) -> Void

    /// Inicializa o formulário com os dados atuais do produto selecionado.
    init(item: Product, onSave: @escaping (Product) -> Void) {

        self.originalItem = item
        self.onSave = onSave

        // Preenche os campos com os valores atuais do produto.
        _name = State(initialValue: item.name)
        _quantity = State(initialValue: item.quantity)

        // Converte o preço atual do produto para centavos, que é a
        // unidade usada internamente pelo campo estilo Nubank.
        _priceInCents = State(initialValue: Int((item.price * 100).rounded()))
    }


    var body: some View {
        ItemFormSheet(
            headerAccessibilityLabel: "Editar item",
            leadingAction: .delete(
                accessibilityLabel: "Excluir item",
                action: { showDeleteAlert = true }
            ),
            confirmAccessibilityLabel: "Salvar alterações",
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
        // Confirmação antes de excluir o item.
        .alert("Excluir item?", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Excluir", role: .destructive) {
                delete()
            }
        } message: {
            Text("\"\(originalItem.name)\" será removido da conta.")
        }
    }

    /// Cria uma cópia atualizada do produto original e a envia para a View
    /// responsável por persistir as alterações.
    private func save() {

        // O preço vem direto dos centavos digitados no campo estilo Nubank.
        // Caso o campo tenha sido zerado, mantém o preço original.
        let price = priceInCents > 0 ? Double(priceInCents) / 100 : originalItem.price

        // Começa com uma cópia do produto original para preservar
        // propriedades que não são editadas neste formulário.
        var updated = originalItem

        updated.name = name
        updated.quantity = quantity
        updated.price = price

        // Devolve o produto atualizado para quem abriu o formulário.
        onSave(updated)

        // Fecha a sheet após salvar.
        dismiss()
    }

    /// Remove o produto da conta (e dos usuários associados a ele) e fecha a sheet.
    private func delete() {
        billVm.removeItem(originalItem)
        dismiss()
    }
}

#Preview("Edit Item") {

    let sampleProduct = Product(
        name: "Café Espresso",
        price: 8.50,
        quantity: 2
    )

    Text("View Principal")
        .sheet(isPresented: .constant(true)) {
            EditableProductForm(item: sampleProduct) { updatedItem in
                print("Item atualizado no Preview: \(updatedItem.name)")
            }
            .presentationDragIndicator(.visible)
            .environment(BillViewModel())
        }
}
