//
//  UserFormPage.swift
//  EventsApp
//
//  Created by Thais Cangucu on 24/09/26.
//

import SwiftUI

/// Página da sheet de participantes com o formulário para criar ou editar
/// um participante (ou o "Meu Card"): nome, cor e emoji.
struct UserFormPage: View {
    /// ViewModel compartilhada com o AddUserFormView.
    @Bindable var addUserVm: AddUserViewModel

    var body: some View {
        VStack(spacing: 24) {
            UserTextField(
                name: $addUserVm.name,
                selectedEmoji: $addUserVm.selectedEmoji,
                selectedColor: $addUserVm.selectedColor,
                addUserVm: addUserVm
            )
            .padding(.top)

            ColorPickerView(
                colors: addUserVm.predefinedColors,
                selectedColor: $addUserVm.selectedColor
            )

            EmojiPickerView(
                emojis: addUserVm.emojis,
                selectedEmoji: $addUserVm.selectedEmoji
            )

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

#Preview {
    UserFormPage(addUserVm: AddUserViewModel())
        .environment(BillViewModel())
}
