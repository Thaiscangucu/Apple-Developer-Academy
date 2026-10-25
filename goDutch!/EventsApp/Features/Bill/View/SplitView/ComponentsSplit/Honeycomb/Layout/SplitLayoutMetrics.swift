//
//  SplitLayoutMetrics.swift
//  EventsApp
//
//  Created by Camila Parolin on 11/09/26.
//

import SwiftUI

struct SplitLayoutMetrics {
    static let referenceWidth: CGFloat = 393
    static let referenceCardWidth: CGFloat = 348
    static let minimumScale: CGFloat = 0.78
    static let minimumHorizontalMargin: CGFloat = 16
    
    let scale: CGFloat
    let cardWidth: CGFloat

    init(containerSize: CGSize) {
        let proportionalScale = containerSize.width / Self.referenceWidth
        scale = min(max(proportionalScale, Self.minimumScale), 1)
        
        let cardScale: CGFloat
        
        if containerSize.width > Self.referenceWidth {
            cardScale = proportionalScale
        } else {
            cardScale = scale
        }
        
        let proportionalCardWidth = Self.referenceCardWidth * cardScale
        
        let maximumCardWidth = containerSize.width - (Self.minimumHorizontalMargin * 2)
        
        cardWidth = max(0, min(proportionalCardWidth, maximumCardWidth))
    }
    
    func scaled(_ value: CGFloat) -> CGFloat {
        value * scale
    }
}

private struct SplitLayoutScaleKey: EnvironmentKey {
    static let defaultValue: CGFloat = 1
}

private struct SplitCardWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 348
}

extension EnvironmentValues {
    var splitLayoutScale: CGFloat {
        get { self[SplitLayoutScaleKey.self] }
        set { self[SplitLayoutScaleKey.self] = newValue }
    }
    
    var splitCardWidth: CGFloat {
        get { self[SplitCardWidthKey.self] }
        set { self[SplitCardWidthKey.self] = newValue }
    }
}
