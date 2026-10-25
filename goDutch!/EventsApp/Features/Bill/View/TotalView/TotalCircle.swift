
//
//  PaymentProgressView.swift
//  EventsApp
//
//  Created by Thais Cangucu on 03/09/26.
//

import SwiftUI

struct TotalCircle: View {
    let progress: CGFloat
    let formattedTotal: String
    let formattedTarget: String
    let totalAmount: Double
    let isCompleted: Bool
    /// `true` quando o botão "Concluir pagamento" está levando todos de uma
    /// vez: o anel e o valor avançam mais rápido, acompanhando os cards.
    var isPayingAll: Bool = false

    private let circleSize: CGFloat = 270

    /// Cor do preenchimento do anel (#C4DCE4).
    private let progressColor = Color(red: 196 / 255, green: 220 / 255, blue: 228 / 255)

    /// Pagamento a pagamento: avanço suave. Pagar todos: rápido, em
    /// degraus curtos que se encadeiam conforme cada card chega.
    private var progressAnimation: Animation {
        isPayingAll ? .easeOut(duration: 0.2) : .easeInOut(duration: 0.6)
    }

    var body: some View {
        ZStack {
            ZStack {
                VStack(spacing: 4) {
                    Text("**Arraste** aqui quem já pagou!")
                        .font(.app(.caption))
                        .foregroundColor(Color("textSecondary"))

                    HStack(spacing: CurrencyHelper.symbolSpacing) {
                        Text(verbatim: CurrencyHelper.symbol)
                            .font(.app(.headline))
                        
                        Text(formattedTotal)
                            .font(Font.custom("Montserrat Alternates", size: 60).weight(.semibold))
                            .contentTransition(.numericText())
                            .animation(progressAnimation, value: totalAmount)
                    }
                }
                
                Text("Pago")
                    .font(.app(.headline))
                    .offset(x: 63, y: 55)
                
                // Valor total que precisa ser pago
                HStack(spacing: 0) {
                    Text(verbatim: CurrencyHelper.symbol)
                        .font(.app(.caption))
                    
                    Text(formattedTarget)
                        .font(.app(.headline, weight: .bold))
                }
                .offset(y: 80)
            }
            .padding(.bottom, 20)
            
            // Anel de fundo
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 12)
                .blur(radius: 1.7)
                .frame(width: circleSize, height: circleSize)

            // Anel que representa o progresso do pagamento
            Circle()
                .trim(from: 0, to: progress)
                .stroke(progressColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .frame(width: circleSize, height: circleSize)
                .rotationEffect(.degrees(-90))
                .animation(progressAnimation, value: progress)

                
        }

        .foregroundColor(Color("textSecondary"))
        .frame(width: circleSize, height: circleSize)
        .transition(.scale.combined(with: .opacity))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Já pago")
        .accessibilityValue("\(CurrencyHelper.symbol) \(formattedTotal) de \(CurrencyHelper.symbol) \(formattedTarget)")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

#Preview {
    VStack {
        TotalCircle(
            progress: 0.65,
            formattedTotal: "13,00",
            formattedTarget: "58,30",
            totalAmount: 650,
            isCompleted: false
        )
    }
}

