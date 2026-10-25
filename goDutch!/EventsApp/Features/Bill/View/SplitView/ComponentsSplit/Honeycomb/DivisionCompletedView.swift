//
//  DivisionCompletedView.swift
//  JuncaoPocs
//
//  Created by Camila Parolin on 25/08/26.
//

import SwiftUI

//tela que aparece quando o ciclo da view é dado como completo
struct DivisionCompletedView: View {
    
    @Environment(BillViewModel.self)
    private var billViewModel
    
    var body: some View {
        List {
            ForEach(billViewModel.bill.users) { user in
                AdaptiveStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(user.color)
                        
                            Text(user.emoji)
                                .font(.title3)
                        }
                        .frame(width: 44)
                        .accessibilityHidden(true)
                    
                        Text(user.name)
                            .font(.body)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Text(billViewModel.totalToPay(for: user), format: CurrencyHelper.formatStyle)
                        .font(.headline)
                        .monospacedDigit()
                }
                .padding(.vertical, 6)
                // "Ana, R$ 42,50" em um único elemento.
                .accessibilityElement(children: .combine)
            }
        }
        .navigationTitle("Resumo da divisão")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DivisionCompletedView()
    }
}
