import SwiftUI

// MARK: - Tela de carregamento 2
// As bolinhas giram em órbita ao redor da esfera de vidro e entram nela uma por uma.
// Quando a última entra, a esfera dá uma leve pulsada e `onFinished` é chamado.
//
// Mesmo esquema da tela 1: canvas fixo de 393×852 escalado para caber na tela.
// Usa o `Color(hex:)` que está no Carregamento1View.swift.
// Requer iOS 17+.

struct SplitLoadingView: View {
    var onFinished: () -> Void = {}

    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date()

    private let W: CGFloat = 393
    private let H: CGFloat = 852

    // MARK: Geometria (tirada do protótipo)
    private static let center = CGPoint(x: 196.5, y: 430)
    private static let glassR: CGFloat = 98          // esfera de vidro
    private static let ringRadii: [CGFloat] = [125, 148]

    // MARK: Tempos (ajuste aqui)
    private static let firstEntry: Double = 0.5      // quando a 1ª bolinha começa a entrar
    private static let entryInterval: Double = 0.2   // intervalo entre uma e outra
    private static let entryDuration: Double = 0.5   // quanto tempo cada uma leva para entrar
    private static let finishPulse: Double = 0.4     // pulsada final da esfera
    private static let orbitSpeed: Double = 2 * .pi / 5  // uma volta a cada 22 s
    private static let innerSwirl: Double = 0.2      // giro extra (rad/s) depois que entra no vidro

    private static var endTime: Double {
        firstEntry + entryInterval * Double(bubbleData.count - 1) + entryDuration
    }

    var body: some View {
        GeometryReader { geo in
            let k = min(geo.size.width / W, geo.size.height / H, 1.4)
            stage
                .frame(width: W, height: H)
                .scaleEffect(k)
                // Centraliza o canvas escalado na tela inteira.
                .frame(width: geo.size.width, height: geo.size.height)
        }
        // O fundo preenche a tela inteira (inclusive as safe areas),
        // independente da proporção do aparelho.
        .background {
            LinearGradient(colors: [palette.bg1, palette.bg2], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .onAppear { start = Date() }
        .task {
            try? await Task.sleep(nanoseconds: UInt64((Self.endTime + Self.finishPulse) * 1_000_000_000))
            onFinished()
        }
    }

    // MARK: Stage

    private var stage: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSince(start)
            let states = Self.bubbleData.map { state(for: $0, t: t) }
            let pulse = pulseScale(t)

            ZStack(alignment: .topLeading) {
                rings

                glass(t: t, states: states)
                    .scaleEffect(pulse, anchor: UnitPoint(x: Self.center.x / W, y: Self.center.y / H))

                outsideBubbles(states, glassScale: pulse)
            }
            .frame(width: W, height: H)
        }
    }

    // MARK: Anéis

    private var rings: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Self.ringRadii, id: \.self) { r in
                Circle()
                    .stroke(Color.white.opacity(0.9), lineWidth: 3)
                    .shadow(color: Color(hex: 0xb9b2e0).opacity(0.35), radius: 6)
                    .frame(width: r * 2, height: r * 2)
                    .position(Self.center)
            }
        }
        .frame(width: W, height: H)
    }

    // MARK: Esfera de vidro

    private func glass(t: Double, states: [BubbleState]) -> some View {
        let d = Self.glassR * 2
        let c = Self.center

        return ZStack(alignment: .topLeading) {
            // Base fosca
            Circle()
                .fill(RadialGradient(stops: [
                    .init(color: .white.opacity(0.95), location: 0),
                    .init(color: Color(red: 235/255, green: 232/255, blue: 248/255).opacity(0.85), location: 0.6),
                    .init(color: Color(red: 222/255, green: 218/255, blue: 240/255).opacity(0.9), location: 1)
                ], center: .center, startRadius: 0, endRadius: Self.glassR))
                .shadow(color: Color(red: 150/255, green: 140/255, blue: 200/255).opacity(0.25), radius: 18, y: 6)
                .frame(width: d, height: d)
                .position(c)

            // Redemoinho lilás de dentro (gira devagar)
            Circle()
                .stroke(AngularGradient(colors: [
                    Color(hex: 0xd9d2f0), Color(hex: 0xc9c0ea), Color(hex: 0xe6e0f6),
                    Color(hex: 0xcfc6ee), Color(hex: 0xd9d2f0)
                ], center: .center), lineWidth: 22)
                .blur(radius: 12)
                .opacity(0.8)
                .rotationEffect(.degrees(reduceMotion ? 0 : t * 25))
                .frame(width: d * 0.55, height: d * 0.55)
                .position(c)

            // Bolinhas que já entraram: borradas, sem emoji, girando dentro do vidro
            insideBlobs(states)

            // Borda iridescente
            Circle()
                .strokeBorder(AngularGradient(colors: [
                    Color(hex: 0xffd1f0), Color(hex: 0xc8e6ff), Color(hex: 0xd6ffe8),
                    Color(hex: 0xfff3c4), Color(hex: 0xe2d4ff), Color(hex: 0xffd1f0)
                ], center: .center), lineWidth: 10)
                .blur(radius: 6)
                .opacity(0.55)
                .frame(width: d, height: d)
                .clipShape(Circle())
                .position(c)

            // Brilho interno da borda (inset glow)
            Circle()
                .stroke(Color.white.opacity(0.9), lineWidth: 8)
                .blur(radius: 6)
                .frame(width: d, height: d)
                .clipShape(Circle())
                .position(c)

            // Reflexo de luz
            Ellipse()
                .fill(Color.white.opacity(0.7))
                .frame(width: 70, height: 36)
                .rotationEffect(.degrees(-30))
                .blur(radius: 10)
                .position(x: c.x - 35, y: c.y - 48)
        }
        .frame(width: W, height: H)
    }

    private func insideBlobs(_ states: [BubbleState]) -> some View {
        let d = Self.glassR * 2
        return ZStack(alignment: .topLeading) {
            ForEach(states.filter { $0.p > 0 }) { s in
                Circle()
                    .fill(s.b.color)
                    .frame(width: s.b.size, height: s.b.size)
                    .overlay(Text(s.b.emoji).font(.system(size: s.b.fontSize)).opacity(1 - s.p))
                    .scaleEffect(1.08) // leve "refração" na borda
                    .position(s.pos)
            }
        }
        .frame(width: W, height: H)
        .blur(radius: 7)
        .opacity(0.85)
        .mask(
            Circle()
                .frame(width: d, height: d)
                .position(Self.center)
        )
    }

    // MARK: Bolinhas do lado de fora

    private func outsideBubbles(_ states: [BubbleState], glassScale: CGFloat) -> some View {
        let d = Self.glassR * 2 * glassScale
        return ZStack(alignment: .topLeading) {
            ForEach(states.filter { $0.p < 1 }) { s in
                Circle()
                    .fill(s.b.color)
                    .frame(width: s.b.size, height: s.b.size)
                    .overlay(
                        // Para usar suas imagens: troque por Image("nome").resizable().scaledToFit().frame(...)
                        Text(s.b.emoji).font(.system(size: s.b.fontSize))
                    )
                    .position(s.pos)
            }
        }
        .frame(width: W, height: H)
        // Tudo que estiver em cima da esfera some daqui (e aparece borrado dentro do vidro)
        .mask(
            Rectangle()
                .overlay(
                    Circle()
                        .frame(width: d, height: d)
                        .position(Self.center)
                        .blendMode(.destinationOut)
                )
                .compositingGroup()
        )
    }

    // MARK: Movimento

    private struct BubbleState: Identifiable {
        let b: Bubble
        let pos: CGPoint
        let p: Double            // 0 = fora, 1 = totalmente dentro
        var id: Int { b.order }
    }

    private func state(for b: Bubble, t: Double) -> BubbleState {
        let ts = Self.firstEntry + Self.entryInterval * Double(b.order)
        let x = min(max((t - ts) / Self.entryDuration, 0), 1)
        let p = x * x * (3 - 2 * x) // smoothstep

        let spin = reduceMotion ? 0 : Self.orbitSpeed * t
        let swirl = reduceMotion ? 0 : Self.innerSwirl * smoothIntegral(t - ts, Self.entryDuration)
        let angle = b.angle0 + spin + swirl

        // balanço sutil no raio enquanto está fora
        let wobble = reduceMotion ? 0 : 3 * sin(t * 1.3 + b.phase) * (1 - p)
        let r = b.r0 + (b.rInside - b.r0) * p + wobble

        let pos = CGPoint(x: Self.center.x + CGFloat(cos(angle) * r),
                          y: Self.center.y + CGFloat(sin(angle) * r))
        return BubbleState(b: b, pos: pos, p: p)
    }

    /// Integral do smoothstep: faz o giro extra acelerar suavemente, sem tranco.
    private func smoothIntegral(_ tau: Double, _ D: Double) -> Double {
        guard tau > 0 else { return 0 }
        let x = tau / D
        if x < 1 { return D * (x * x * x - x * x * x * x / 2) }
        return D * 0.5 + (tau - D)
    }

    private func pulseScale(_ t: Double) -> CGFloat {
        let x = (t - Self.endTime) / Self.finishPulse
        guard x > 0, x < 1 else { return 1 }
        return 1 + 0.05 * CGFloat(sin(.pi * x))
    }

    // MARK: Dados das bolinhas

    private struct Bubble {
        let x: CGFloat, y: CGFloat      // posição inicial (centro), do protótipo
        let size: CGFloat
        let color: Color
        let emoji: String, fontSize: CGFloat
        let order: Int                  // ordem de entrada
        let rInside: Double             // raio da órbita dentro do vidro
        let phase: Double

        var angle0: Double { atan2(Double(y - SplitLoadingView.center.y), Double(x - SplitLoadingView.center.x)) }
        var r0: Double { hypot(Double(x - SplitLoadingView.center.x), Double(y - SplitLoadingView.center.y)) }
    }

    // Ordem: começa pela 🤓 e segue no sentido horário
    private static let bubbleData: [Bubble] = [
        .init(x: 255, y: 303, size: 62, color: Color(hex: 0x007aff), emoji: "🤓",   fontSize: 34, order: 0, rInside: 30, phase: 0.0),
        .init(x: 300, y: 353, size: 48, color: Color(hex: 0xe91ec8), emoji: "🧐",   fontSize: 26, order: 1, rInside: 45, phase: 1.1),
        .init(x: 339, y: 367, size: 30, color: Color(hex: 0xff1a1a), emoji: "🌈",   fontSize: 16, order: 2, rInside: 58, phase: 2.3),
        .init(x: 314, y: 398, size: 38, color: Color(hex: 0xffae1a), emoji: "🎈",   fontSize: 20, order: 3, rInside: 40, phase: 3.0),
        .init(x: 302, y: 493, size: 29, color: Color(hex: 0x6bf50a), emoji: "😇",   fontSize: 15, order: 4, rInside: 60, phase: 4.2),
        .init(x: 131, y: 541, size: 52, color: Color(hex: 0x1aa7f5), emoji: "😎",   fontSize: 28, order: 5, rInside: 35, phase: 5.1),
        .init(x: 105, y: 503, size: 30, color: Color(hex: 0xd0d0d0), emoji: "🧑‍⚕️", fontSize: 16, order: 6, rInside: 52, phase: 0.7),
        .init(x: 90,  y: 329, size: 52, color: Color(hex: 0x6bf55e), emoji: "🐙",   fontSize: 28, order: 7, rInside: 42, phase: 1.9),
        .init(x: 121, y: 294, size: 40, color: Color(hex: 0xffd60a), emoji: "🧑‍💻", fontSize: 22, order: 8, rInside: 22, phase: 2.8)
    ]

    // MARK: Cores (claro / escuro, iguais à tela 1)

    private struct Palette { let bg1, bg2: Color }

    private var palette: Palette {
        scheme == .dark
        ? Palette(bg1: Color(hex: 0x0b1220), bg2: Color(hex: 0x12233d))
        : Palette(bg1: Color(hex: 0xffffff), bg2: Color(hex: 0xe0f0ff))
    }
}

#Preview {
    SplitLoadingView { print("carregamento concluído") }
}
