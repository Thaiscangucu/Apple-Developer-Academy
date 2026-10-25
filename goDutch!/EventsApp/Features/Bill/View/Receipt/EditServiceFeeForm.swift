import SwiftUI

/// Sheet responsável por editar a taxa de serviço da conta. Usa os mesmos
/// componentes dos formulários de item (`ItemFormComponents`). O nome da
/// taxa é fixo — só a porcentagem pode ser alterada, digitada no `PercentAmountField` —
/// e o valor calculado é atualizado ao vivo conforme a porcentagem muda.
struct EditServiceFeeForm: View {
    
    @Environment(\.dismiss) private var dismiss
    
    /// Porcentagem da taxa sendo editada nesta sheet.
    @State private var percentage: Double
    
    /// Subtotal da conta (soma dos itens, sem a taxa), usado para
    /// recalcular o valor da taxa ao vivo conforme o stepper muda.
    let subtotal: Double
    
    /// Devolve a nova porcentagem escolhida para quem abriu o formulário.
    let onSave: (Double) -> Void
    
    /// Inicializa o formulário com a porcentagem atual da taxa.
    init(percentage: Double, subtotal: Double, onSave: @escaping (Double) -> Void) {
        _percentage = State(initialValue: percentage)
        self.subtotal = subtotal
        self.onSave = onSave
    }

    /// Valor da taxa recalculado ao vivo com a porcentagem escolhida,
    /// para exibição na linha "Valor".
    private var calculatedFee: Double {
        subtotal * (percentage / 100)
    }

    var body: some View {
        ItemFormSheet(
            // Sem o "Item" acima do cartão: o título "Taxa de Serviço"
            // dentro dele já identifica o formulário.
            header: nil,
            leadingAction: .cancel,
            confirmAccessibilityLabel: "Salvar taxa",
            onConfirm: save
        ) {
            // Nome fixo — a taxa de serviço não pode ser renomeada,
            // diferente do nome de um item comum.
            ItemFormTitle("Taxa de Serviço")

            // O campo ao lado já se anuncia como "Porcentagem da taxa de serviço".
            ItemFormRow("Porcentagem") {
                PercentAmountField(
                    percentage: $percentage,
                    accessibilityLabel: "Porcentagem da taxa de serviço"
                )
            }

            // Valor calculado a partir da porcentagem — não é editável.
            ItemFormRow("Valor") {
                CurrencyAmountText(value: calculatedFee, accessibilityLabel: "Valor da taxa")
            }
        }
    }

    /// Devolve a porcentagem escolhida para quem abriu o formulário
    /// e fecha a sheet.
    func save() {
        onSave(percentage)
        dismiss()
    }
}

#Preview("Edit Service Fee") {

    Text("View Principal")
        .sheet(isPresented: .constant(true)) {
            EditServiceFeeForm(percentage: 10, subtotal: 120) { newPercentage in
                print("Nova porcentagem escolhida no Preview: \(newPercentage)")
            }
            .presentationDragIndicator(.visible)
        }
}
