//
//  LiquidGlassRectangle.swift
//  EventsApp
//
//  Created by Camila Parolin on 03/09/26.
//

import SwiftUI

struct LiquidGlassRectangle: View {
    
    @Environment(\.splitLayoutScale)
    private var layoutScale
    
    let width: CGFloat
    let height: CGFloat
    private let cornerRadius: CGFloat = 22
    
    private let innerColor = Color("glassBlue")
    
    private var responsiveWidth: CGFloat {
        width * layoutScale
    }
    
    private var responsiveHeight: CGFloat {
        height * layoutScale
    }
    
    private var responsiveCornerRadius: CGFloat {
        cornerRadius * layoutScale
    }
    
    init(width: CGFloat = 310, height: CGFloat = 120) {
        self.width = width
        self.height = height
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: responsiveCornerRadius, style: .continuous)
                .fill(innerColor)
                .frame(width: responsiveWidth, height: responsiveHeight)
            
            externalGlass
        }
        .frame(width: responsiveWidth, height: responsiveHeight)
    }
    
    @ViewBuilder
    private var externalGlass: some View {
        if #available(iOS 26.0, *) {
            RoundedRectangle(cornerRadius: responsiveCornerRadius, style: .continuous)
                .fill(Color.white.opacity(0.001))
                .frame(width: responsiveWidth, height: responsiveHeight)
                .glassEffect(.regular.tint(Color.black.opacity(0.08)), in: RoundedRectangle(cornerRadius: responsiveCornerRadius, style: .continuous))
                .overlay(glassColorAdjustment)
        } else {
            RoundedRectangle(cornerRadius: responsiveCornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(width: responsiveWidth, height: responsiveHeight)
                .overlay(glassColorAdjustment)
        }
    }
    
    private var glassColorAdjustment: some View {
        RoundedRectangle(cornerRadius: responsiveCornerRadius, style: .continuous)
            .fill(LinearGradient(stops: [.init(color: Color.white.opacity(0.42), location: 0), .init(color: Color.white.opacity(0.24), location: 0.55), .init(color: Color.white.opacity(0.46), location: 1)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .allowsHitTesting(false)
    }
}

#Preview {
    
    ZStack {
        RoundedRectangle(cornerRadius: 16)
        
        LiquidGlassRectangle()
    }
}
