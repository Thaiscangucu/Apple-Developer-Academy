//
//  ExistingUsersPage.swift
//  EventsApp
//
//  Created by Thais Cangucu on 24/09/26.
//

import SwiftUI

/// Página da sheet de participantes que mostra o "Meu Card" e a grade
/// com os participantes já salvos.
struct ExistingUsersPage: View {
    @Environment(BillViewModel.self) private var vm

    /// ViewModel compartilhada com o AddUserFormView.
    var addUserVm: AddUserViewModel
    
    let flyingUserID: User.ID?
    let onAddPersistendUser: ((User, CGRect) -> Void)?
    let onAddMyCard: ((User, CGRect) -> Void)?
    
    @State private var circleFrames: [User.ID: CGRect] = [:]

    @Environment(\.dynamicTypeSize) private var typeSize

    /// 3 colunas de mesma largura. Com texto grande, 2 colunas: assim o
    /// nome de cada pessoa tem espaço para aparecer inteiro.
    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: 12),
            count: typeSize.isAccessibilitySize ? 2 : 3
        )
    }

    /// Espaço vertical entre as linhas da grade.
    private let rowSpacing: CGFloat = 20
    
    init(addUserVm: AddUserViewModel, flyingUserID: User.ID? = nil, onAddPersistendUser: ((User, CGRect) -> Void)? = nil, onAddMyCard: ((User, CGRect) -> Void)? = nil) {
        self.addUserVm = addUserVm
        self.flyingUserID = flyingUserID
        self.onAddPersistendUser = onAddPersistendUser
        self.onAddMyCard = onAddMyCard
    }

    var body: some View {
        VStack {
            Text("Meu Card")
                .font(.app(.subheadline, weight: .medium))
                .foregroundColor(.textSecondary)
                .accessibilityAddTraits(.isHeader)

            MyCardSection(
                addUserVm: addUserVm,
                isFlying: addUserVm.myCard.map {
                    flyingUserID == $0.id
                } ?? false,
                onTap: { user, circleFrame in
                    guard flyingUserID == nil else {
                        return
                    }
                    
                    guard
                        let onAddMyCard,
                        !circleFrame.isEmpty
                    else {
                        addUserVm.addMyCardToBill(in: vm)
                        return
                    }
                    
                    onAddMyCard(user, circleFrame)
                },
                onEdit: { _ in
                    addUserVm.startMyCardForm(fromContextMenu: true)
                },
                onDelete: { _ in
                    withAnimation {
                        addUserVm.deleteMyCard()
                    }
                }
            )
            .frame(minHeight: 85)

            Divider()
                .padding()
                .accessibilityHidden(true)

            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: rowSpacing) {
                    ForEach(vm.oldUsers) { user in
                        UserCircleForm(
                            user: user,
                            isAlreadyAdded: addUserVm.isUserInBill(user, in: vm),
                            onTap: {
                                handlePersistedUserTap(user)
                            },
                            onEdit: {
                                addUserVm.startEditingUser(user)
                            },
                            onDelete: {
                                withAnimation {
                                    vm.removeOldUser(user)
                                }
                            },
                            isFlying: flyingUserID == user.id,
                            onCircleFrameChange: { frame in
                                circleFrames[user.id] = frame
                            }
                        )
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Participantes salvos")
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func handlePersistedUserTap(_ user: User) {
        guard flyingUserID == nil else {
            return
        }
        
        guard
            let sourceFrame = circleFrames[user.id],
            let onAddPersistendUser
        else {
            addUserVm.addExistingUser(user, in: vm)
            return
        }
        
        onAddPersistendUser(user, sourceFrame)
    }
}

#Preview {
    ExistingUsersPage(addUserVm: AddUserViewModel())
        .environment(BillViewModel())
}
