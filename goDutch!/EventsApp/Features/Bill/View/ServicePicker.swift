//
//  ServicePicker.swift
//  EventsApp
//
//  Created by Thais Cangucu on 22/09/26.
//

import SwiftUI

struct ServicePicker: View {
    
    @Binding var percentage: Double
    /// Opções de porcentagem disponíveis para seleção no Picker
    /// De 0% a 20%, de 1 em 1.
    let options: [Double] = (0...20).map(Double.init)
    
    /// Controla a exibição do popover com a roda de seleção.
    @State private var isShowingPicker = false

    var body: some View{
        // Pílula que abre uma roda de seleção (estilo do picker de horário
        // do iOS) num popover ancorado nela.
        Button {
            isShowingPicker = true
        } label: {
            HStack(spacing: 6) {
                // Reserva sempre a largura do maior valor ("20%") para a
                // pílula não mudar de tamanho/posição entre 1 e 2 dígitos.
                ZStack(alignment: .trailing) {
                    Text("20%").hidden()
                    Text("\(Int(percentage))%")
                }
                .monospacedDigit()
                Image(systemName: "chevron.up.chevron.down")
            }
            .font(.app(.caption))
            .lineLimit(1)
            // A pílula acompanha o tamanho do texto. Antes ela tinha
            // largura fixa de 55pt e, com a fonte grande, o "10%"
            // ficava cortado.
            .fixedSize()
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .frame(minWidth: 55, minHeight: 20)
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.white)
                    .shadow(color: Color("shadowMedium").opacity(0.41), radius: 2, x: 0, y: 0)
            }
            .foregroundColor(Color("textSecondary"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isShowingPicker, arrowEdge: .bottom) {
            Picker("Taxa de serviço", selection: $percentage) {
                ForEach(options, id: \.self) { value in
                    Text("\(Int(value))%").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(width: 160, height: 180)
            .padding(.horizontal, 8)
            // Mantém como popover no iPhone (em vez de virar sheet),
            // igual ao picker de horário compacto.
            .presentationCompactAdaptation(.popover)
        }
        .accessibilityLabel("Porcentagem da taxa de serviço")
        .accessibilityValue("\(Int(percentage))%")
        .accessibilityHint("Toque duas vezes para escolher outra porcentagem.")
    }
}
