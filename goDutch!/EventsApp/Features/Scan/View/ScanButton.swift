//
//  ScanButton.swift
//  EventsApp
//
//  Created by Thais Cangucu on 15/09/26.
//

import SwiftUI

struct ScanButton: View {
    @Binding var isExpanded: Bool
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(.accentSlateLight)
                .cornerRadius(70)
                .shadow(color: Color("shadowSoft").opacity(0.25), radius: 2, x: 0, y: -1)
                .shadow(color: Color("shadowSoft").opacity(0.25), radius: 2, x: 0, y: 3)
                .frame(width: isExpanded ? 72 : 138, height: isExpanded ? 72 : 138)
                .adaptiveGlass(clear: true, in: .circle)
                // Contorno com texto grande.
                .largeTextStroke(diameter: isExpanded ? 72 : 138)
            Image(systemName: CompatSymbol.documentViewfinderFill)
                .resizable()
                .scaledToFit()
                .frame(width: isExpanded ? 35 : 60)
                .fontWeight(.semibold)
                .tint(.accentSlate)
            
        }
    }
}
