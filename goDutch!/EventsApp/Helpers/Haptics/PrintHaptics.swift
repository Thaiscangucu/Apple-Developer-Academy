//
//  PrintHaptics.swift
//  EventsApp
//

import CoreHaptics

/// Vibração contínua de "impressora" para animações de nota descendo.
///
/// A intensidade segue a VELOCIDADE da curva de animação (bezier): forte onde
/// a nota anda rápido, fraca onde ela anda devagar. No fim, uma batida curta
/// marca que a nota parou. Só toca se "Animações & haptics" estiver ligado
/// nos Ajustes e se o aparelho tiver suporte a Core Haptics.
final class PrintHaptics {

    /// Curva de bezier da animação (mesmos valores de `.timingCurve`).
    struct Curve {
        let p1x, p1y, p2x, p2y: Double

        /// Curva do `.easeInOut` do SwiftUI.
        static let easeInOut = Curve(p1x: 0.42, p1y: 0, p2x: 0.58, p2y: 1)
    }

    // MARK: Sensação padrão (compartilhada com o arrasto do cartão)
    /// Força máxima da vibração contínua.
    static let defaultIntensity: Float = 0.45
    /// "Timbre": 0 = grave/abafado, 1 = seco/agudo.
    static let defaultSharpness: Float = 0.35
    /// Força da batida final.
    static let defaultFinishIntensity: Float = 0.45

    // MARK: Ajustes de sensação
    /// Intensidade quando a nota está parada / no ponto mais rápido.
    var minIntensity: Float = 0.04
    var maxIntensity: Float = PrintHaptics.defaultIntensity
    /// "Timbre": 0 = grave/abafado, 1 = seco/agudo.
    var sharpness: Float = PrintHaptics.defaultSharpness
    /// Batida final quando a nota para (0 desliga).
    var finishIntensity: Float = PrintHaptics.defaultFinishIntensity

    private var engine: CHHapticEngine?
    private var player: CHHapticPatternPlayer?

    /// Toca a vibração. `delay` e `duration` devem ser os mesmos da animação.
    func play(delay: TimeInterval = 0, duration: TimeInterval, curve: Curve = .easeInOut) {
        guard
            AppSettings.isAnimationsOn,
            CHHapticEngine.capabilitiesForHardware().supportsHaptics
        else { return }

        stop()

        do {
            let engine = try CHHapticEngine()
            engine.playsHapticsOnly = true
            engine.isAutoShutdownEnabled = true
            try engine.start()

            let player = try engine.makePlayer(with: pattern(duration: duration, curve: curve))
            try player.start(atTime: engine.currentTime + max(delay, 0))

            self.engine = engine
            self.player = player
        } catch {
            print("[Haptics] Não foi possível tocar: \(error)")
        }
    }

    /// Interrompe a vibração (ex.: a tela saiu antes da animação terminar).
    func stop() {
        try? player?.stop(atTime: CHHapticTimeImmediate)
        engine?.stop(completionHandler: nil)
        player = nil
        engine = nil
    }

    deinit {
        stop()
    }

    // MARK: Padrão

    private func pattern(duration: TimeInterval, curve: Curve) throws -> CHHapticPattern {
        let continuous = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0,
            duration: duration
        )

        // Velocidade da animação em alguns pontos (máx. 16 por curva).
        let samples = 14
        let dt = 0.01
        let speeds: [Double] = (0..<samples).map { i in
            let x = min(Double(i) / Double(samples - 1), 1 - dt)
            let a = Self.bezier(x, curve)
            let b = Self.bezier(x + dt, curve)
            return max(b - a, 0) / dt
        }
        let maxSpeed = max(speeds.max() ?? 1, 0.0001)

        let range = maxIntensity - minIntensity
        let points = speeds.enumerated().map { i, speed in
            CHHapticParameterCurve.ControlPoint(
                relativeTime: duration * Double(i) / Double(samples - 1),
                value: minIntensity + range * Float(speed / maxSpeed)
            )
        }
        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: points,
            relativeTime: 0
        )

        var events = [continuous]
        if finishIntensity > 0 {
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: finishIntensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: duration
            ))
        }

        return try CHHapticPattern(events: events, parameterCurves: [intensityCurve])
    }

    /// Progresso (0...1) da curva de bezier no tempo `x` (0...1).
    private static func bezier(_ x: Double, _ c: Curve) -> Double {
        func bx(_ t: Double) -> Double { let u = 1 - t; return 3*u*u*t*c.p1x + 3*u*t*t*c.p2x + t*t*t }
        func by(_ t: Double) -> Double { let u = 1 - t; return 3*u*u*t*c.p1y + 3*u*t*t*c.p2y + t*t*t }
        var lo = 0.0, hi = 1.0, t = 0.5
        for _ in 0..<24 {
            if bx(t) < x { lo = t } else { hi = t }
            t = (lo + hi) / 2
        }
        return by(t)
    }
}
