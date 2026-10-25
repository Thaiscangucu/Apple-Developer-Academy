//
//  CirclePatternLayout.swift
//  EventsApp
//
//  Created by Camila Parolin on 31/08/26.
//

import CoreGraphics

//aqui temos todos os padrões de posicionamentos dos círculos
enum CirclePatternLayout {
    //aqui limita a 12 elementos
    static let maximumCount = 12

    //possui um desenho específico para cada quantidade
    private static func normalizedPositions(for count: Int) -> [CGPoint] {
        switch count {
        case 1:
            return [CGPoint(x: 0, y: 0)]

        case 2:
            return [
                CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0)
            ]

        case 3:
            return [
                CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0),
                CGPoint(x: 2, y: 0)
            ]

        case 4:
            return [
                CGPoint(x: 0.5, y: 1),
                CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0),
                CGPoint(x: 2, y: 0)
            ]

        case 5:
            return [
                CGPoint(x: 0.5, y: 1),
                CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0),
                CGPoint(x: 2, y: 0),
                CGPoint(x: 1.5, y: -1)
            ]

        case 6:
            return [
                CGPoint(x: 0.5, y: 1), CGPoint(x: 1.5, y: 1),
                CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0),
                CGPoint(x: 2, y: 0),
                CGPoint(x: 1.5, y: -1)
            ]

        case 7:
            return [
                CGPoint(x: 0.5, y: 1), CGPoint(x: 1.5, y: 1),
                CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0),
                CGPoint(x: 2, y: 0),
                CGPoint(x: 0.5, y: -1), CGPoint(x: 1.5, y: -1)
            ]

        case 8:
            return [
                CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1),
                CGPoint(x: 2, y: 1),
                CGPoint(x: 0.5, y: 0), CGPoint(x: 1.5, y: 0),
                CGPoint(x: 2.5, y: 0),
                CGPoint(x: 1, y: -1), CGPoint(x: 2, y: -1)
            ]

        case 9:
            return [
                CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1),
                CGPoint(x: 2, y: 1),
                CGPoint(x: 0.5, y: 0), CGPoint(x: 1.5, y: 0),
                CGPoint(x: 2.5, y: 0),
                CGPoint(x: 1, y: -1), CGPoint(x: 2, y: -1),
                CGPoint(x: 3, y: -1)
            ]

        case 10:
            return [
                CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1),
                CGPoint(x: 2, y: 1),
                CGPoint(x: 0.5, y: 0), CGPoint(x: 1.5, y: 0),
                CGPoint(x: 2.5, y: 0),
                CGPoint(x: 0, y: -1), CGPoint(x: 1, y: -1),
                CGPoint(x: 2, y: -1), CGPoint(x: 3, y: -1)
            ]

        case 11:
            return [
                CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1),
                CGPoint(x: 2, y: 1), CGPoint(x: 3, y: 1),
                CGPoint(x: 0.5, y: 0), CGPoint(x: 1.5, y: 0),
                CGPoint(x: 2.5, y: 0),
                CGPoint(x: 0, y: -1), CGPoint(x: 1, y: -1),
                CGPoint(x: 2, y: -1), CGPoint(x: 3, y: -1)
            ]

        case 12:
            return [
                CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1),
                CGPoint(x: 2, y: 1), CGPoint(x: 3, y: 1),
                CGPoint(x: 0.5, y: 0), CGPoint(x: 1.5, y: 0),
                CGPoint(x: 2.5, y: 0), CGPoint(x: 3.5, y: 0),
                CGPoint(x: 0, y: -1), CGPoint(x: 1, y: -1),
                CGPoint(x: 2, y: -1), CGPoint(x: 3, y: -1)
            ]

        default:
            return []
        }
    }
    
    //recebe a quantidade de círculos e os espaçamentos desejados para cada caso. Em seguida, redimensiona as posições e centraliza todo o conjunto em torno do ponto zero
    static func positions(
        for count: Int,
        horizontalSpacing: CGFloat,
        verticalSpacing: CGFloat
    ) -> [CGPoint] {
        let safeCount = min(max(count, 0), maximumCount)
        let normalized = normalizedPositions(for: safeCount)
        guard !normalized.isEmpty else { return [] }

        let scaled = normalized.map { point in
            CGPoint(x: point.x * horizontalSpacing, y: point.y * verticalSpacing)
        }

        let minX = scaled.map(\.x).min() ?? 0
        let maxX = scaled.map(\.x).max() ?? 0
        let minY = scaled.map(\.y).min() ?? 0
        let maxY = scaled.map(\.y).max() ?? 0
        let center = CGPoint(x: (minX + maxX) / 2, y: (minY + maxY) / 2)

        return scaled.map { point in
            CGPoint(x: point.x - center.x, y: point.y - center.y)
        }
    }
}
