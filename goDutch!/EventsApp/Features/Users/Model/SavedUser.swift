import Foundation
import SwiftData
import SwiftUI
import UIKit

/// Modelo persistido pelo SwiftData para armazenar os participantes
/// que já foram adicionados anteriormente pelo usuário.
@Model
final class SavedUser {
    var id: UUID
    var name: String
    var emoji: String
    var colorRed: Double
    var colorGreen: Double
    var colorBlue: Double
    var colorOpacity: Double

    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        color: Color
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji

        let uiColor = UIColor(color)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 1

        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            self.colorRed = Double(red)
            self.colorGreen = Double(green)
            self.colorBlue = Double(blue)
            self.colorOpacity = Double(alpha)
        } else {
            self.colorRed = 0.5
            self.colorGreen = 0.5
            self.colorBlue = 0.5
            self.colorOpacity = 1
        }
    }

    var color: Color {
        Color(
            red: colorRed,
            green: colorGreen,
            blue: colorBlue,
            opacity: colorOpacity
        )
    }
}
