//
//  ItemCardView.swift
//  EventsApp
//
//  Created by Camila Parolin on 31/08/26.
//

import SwiftUI

//decide qual versão do card deve aparecer MinCard ou MaxCard
struct ItemCardView: View {
    let product: Product
    let productNumber: Int
    let users: [User]
    let centeredUserID: User.ID?
    let returningUserID: User.ID?
    let returningAllUserIDs: Set<User.ID>
    let isExpanded: Bool

    var physicsScene: UserPhysicsClusterScene? = nil

    let animation: Namespace.ID
    let onRemoveUser: (CardUserSelection) -> Void
    let onRemoveAllUsers: () -> Void
    let onTap: () -> Void

    var body: some View {
        Group {
            if isExpanded {
                MaxCard(
                    product: product,
                    productNumber: productNumber,
                    users: users,
                    centeredUserID: centeredUserID,
                    returningUserID: returningUserID,
                    returningAllUserIDs: returningAllUserIDs,
                    physicsScene: physicsScene,
                    animation: animation,
                    onRemoveUser: onRemoveUser,
                    onRemoveAllUsers: onRemoveAllUsers,
                    onTapCard: onTap
                )
            } else {
                MinCard(
                    product: product,
                    productNumber: productNumber
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    onTap()
                }
                // VoiceOver: o card fechado é um único botão que abre o item.
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(product.accessibilitySummary(number: productNumber))
                .accessibilityValue(assignedNamesValue)
                .accessibilityHint("Toque duas vezes para abrir e dividir este item.")
                .accessibilityAddTraits(.isButton)
                .accessibilityAction {
                    onTap()
                }
            }
        }
    }

    /// Quem já está no item, para o VoiceOver saber o que falta dividir.
    private var assignedNamesValue: Text {
        let names = users
            .filter { product.assignedUserIDs.contains($0.id) }
            .map(\.name)

        guard !names.isEmpty else {
            return Text("Ninguém neste item ainda")
        }

        return Text("Pessoas: \(names.formatted(.list(type: .and)))")
    }
}
