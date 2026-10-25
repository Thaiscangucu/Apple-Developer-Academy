//
//  LargeTextAvatar.swift
//  EventsApp
//
//  Bolinha de emoji + cor usada nas versões em lista das telas
//  (tamanhos de texto de acessibilidade). Cresce junto com o texto,
//  mas com um teto para não engolir a linha.
//

import SwiftUI

struct LargeTextAvatar: View {
    let user: User

    @ScaledMetric(relativeTo: .body) private var scaledDiameter: CGFloat = 36

    private var diameter: CGFloat { min(scaledDiameter, 72) }

    var body: some View {
        Text(user.emoji)
            .font(.system(size: diameter * 0.5))
            .frame(width: diameter, height: diameter)
            .background(user.color, in: Circle())
            // Decorativo: o nome da pessoa já é lido ao lado.
            .accessibilityHidden(true)
    }
}
