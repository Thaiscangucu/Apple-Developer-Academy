//
//  AppSettings.swift
//  EventsApp
//

import Foundation

/// Chaves das preferências globais do app (salvas no UserDefaults).
/// Use com @AppStorage em qualquer View, por exemplo:
/// `@AppStorage(AppSettings.animationsOn) private var animationsOn = true`
enum AppSettings {
    /// Liga/desliga animações & haptics no app todo.
    static let animationsOn = "animationsOn"
    
    /// Valor atual de `animationsOn` para código fora de Views
    /// (SpriteKit, controllers de haptics etc.). Padrão: `true`.
    static var isAnimationsOn: Bool {
        UserDefaults.standard.object(forKey: animationsOn) as? Bool ?? true
    }
}
