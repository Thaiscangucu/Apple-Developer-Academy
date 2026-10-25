//
//  MinCard.swift
//  EventsApp
//
//  Created by Camila Parolin on 31/08/26.
//

import SwiftUI
import Foundation

//view do card quando "recolhido"
struct MinCard: View {
    
    @Environment(\.splitLayoutScale)
    private var layoutScale
    
    @Environment(\.splitCardWidth)
    private var responsiveCardWidth
    
    let product: Product
    let productNumber: Int

    private let cardHeight: CGFloat = 66
    private let cardCornerRadius: CGFloat = 33
    
    private var total: Double {
        product.price * Double(product.quantity)
    }
    
    private func scaled(_ value: CGFloat) -> CGFloat {
        value * layoutScale
    }
    
    var body: some View {
        VStack(spacing: scaled(5)) {
            HStack {
                Text(String(format: "%02d.", productNumber))
                    .font(Font.custom("Montserrat Alternates", size: scaled(15)) .weight(.bold))
                
                Text(product.name)
                    .font(Font.custom("Montserrat Alternates", size: scaled(15)) .weight(.medium))
                    .lineLimit(1)
                
                Spacer()
            }
            .foregroundColor(Color("textSecondary"))
            
            
            HStack {
                Text("\(product.quantity) Un.  x  \(product.price, format: CurrencyHelper.formatStyle)")
                    .font(Font.custom("Montserrat Alternates", size: scaled(14)) .weight(.medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                
                Spacer()
                
                Text(total, format: CurrencyHelper.formatStyle)
                    .font(Font.custom("Montserrat Alternates", size: scaled(16)) .weight(.bold))
                    .lineLimit(1)
            }
            .foregroundColor(Color("textSecondary"))
            
        }
        .padding(.horizontal, scaled(19))
        .frame(width: responsiveCardWidth, height: scaled(cardHeight))
        .background {
            RoundedRectangle(cornerRadius: scaled(cardCornerRadius), style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.14), radius: scaled(10), x: 0, y: scaled(6))
        }
        .contentShape(RoundedRectangle(cornerRadius: scaled(cardCornerRadius), style: .continuous))
    }
}

//#Preview {
//    MinCard()
//}


