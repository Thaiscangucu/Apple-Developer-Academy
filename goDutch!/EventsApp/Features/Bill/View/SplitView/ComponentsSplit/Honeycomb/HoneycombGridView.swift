import SwiftUI
import SpriteKit

/// Define como o VoiceOver descreve e aciona os círculos do honeycomb.
enum HoneycombAccessibilityRole {
    /// Tela de participantes: tocar remove da conta; segurar edita.
    case billParticipants
    /// Tela de divisão: tocar coloca a pessoa no item aberto.
    case itemAssignment
    /// Card aberto: tocar tira a pessoa do item; segurar tira todas.
    case itemMembers
}

// Ponte entre SwiftUI e SpriteKit responsável por exibir e controlar o Honeycomb.
struct HoneycombGridView<Background: View>: View {
    
    @Environment(\.splitLayoutScale)
    private var layoutScale
    
    let users: [User]
    let assignedUserIDs: Set<User.ID>
    let onTapSelect: (HoneycombSelection) -> Bool
    let onLongPressSelectAll: (([User.ID]) -> Void)?
    let onLongPressUser: ((User.ID) -> Void)?
    let voiceOverRole: HoneycombAccessibilityRole
    let background: Background

    @State private var scene: HoneycombGridScene
    
    private static func configuredScene(_ existingScene: HoneycombGridScene?) -> HoneycombGridScene {
        let scene = existingScene ?? HoneycombGridScene()
        
        scene.scaleMode = .resizeFill
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.backgroundColor = .clear
        
        return scene
    }

    init(
        users: [User],
        assignedUserIDs: Set<User.ID>,
        scene: HoneycombGridScene? = nil,
        onTapSelect: @escaping (HoneycombSelection) -> Bool,
        onLongPressSelectAll: (([User.ID]) -> Void)? = nil,
        onLongPressUser: ((User.ID) -> Void)? = nil,
        voiceOverRole: HoneycombAccessibilityRole = .itemAssignment,
        @ViewBuilder background: () -> Background
    ) {
        
        _scene = State(initialValue: Self.configuredScene(scene))
        
        self.users = users
        self.assignedUserIDs = assignedUserIDs
        self.onTapSelect = onTapSelect
        self.onLongPressSelectAll = onLongPressSelectAll
        self.onLongPressUser = onLongPressUser
        self.voiceOverRole = voiceOverRole
        self.background = background()
    }
    
    init(
        users: [User],
        assignedUserIDs: Set<User.ID>,
        scene: HoneycombGridScene? = nil,
        onTapSelect: @escaping (User.ID) -> Void,
        onLongPressSelectAll: (([User.ID]) -> Void)? = nil,
        onLongPressUser: ((User.ID) -> Void)? = nil,
        voiceOverRole: HoneycombAccessibilityRole = .itemAssignment,
        @ViewBuilder background: () -> Background
    ) {
        
        _scene = State(initialValue: Self.configuredScene(scene))
        
        self.users = users
        self.assignedUserIDs = assignedUserIDs
        self.onTapSelect = { selection in
            onTapSelect(selection.userID)
            return false
        }
        self.onLongPressSelectAll = onLongPressSelectAll
        self.onLongPressUser = onLongPressUser
        self.voiceOverRole = voiceOverRole
        self.background = background()
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fundo escolhido pela View que utiliza o componente.
                background

                // A cena SpriteKit ocupa exatamente o mesmo espaço do fundo.
                TransparentSpriteView(scene: scene)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipShape(Circle())
                    .contentShape(Circle())
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            // O VoiceOver não enxerga os nós do SpriteKit. Para ele, o
            // honeycomb vira uma lista de botões (um por pessoa), com as
            // mesmas ações do toque e do toque longo.
            .accessibilityRepresentation {
                accessibleUserList(in: geometry.size)
            }
            .onAppear {
                configureScene()
            }
            .onChange(of: users) {
                configureScene()
            }
            .onChange(of: assignedUserIDs) {
                configureScene()
            }
            .onChange(of: layoutScale) {
                configureScene()
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - Acessibilidade (VoiceOver)

    /// Pessoas que aparecem como círculos no honeycomb (as que ainda não
    /// estão no item), na mesma ordem e limite usados pela cena.
    private var accessibleUsers: [User] {
        Array(
            users
                .filter { !assignedUserIDs.contains($0.id) }
                .prefix(CirclePatternLayout.maximumCount)
        )
    }

    private func accessibleUserList(in size: CGSize) -> some View {
        VStack {
            if accessibleUsers.isEmpty {
                if voiceOverRole == .billParticipants {
                    Text("Nenhum participante adicionado ainda")
                } else {
                    Text("Todas as pessoas já estão neste item")
                }
            }

            ForEach(accessibleUsers) { user in
                accessibleUserButton(user, in: size)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            voiceOverRole == .billParticipants
                ? Text("Participantes da conta")
                : Text("Pessoas disponíveis")
        )
    }

    private func accessibleUserButton(_ user: User, in size: CGSize) -> some View {
        Button {
            selectForAccessibility(user, in: size)
        } label: {
            Text(user.accessibilityName)
        }
        .accessibilityHint(
            voiceOverRole == .billParticipants
                ? Text("Toque duas vezes para remover da conta.")
                : Text("Toque duas vezes para colocar esta pessoa no item.")
        )
        .accessibilityActions {
            if voiceOverRole == .billParticipants, let onLongPressUser {
                Button("Editar participante") {
                    onLongPressUser(user.id)
                }
            }

            if voiceOverRole == .itemAssignment, let onLongPressSelectAll {
                Button("Adicionar todas as pessoas ao item") {
                    onLongPressSelectAll(accessibleUsers.map(\.id))
                    AccessibilityAnnouncer.announce(
                        String(localized: "Todas as pessoas estão neste item")
                    )
                }
            }
        }
    }

    /// Faz o mesmo que tocar no círculo da pessoa.
    private func selectForAccessibility(_ user: User, in size: CGSize) {
        let didSelect: Bool

        if let result = scene.accessibilitySelect(userID: user.id) {
            didSelect = result
        } else {
            // Círculo fora da cena (ex.: ainda sendo montado): usa o
            // centro do honeycomb como ponto de partida da animação.
            didSelect = onTapSelect(
                HoneycombSelection(
                    userID: user.id,
                    centerInHoneycomb: CGPoint(x: size.width / 2, y: size.height / 2),
                    diameter: 80 * layoutScale
                )
            )
        }

        guard didSelect else { return }

        switch voiceOverRole {
        case .billParticipants:
            AccessibilityAnnouncer.announce(String(localized: "\(user.name) saiu da conta"))
        case .itemAssignment:
            AccessibilityAnnouncer.announce(String(localized: "\(user.name) está neste item"))
        case .itemMembers:
            AccessibilityAnnouncer.announce(String(localized: "\(user.name) saiu do item"))
        }
    }

    // Envia para a cena os usuários disponíveis e os usuários já selecionados.
    private func configureScene() {
        scene.layoutScale = layoutScale
        scene.onTapSelect = onTapSelect
        scene.onLongPressSelectAll = onLongPressSelectAll
        scene.onLongPressUser = onLongPressUser
        
        scene.applyDataSnapshot(users: users, assignedUserIDs: assignedUserIDs)
    }
}

