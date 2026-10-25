//
//  MyCardStore.swift
//  EventsApp
//
//  Created by Thais Cangucu on 24/09/26.
//

import SwiftUI
import UIKit

/// Salva e carrega o "Meu Card" (o card do próprio usuário do app) no
/// UserDefaults. Fica separado dos `SavedUser` para não aparecer na
/// lista de participantes antigos.
enum MyCardStore {
    private static let key = "myCard"

    /// Versão Codable do card (Color não é Codable, então guardamos RGBA).
    private struct StoredCard: Codable {
        var id: UUID
        var name: String
        var emoji: String
        var red: Double
        var green: Double
        var blue: Double
        var opacity: Double
    }

    static func load() -> User? {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let stored = try? JSONDecoder().decode(StoredCard.self, from: data)
        else { return nil }

        return User(
            id: stored.id,
            name: stored.name,
            emoji: stored.emoji,
            color: Color(red: stored.red, green: stored.green, blue: stored.blue, opacity: stored.opacity)
        )
    }

    static func save(_ user: User) {
        var red: CGFloat = 0.5, green: CGFloat = 0.5, blue: CGFloat = 0.5, alpha: CGFloat = 1
        UIColor(user.color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let stored = StoredCard(
            id: user.id,
            name: user.name,
            emoji: user.emoji,
            red: Double(red),
            green: Double(green),
            blue: Double(blue),
            opacity: Double(alpha)
        )

        if let data = try? JSONEncoder().encode(stored) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func delete() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
