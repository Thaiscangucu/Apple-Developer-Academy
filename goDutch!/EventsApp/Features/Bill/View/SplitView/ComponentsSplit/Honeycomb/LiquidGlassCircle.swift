//
//  LiquidGlassCircle.swift
//  CircleGlassPOC
//
//  Created by Camila Parolin on 02/09/26.
//

import SwiftUI

struct LiquidGlassCircle: View {
    
    @Environment(\.splitLayoutScale)
    private var layoutScale
    
    private let innerRadius: CGFloat = 86
    private let outerRadius: CGFloat = 135
    
    private let innerColor = Color("glassBlue")
    
    private var responsiveOuterRadius: CGFloat {
        outerRadius * layoutScale
    }
    
    private var responsiveDiameter: CGFloat {
        responsiveOuterRadius * 2
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(innerColor)
                .frame(width: responsiveDiameter, height: responsiveDiameter)
            
            externalGlass
            
        }
        .frame(width: responsiveDiameter, height: responsiveDiameter)
    }
    
    @ViewBuilder
    private var externalGlass: some View {
        if #available(iOS 26.0, *) {
            Circle()
                .fill(Color.white.opacity(0.001))
                .frame(width: responsiveDiameter, height: responsiveDiameter)
                .glassEffect(.regular.tint(Color.black.opacity(0.08)), in: Circle())
                .overlay(glassColorAdjustment)
        } else {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: responsiveDiameter, height: responsiveDiameter)
                .overlay(glassColorAdjustment)
        }
    }
    
    private var glassColorAdjustment: some View {
        Circle()
            .fill(RadialGradient(
                stops: [
                    .init(color: Color.white.opacity(0.42), location: 0),
                    .init(color: Color.white.opacity(0.24), location: 0.58),
                    .init(color: Color.white.opacity(0.46), location: 1)
                ],
                center: .center,
                startRadius: 0,
                endRadius: responsiveOuterRadius))
            .frame(width: responsiveDiameter, height: responsiveDiameter)
    }
}
