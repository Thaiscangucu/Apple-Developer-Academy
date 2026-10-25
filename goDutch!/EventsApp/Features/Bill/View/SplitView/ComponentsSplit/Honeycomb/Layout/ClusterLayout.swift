//
//  ClusterLayout.swift
//  EventsApp
//
//  Created by Camila Parolin on 31/08/26.
//

import SwiftUI

//ainda preciso entender direito esse arquivo, não ficou exatamente claro

//adapta os padrões CirclePatternLayout para os círculos exibidos dentro dos cards SwiftUI
enum ClusterLayout {
    static let circleSize: CGFloat = 50
    static let horizontalSpacing: CGFloat = 58
    static let verticalSpacing: CGFloat = 66

    static let verticalPadding: CGFloat = 16
    static let scrollGap: CGFloat = 16

    static func offsets(for count: Int, scale: CGFloat = 1) -> [CGSize] {
        CirclePatternLayout.positions(
            for: count,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing
        )
        .map { point in
            CGSize(width: point.x * scale, height: -point.y * scale)
        }
    }

    static func offset(
        for index: Int,
        count: Int,
        scale: CGFloat = 1
    ) -> CGSize {
        let patternOffsets = offsets(for: count, scale: scale)
        guard patternOffsets.indices.contains(index) else { return .zero }
        return patternOffsets[index]
    }

    static var clusterHeight: CGFloat {
        let positions = CirclePatternLayout.positions(
            for: CirclePatternLayout.maximumCount,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing
        )
        let maxAbsY = positions.map { abs($0.y) }.max() ?? 0
        return (maxAbsY * 2) + circleSize + (verticalPadding * 2)
    }

    static var clusterWidth: CGFloat {
        let positions = CirclePatternLayout.positions(
            for: CirclePatternLayout.maximumCount,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing
        )
        let maxAbsX = positions.map { abs($0.x) }.max() ?? 0
        return (maxAbsX * 2) + circleSize
    }
    
    static func centerIndex(for count: Int) -> Int? {
        guard count > 0 else {
            return nil
        }
        
        let layoutOffsets = offsets(for: count)
        
        return layoutOffsets.indices.min { firstIndex, secondIndex in
            let firstOffset = layoutOffsets[firstIndex]
            let secondOffset = layoutOffsets[secondIndex]
            
            let firstDistance = hypot(firstOffset.width, firstOffset.height)
            let secondDistance = hypot(secondOffset.width, secondOffset.height)
            
            return firstDistance < secondDistance
        }
    }
}
