import SwiftUI

// MARK: - Tela de carregamento 1
// Porte 1:1 do carregamento1.html.
// A tela é montada num canvas fixo de 393×852 (as mesmas coordenadas do protótipo)
// e escalada para caber na tela (máx. 1.4×), igual à função fit() do HTML.
// Requer iOS 17+ (UnevenRoundedRectangle / #Preview).

struct ScanLoadingView: View {
    /// Progresso real do processamento (0...1), vindo da ScanViewModel.
    /// A notinha desce conforme ele avança, então a tela dura o mesmo
    /// tempo que a leitura + IA levarem.
    var progress: Double = 0

    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Quanto da notinha já saiu da fenda (0...1), animado.
    @State private var paperProgress: Double = 0
    @State private var start = Date()

    private let W: CGFloat = 393
    private let H: CGFloat = 852

    // MARK: Ritmo da notinha
    /// Tempo para a notinha alcançar o progresso de cada etapa concluída.
    private static let catchUpDuration: Double = 0.6
    /// Enquanto espera a próxima etapa (ex.: a IA pensando), a notinha
    /// continua andando devagar até no máximo `creepAmount` à frente,
    /// para nunca parecer travada.
    private static let creepAmount: Double = 0.12
    private static let creepDuration: Double = 6
    /// Até onde ela pode chegar antes do processamento terminar de verdade.
    private static let maxBeforeDone: Double = 0.96
    /// Tempo para terminar de sair quando o processamento acaba.
    static let finishDuration: Double = 0.45

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
        .onAppear {
            // Um pouquinho de papel já sai logo de cara, para mostrar que começou.
            advancePaper(to: max(progress, 0.06))
        }
        .onChange(of: progress) { _, newValue in
            advancePaper(to: newValue)
        }
    }

    // MARK: Avanço da notinha

    /// Leva a notinha até o progresso da etapa e, se ainda não terminou,
    /// continua deslizando devagar enquanto a próxima etapa não chega.
    private func advancePaper(to target: Double) {
        let target = min(max(target, 0), 1)

        if target >= 1 {
            withAnimation(.easeOut(duration: Self.finishDuration)) {
                paperProgress = 1
            }
            return
        }

        let reached = min(target, Self.maxBeforeDone)
        withAnimation(.easeOut(duration: Self.catchUpDuration)) {
            paperProgress = max(paperProgress, reached)
        }

        // Depois de alcançar a etapa, segue "imprimindo" devagar.
        let creepTarget = min(reached + Self.creepAmount, Self.maxBeforeDone)
        withAnimation(.easeOut(duration: Self.creepDuration).delay(Self.catchUpDuration)) {
            paperProgress = max(paperProgress, creepTarget)
        }
    }

    // MARK: Stage

    private var stage: some View {
        ZStack(alignment: .topLeading) {
            // Vidro atrás da notinha
            glassOverlay
                .place(x: 20, y: 254, w: 353, h: 353)

            // Fenda + notinha na frente do vidro
            slot
                .place(x: 107, y: 313, w: 173, h: 32)

            // A notinha fica por cima da fenda e nasce no centro da abertura escura
            receipt
                .place(x: 123, y: Self.slitCenterY, w: 142, h: Self.receiptH)

            bubbles
        }
        .frame(width: W, height: H)
    }

    // MARK: Vidro (mesmos valores do painel "Vidro" do Figma)

    private enum GlassSpec {
        static let lightAngle: Double = -29        // Luz: -29°
        static let lightIntensity: Double = 0.80   // Luz: 80%
        static let refraction: Double = 0          // Refração 0 → sem distorção do que está atrás
        static let depth: CGFloat = 147.37         // Profundidade
        static let dispersion: Double = 1.0        // Dispersão 100
        static let frost: CGFloat = 0              // Gelo 0 → sem desfoque
        static let splay: Double = 0               // Splay 0
        static let fill = Color(hex: 0xD9D9D9)     // Preenchimento D9D9D9
        static let fillOpacity: Double = 0.20      //                20%
    }

    private var glassOverlay: some View {
        // O Figma mede o ângulo no sentido anti-horário e o SwiftUI no horário.
        // A luz vem do lado oposto à direção indicada (com -29° ela vem de cima/esquerda).
        let lightFrom = Angle.degrees(-GlassSpec.lightAngle + 180)
        let a = GlassSpec.lightIntensity

        // Brilho forte do lado da luz e um reflexo mais fraco no lado oposto
        let lightRim = AngularGradient(stops: [
            .init(color: .white.opacity(a), location: 0),
            .init(color: .white.opacity(0), location: 0.16),
            .init(color: .white.opacity(0), location: 0.34),
            .init(color: .white.opacity(a * 0.5), location: 0.5),
            .init(color: .white.opacity(0), location: 0.66),
            .init(color: .white.opacity(0), location: 0.84),
            .init(color: .white.opacity(a), location: 1)
        ], center: .center, startAngle: lightFrom, endAngle: lightFrom + .degrees(360))

        // Dispersão: franja de arco-íris na borda, mais forte onde a luz bate
        let rainbow = AngularGradient(colors: [
            .red, .orange, .yellow, .green, .cyan, .blue, .purple, .red
        ], center: .center, startAngle: lightFrom, endAngle: lightFrom + .degrees(360))

        let dispersionMask = AngularGradient(stops: [
            .init(color: .white, location: 0),
            .init(color: .white.opacity(0.25), location: 0.25),
            .init(color: .white.opacity(0.6), location: 0.5),
            .init(color: .white.opacity(0.25), location: 0.75),
            .init(color: .white, location: 1)
        ], center: .center, startAngle: lightFrom, endAngle: lightFrom + .degrees(360))

        // Largura da borda "funda" do vidro, proporcional à profundidade
        let band = GlassSpec.depth * 0.1

        return ZStack {
            // Preenchimento D9D9D9 20%
            Circle()
                .fill(GlassSpec.fill.opacity(GlassSpec.fillOpacity))

            // Dispersão
            Circle()
                .strokeBorder(rainbow, lineWidth: band)
                .blur(radius: band * 0.6)
                .opacity(0.22 * GlassSpec.dispersion)
                .mask(Circle().fill(dispersionMask))

            // Luz: brilho suave por dentro da borda
            Circle()
                .strokeBorder(lightRim, lineWidth: band)
                .blur(radius: band * 0.5)

            // Luz: fio de luz na borda
            Circle()
                .strokeBorder(lightRim, lineWidth: 1.5)
        }
        .clipShape(Circle())
        .allowsHitTesting(false)
    }

    // MARK: Notinha

    // Fenda: top 313 + abertura escura em top 7, altura 7 → centro em 313 + 7 + 3.5
    private static let slitCenterY: CGFloat = 313 + 7 + 3.5
    // A base da nota continua no mesmo lugar do protótipo (328 + 229 = 557)
    private static let receiptH: CGFloat = 557 - slitCenterY

    private var receipt: some View {
        ZStack(alignment: .topLeading) {
            paper
                .offset(y: -Self.receiptH * (1 - paperProgress)) // translateY(-100%) → 0
        }
        .frame(width: 142, height: Self.receiptH)
        .clipped() // recorte começa no centro da fenda
    }

    private var paper: some View {
        ZStack(alignment: .bottom) {
            UnevenRoundedRectangle(bottomLeadingRadius: 4, bottomTrailingRadius: 4)
                .fill(palette.paper)
                .shadow(color: Color(red: 80/255, green: 90/255, blue: 120/255).opacity(0.25), radius: 12, y: 8)

            // Conteúdo mantém as mesmas posições finais de antes
            paperContent
        }
        .frame(width: 142, height: Self.receiptH)
    }

    private var paperContent: some View {
        let ink = palette.ink
        return ZStack(alignment: .topLeading) {

            // .title
            RoundedRectangle(cornerRadius: 3)
                .fill(ink)
                .place(x: 14, y: 34, w: 114, h: 17)

            // .ln (linhas)
            row(mid: 84, packed: false).place(x: 14, y: 70, w: 114, h: 3)
            row(mid: 76, packed: false).place(x: 14, y: 81, w: 114, h: 3)
            row(mid: 36, packed: true).place(x: 14, y: 92, w: 114, h: 3)
            row(mid: 86, packed: false).place(x: 14, y: 103, w: 114, h: 3)
            row(mid: 64, packed: true).place(x: 14, y: 114, w: 114, h: 3)

            // .dots (border-top 1px dotted)
            Path { p in
                p.move(to: CGPoint(x: 0, y: 0.5))
                p.addLine(to: CGPoint(x: 114, y: 0.5))
            }
            .stroke(ink, style: StrokeStyle(lineWidth: 1, dash: [1, 1]))
            .place(x: 14, y: 177, w: 114, h: 1)

            // .bar (código de barras)
            Canvas { ctx, size in
                var x: CGFloat = 0
                while x < size.width {
                    ctx.fill(Path(CGRect(x: x, y: 0, width: 1, height: size.height)), with: .color(ink))
                    ctx.fill(Path(CGRect(x: x + 3, y: 0, width: 2, height: size.height)), with: .color(ink))
                    x += 6
                }
            }
            .opacity(0.8)
            .place(x: 14, y: 194, w: 114, h: 14)
        }
        .frame(width: 142, height: 229)
    }

    /// Linha da nota. `packed == false` → justify-content: space-between.
    /// `packed == true` → último item com margin-left:auto (os dois primeiros ficam juntos à esquerda).
    private func row(mid: CGFloat, packed: Bool) -> some View {
        HStack(spacing: 0) {
            lineBar(14)
            if !packed { Spacer(minLength: 0) }
            lineBar(mid)
            Spacer(minLength: 0)
            lineBar(11)
        }
    }

    private func lineBar(_ w: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 1.5)
            .fill(palette.ink)
            .frame(width: w, height: 3)
    }

    // MARK: Fenda

    private var slot: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(stops: [
                    .init(color: Color(hex: 0x8a98a3), location: 0),
                    .init(color: Color(hex: 0x6d7a85), location: 0.55),
                    .init(color: Color(hex: 0x59656f), location: 1)
                ], startPoint: .top, endPoint: .bottom))
                .shadow(color: Color(red: 40/255, green: 50/255, blue: 70/255).opacity(0.3), radius: 4, y: 3)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: 0x37424b))
                .frame(height: 7)
                .padding(.horizontal, 8)
                .padding(.top, 7)
        }
    }

    // MARK: Bolinhas

    private var bubbles: some View {
        TimelineView(.animation(paused: reduceMotion)) { tl in
            let t = tl.date.timeIntervalSince(start)
            ZStack(alignment: .topLeading) {
                ForEach(Self.bubbleData) { b in
                    Circle()
                        .fill(b.color)
                        .frame(width: b.size, height: b.size)
                        .overlay(
                            // Para usar suas imagens: troque por Image("nome").resizable().scaledToFit().frame(...)
                            Text(b.emoji).font(.system(size: b.fontSize))
                        )
                        .offset(reduceMotion ? .zero : floatOffset(b, t: t))
                        .position(x: b.x, y: b.y)
                }
            }
            .frame(width: W, height: H)
        }
    }

    /// Reproduz @keyframes float com ease-in-out, infinite alternate e delay negativo.
    private func floatOffset(_ b: Bubble, t: Double) -> CGSize {
        let elapsed = t - b.delay            // delay negativo = já começa no meio do ciclo
        let cycle = elapsed / b.duration
        let i = floor(cycle)
        var p = cycle - i
        if Int(i) % 2 != 0 { p = 1 - p }     // alternate

        let stops: [Double] = [0, 0.33, 0.66, 1]
        let xs: [Double] = [0, b.dx, -0.6 * b.dx, 0.4 * b.dx]
        let ys: [Double] = [0, -0.5 * b.dy, b.dy, -b.dy]

        var s = 0
        while s < 2 && p > stops[s + 1] { s += 1 }
        let local = (p - stops[s]) / (stops[s + 1] - stops[s])
        let e = cubicBezier(local, 0.42, 0, 0.58, 1) // ease-in-out, aplicado por trecho como no CSS

        return CGSize(width: xs[s] + (xs[s + 1] - xs[s]) * e,
                      height: ys[s] + (ys[s + 1] - ys[s]) * e)
    }

    private func cubicBezier(_ x: Double, _ p1x: Double, _ p1y: Double, _ p2x: Double, _ p2y: Double) -> Double {
        func bx(_ t: Double) -> Double { let u = 1 - t; return 3*u*u*t*p1x + 3*u*t*t*p2x + t*t*t }
        func by(_ t: Double) -> Double { let u = 1 - t; return 3*u*u*t*p1y + 3*u*t*t*p2y + t*t*t }
        var lo = 0.0, hi = 1.0, t = 0.5
        for _ in 0..<24 {
            if bx(t) < x { lo = t } else { hi = t }
            t = (lo + hi) / 2
        }
        return by(t)
    }

    private struct Bubble: Identifiable {
        let id = UUID()
        let x: CGFloat, y: CGFloat, size: CGFloat
        let color: Color
        let emoji: String, fontSize: CGFloat
        let dx: Double, dy: Double
        let duration: Double, delay: Double
    }

    // left/top = centro da bolinha (translate -50%), mesmos valores do HTML
    private static let bubbleData: [Bubble] = [
        .init(x: 244, y: 232, size: 62, color: Color(hex: 0x007aff), emoji: "🤓",   fontSize: 34, dx: 5, dy: 5, duration: 3.4, delay: -0.4),
        .init(x: 127, y: 243, size: 40, color: Color(hex: 0xffd60a), emoji: "🧑‍💻", fontSize: 22, dx: 4, dy: 5, duration: 2.9, delay: -1.2),
        .init(x: 96,  y: 278, size: 52, color: Color(hex: 0x6bf55e), emoji: "🐙",   fontSize: 28, dx: 5, dy: 4, duration: 3.7, delay: -2.0),
        .init(x: 300, y: 353, size: 48, color: Color(hex: 0xe91ec8), emoji: "🧐",   fontSize: 26, dx: 4, dy: 5, duration: 3.1, delay: -0.8),
        .init(x: 339, y: 367, size: 30, color: Color(hex: 0xff1a1a), emoji: "🌈",   fontSize: 16, dx: 3, dy: 4, duration: 2.6, delay: -1.6),
        .init(x: 314, y: 398, size: 38, color: Color(hex: 0xffae1a), emoji: "🎈",   fontSize: 20, dx: 4, dy: 4, duration: 3.5, delay: -2.4),
        .init(x: 302, y: 493, size: 29, color: Color(hex: 0x6bf50a), emoji: "😇",   fontSize: 15, dx: 3, dy: 4, duration: 2.8, delay: -0.2),
        .init(x: 100, y: 550, size: 30, color: Color(hex: 0xd0d0d0), emoji: "🧑‍⚕️", fontSize: 16, dx: 3, dy: 3, duration: 3.3, delay: -1.0),
        .init(x: 130, y: 606, size: 52, color: Color(hex: 0x1aa7f5), emoji: "😎",   fontSize: 28, dx: 5, dy: 5, duration: 3.8, delay: -1.9)
    ]

    // MARK: Cores (claro / escuro, como as variáveis CSS)

    private struct Palette { let bg1, bg2, paper, ink: Color }

    private var palette: Palette {
        scheme == .dark
        ? Palette(bg1: Color(hex: 0x0b1220), bg2: Color(hex: 0x12233d), paper: Color(hex: 0xe8e8ec), ink: Color(hex: 0xb5b5bb))
        : Palette(bg1: Color(hex: 0xffffff), bg2: Color(hex: 0xe0f0ff), paper: Color(hex: 0xf6f6f8), ink: Color(hex: 0xd4d4d8))
    }
}

// MARK: - Helpers

private extension View {
    /// Posiciona como position:absolute (left/top/width/height) dentro de um ZStack de tamanho fixo.
    func place(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) -> some View {
        frame(width: w, height: h)
            .position(x: x + w / 2, y: y + h / 2)
    }
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xff) / 255,
                  green: Double((hex >> 8) & 0xff) / 255,
                  blue: Double(hex & 0xff) / 255,
                  opacity: opacity)
    }
}

#Preview {
    ScanLoadingView()
}
