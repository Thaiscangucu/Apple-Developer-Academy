//
//  UserPhysicsClusterView.swift
//  EventsApp
//
//  Created by Camila Parolin on 29/09/26.
//

import SwiftUI
import SpriteKit

struct SplitPhysicsClusterView<Background: View>: View {
    
    let users: [User]
    let centeredUserID: User.ID?
    let hiddenUserIDs: Set<User.ID>
    let mode: UserPhysicsClusterMode
    let circleRadius: CGFloat
    let scene: UserPhysicsClusterScene
    
    let onTapSelect: (PhysicsUserSelection) -> Bool
    let onLongPressUsers: (([User.ID]) -> Void)?
    let onLongPressUser: ((User.ID) -> Void)?
    /// O que tocar/segurar significa para o VoiceOver nesta tela.
    let voiceOverRole: HoneycombAccessibilityRole
    let onTapBackground: (() -> Void)?
    let background: Background
    
    init(
        users: [User],
        centeredUserID: User.ID?,
        hiddenUserIDs: Set<User.ID> = [],
        mode: UserPhysicsClusterMode,
        circleRadius: CGFloat,
        scene: UserPhysicsClusterScene,
        onTapSelect: @escaping (PhysicsUserSelection) -> Bool,
        onLongPressUsers: (([User.ID]) -> Void)? = nil,
        onLongPressUser: ((User.ID) -> Void)? = nil,
        voiceOverRole: HoneycombAccessibilityRole = .itemAssignment,
        onTapBackground: (() -> Void)? = nil,
        @ViewBuilder background: () -> Background
    ) {
        self.users = users
        self.centeredUserID = centeredUserID
        self.hiddenUserIDs = hiddenUserIDs
        self.mode = mode
        self.circleRadius = circleRadius
        self.scene = scene
        self.onTapSelect = onTapSelect
        self.onLongPressUsers = onLongPressUsers
        self.onLongPressUser = onLongPressUser
        self.voiceOverRole = voiceOverRole
        self.onTapBackground = onTapBackground
        self.background = background()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                background.allowsHitTesting(false)
                
                if mode == .honeycomb {
                    TransparentSpriteView(scene: scene)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipShape(Circle())
                        .contentShape(Circle())
                } else {
                    TransparentSpriteView(scene: scene)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .contentShape(Rectangle())
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .allowsHitTesting(!users.isEmpty)
            .onAppear {
                configureScene(size: geometry.size)
            }
            .onChange(of: geometry.size) {
                configureScene(size: geometry.size)
            }
            .onChange(of: users) {
                configureScene(size: geometry.size)
            }
            .onChange(of: centeredUserID) {
                configureScene(size: geometry.size)
            }
            .onChange(of: hiddenUserIDs) {
                configureScene(size: geometry.size)
            }
            .onChange(of: circleRadius) {
                configureScene(size: geometry.size)
            }
            .onChange(of: mode) {
                configureScene(size: geometry.size)
            }
            .onDisappear {
                scene.cancelInteractions()
                scene.onTapSelection = nil
                scene.onLongPressUsers = nil
                scene.onLongPressUser = nil
                scene.onTapBackground = nil
                scene.isPaused = true
            }
        }
        // VoiceOver: os círculos do SpriteKit não são acessíveis, então
        // viram uma lista de botões com as mesmas ações do toque e do
        // toque longo.
        .accessibilityRepresentation {
            accessibleUserList
        }
    }
    
    // MARK: - Acessibilidade (VoiceOver)
    
    private var accessibleUsers: [User] {
        users.filter { !hiddenUserIDs.contains($0.id) }
    }
    
    private var accessibleUserList: some View {
        VStack {
            if accessibleUsers.isEmpty {
                switch voiceOverRole {
                case .billParticipants:
                    Text("Nenhum participante adicionado ainda")
                case .itemAssignment:
                    Text("Todas as pessoas já estão neste item")
                case .itemMembers:
                    // O card já mostra a própria mensagem de vazio.
                    EmptyView()
                }
            }
            
            ForEach(accessibleUsers, id: \.id) { user in
                accessibleUserButton(user)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityListLabel)
    }
    
    private var accessibilityListLabel: Text {
        switch voiceOverRole {
        case .billParticipants: Text("Participantes da conta")
        case .itemAssignment: Text("Pessoas disponíveis")
        case .itemMembers: Text("Pessoas neste item")
        }
    }
    
    private var accessibilityHint: Text {
        switch voiceOverRole {
        case .billParticipants: Text("Toque duas vezes para remover da conta.")
        case .itemAssignment: Text("Toque duas vezes para colocar esta pessoa no item.")
        case .itemMembers: Text("Toque duas vezes para tirar esta pessoa do item.")
        }
    }
    
    private func accessibleUserButton(_ user: User) -> some View {
        Button {
            selectForAccessibility(user)
        } label: {
            Text(user.accessibilityName)
        }
        .accessibilityHint(accessibilityHint)
        .accessibilityActions {
            if voiceOverRole == .billParticipants, let onLongPressUser {
                Button("Editar participante") {
                    onLongPressUser(user.id)
                }
            }
            
            if voiceOverRole == .itemAssignment, let onLongPressUsers {
                Button("Adicionar todas as pessoas ao item") {
                    onLongPressUsers(accessibleUsers.map(\.id))
                    AccessibilityAnnouncer.announce(String(localized: "Todas as pessoas estão neste item"))
                }
            }
            
            if voiceOverRole == .itemMembers, let onLongPressUsers {
                Button("Remover todas as pessoas do item") {
                    onLongPressUsers(accessibleUsers.map(\.id))
                    AccessibilityAnnouncer.announce(String(localized: "Todas as pessoas saíram do item"))
                }
            }
        }
    }
    
    /// Faz o mesmo que tocar no círculo da pessoa.
    private func selectForAccessibility(_ user: User) {
        guard let selection = scene.selection(for: user.id) else {
            return
        }
        
        if onTapSelect(selection) {
            scene.setCirclesHidden(true, for: [user.id])
        }
        
        switch voiceOverRole {
        case .billParticipants:
            AccessibilityAnnouncer.announce(String(localized: "\(user.name) saiu da conta"))
        case .itemAssignment:
            AccessibilityAnnouncer.announce(String(localized: "\(user.name) está neste item"))
        case .itemMembers:
            AccessibilityAnnouncer.announce(String(localized: "\(user.name) saiu do item"))
        }
    }
    
    private func configureScene(size: CGSize) {
        scene.scaleMode = .resizeFill
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.backgroundColor = .clear
        
        scene.mode = mode
        scene.usesRectangularBoundary = mode == .maxCard
        scene.circleRadius = circleRadius
        
        if scene.size != size {
            scene.size = size
        }
        
        scene.isPaused = false
        scene.onTapSelection = onTapSelect
        scene.onLongPressUsers = onLongPressUsers
        scene.onLongPressUser = onLongPressUser
        scene.onTapBackground = onTapBackground
        
        scene.apply(users: users, centeredUserID: centeredUserID, hiddenUserIDs: hiddenUserIDs)
    }
}

struct UserPhysicsClusterView<Background: View>: View {
    let users: [User]
    let centeredUserID: User.ID?
    let mode: UserPhysicsClusterMode
    let onTapUser: (User.ID) -> Void
    let onVisualCenterUserChanged: (User.ID?) -> Void
    let background: Background
    
    @State private var scene: UserPhysicsClusterScene
    
    init(
        users: [User],
        centeredUserID: User.ID?,
        mode: UserPhysicsClusterMode = .honeycomb,
        scene existingScene: UserPhysicsClusterScene? = nil,
        circleRadius: CGFloat = 30,
        onTapUser: @escaping (User.ID) -> Void,
        onVisualCenterUserChanged: @escaping (User.ID?) -> Void = { _ in },
        @ViewBuilder background: () -> Background
    ) {
        let scene = existingScene ?? UserPhysicsClusterScene()
        
        scene.scaleMode = .resizeFill
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.backgroundColor = .clear
        scene.circleRadius = circleRadius
        scene.mode = mode
        
        _scene = State(initialValue: scene)
        
        self.users = users
        self.centeredUserID = centeredUserID
        self.mode = mode
        self.onTapUser = onTapUser
        self.onVisualCenterUserChanged = onVisualCenterUserChanged
        self.background = background()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                background.allowsHitTesting(false)
                
                TransparentSpriteView(scene: scene)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipShape(Circle())
                    .contentShape(Circle())
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear { configureScene() }
            .onChange(of: users) { configureScene() }
            .onChange(of: centeredUserID) { configureScene() }
            .onChange(of: mode) { configureScene() }
            .onDisappear { scene.isPaused = true }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func configureScene() {
        scene.isPaused = false
        scene.mode = mode
        scene.onTapUser = onTapUser
        scene.onVisualCenterUserChanged = onVisualCenterUserChanged
        
        scene.apply(users: users, centeredUserID: centeredUserID)
    }
}

struct UserPhysicsClusterPrototypeView:
    View {

    @State private var activeUsers: [User]
    @State private var waitingUsers: [User]

    @State private var centeredUserID: User.ID?
    
    @State private var mode: UserPhysicsClusterMode = .honeycomb
    @State private var visuallyCenteredUserID: User.ID?

    init() {
        let sampleUsers = [
            User(
                name: "Ana",
                emoji: "🌸",
                color: .pink
            ),
            User(
                name: "Bia",
                emoji: "🐝",
                color: .yellow
            ),
            User(
                name: "Caio",
                emoji: "🐳",
                color: .blue
            ),
            User(
                name: "Duda",
                emoji: "🍊",
                color: .orange
            ),
            User(
                name: "Enzo",
                emoji: "🌿",
                color: .green
            ),
            User(
                name: "Fê",
                emoji: "🦄",
                color: .purple
            ),
            User(
                name: "Gabi",
                emoji: "🧁",
                color: .mint
            ),
            User(
                name: "Hugo",
                emoji: "🚀",
                color: .indigo
            ),
            User(
                name: "Iara",
                emoji: "🐬",
                color: .cyan
            ),
            User(
                name: "João",
                emoji: "⚽️",
                color: .brown
            ),
            User(
                name: "Kah",
                emoji: "🍓",
                color: .red
            ),
            User(
                name: "Leo",
                emoji: "🌙",
                color: .gray
            )
        ]

        let initialUsers = Array(sampleUsers.prefix(7))

        _activeUsers = State(initialValue: initialUsers)

        _waitingUsers = State(initialValue: Array(sampleUsers.dropFirst(7)))

        _centeredUserID = State(initialValue: initialUsers.first?.id)
        
        _visuallyCenteredUserID = State(initialValue: nil)
    }

    var body: some View {
        VStack(spacing: 18) {
                Text("Protótipo físico")
                    .font(.title2.bold())

                Picker(
                    "Modo",
                    selection: $mode
                ) {
                    Text("Honeycomb")
                        .tag(
                            UserPhysicsClusterMode
                                .honeycomb
                        )

                    Text("MaxCard")
                        .tag(
                            UserPhysicsClusterMode
                                .maxCard
                        )
                }
                .pickerStyle(.segmented)

                Text(
                    mode == .honeycomb
                    ? """
                      Arraste para mudar o centro visual. \
                      Toque em qualquer círculo para removê-lo.
                      """
                    : """
                      O arraste fica desativado e os círculos \
                      permanecem com o mesmo tamanho. \
                      Toque para remover.
                      """
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

                UserPhysicsClusterView(
                    users: activeUsers,
                    centeredUserID:
                        centeredUserID,
                    mode: mode,
                    circleRadius: 30,
                    onTapUser: { userID in
                        removeUser(userID)
                    },
                    onVisualCenterUserChanged: {
                        userID in

                        visuallyCenteredUserID =
                            userID
                    }
                ) {
                    Circle()
                        .fill(
                            Color.gray.opacity(0.12)
                        )
                        .overlay {
                            Circle()
                                .stroke(
                                    Color.gray.opacity(
                                        0.25
                                    ),
                                    lineWidth: 1
                                )
                        }
                }
                .frame(
                    width: 310,
                    height: 310
                )

                VStack(spacing: 4) {
                    Text(
                        """
                        Centro físico: \
                        \(userName(for: centeredUserID))
                        """
                    )

                    Text(
                        """
                        Centro visual: \
                        \(userName(
                            for: visuallyCenteredUserID
                        ))
                        """
                    )
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Button("Adicionar") {
                    addUser()
                }
                .buttonStyle(.borderedProminent)
                .disabled(waitingUsers.isEmpty)

                Text(
                    "\(activeUsers.count) usuários"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding()
    }

    private func addUser() {
        guard !waitingUsers.isEmpty
        else {
            return
        }

        let newUser =
            waitingUsers.removeFirst()

        activeUsers.append(newUser)

        // O usuário novo passa a ocupar
        // o centro.
        centeredUserID = newUser.id
    }
    
    private func removeUser(
        _ userID: User.ID
    ) {
        guard
            let index =
                activeUsers.firstIndex(
                    where: {
                        $0.id == userID
                    }
                )
        else {
            return
        }

        let removedUser =
            activeUsers.remove(at: index)

        waitingUsers.append(removedUser)

        // O centro físico só muda se
        // justamente ele foi removido.
        if centeredUserID == userID {
            centeredUserID =
                activeUsers.first?.id
        }

        if activeUsers.isEmpty {
            visuallyCenteredUserID = nil
        }
    }

    private func userName(
        for userID: User.ID?
    ) -> String {
        guard let userID else {
            return "—"
        }

        return activeUsers.first {
            $0.id == userID
        }?.name ?? "—"
    }
}

#Preview("Cluster físico") {
    UserPhysicsClusterPrototypeView()
}
