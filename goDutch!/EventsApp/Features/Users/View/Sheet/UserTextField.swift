//
//  UserPreview.swift
//  EventsApp
//
//  Created by Thais Cangucu on 24/08/26.
//

import SwiftUI

/// Campo de identificação do participante que combina a edição do nome
/// com uma prévia visual do emoji e da cor escolhidos.
struct UserTextField: View {

    /// Nome digitado pelo usuário.
    @Binding var name: String

    /// Emoji escolhido para representar o participante.
    @Binding var selectedEmoji: String

    /// Cor escolhida para representar o participante.
    @Binding var selectedColor: Color
    
    @Environment(BillViewModel.self) private var vm
    /// ViewModel de participantes (classe, então não precisa de @Binding).
    var addUserVm: AddUserViewModel

    /// Foco do campo de nome: permite abrir o teclado tocando em qualquer
    /// parte da cápsula branca, não só na linha do texto.
    @FocusState private var isNameFocused: Bool

    /// Quantidade máxima de caracteres do nome do participante.
    private let maxNameLength = 10

    var body: some View {

        ZStack(alignment: .leading) {

            RoundedRectangle(cornerRadius: 60)
                .fill(.white)
                .frame(height: 70)
                .shadow(color: .black.opacity(0.2), radius: 2.49645, x: 0, y: 2.49645)
                .shadow(color: Color("shadowSoft").opacity(0.1), radius: 2.49645, x: 0, y: -1.24823)
                .onTapGesture { isNameFocused = true }

            TextField("Nome", text: $name)
                .accessibilityLabel("Nome do participante")
                .accessibilityHint("Até 10 letras.")
                .focused($isNameFocused)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .frame(maxWidth: .infinity, minHeight: 70)
                .padding(.horizontal, 95)
                .contentShape(Rectangle())
                .submitLabel(.go)
                .onChange(of: name) { _, newValue in
                    if newValue.count > maxNameLength {
                        name = String(newValue.prefix(maxNameLength))
                    }
                }
                .onSubmit {
                    addUserVm.submitForm(in: vm)
                    // O "go" tira o foco do campo por padrão; devolvemos o foco
                    // no próximo ciclo para o teclado continuar aberto e o
                    // usuário já poder digitar o próximo nome.
                    DispatchQueue.main.async {
                        isNameFocused = true
                    }
                }

            ZStack {
                Circle()
                    .fill(selectedColor)
                    .frame(width: 95, height: 95)
                    .shadow(color: .black.opacity(0.2), radius: 1.6878, x: 0, y: 1.6878)
                    .shadow(color: Color("shadowSoft").opacity(0.1), radius: 1.6878, x: 0, y: -0.8439)

                Text(selectedEmoji)
                    .font(.system(size: 50))
            }
            .fixedSize()
            .onTapGesture { isNameFocused = true }
            // Prévia visual (cor + emoji): decorativa, o VoiceOver não lê.
            .accessibilityHidden(true)
        }
        .padding(.top)
        .containerRelativeFrame(.horizontal) { width, _ in
            width * 0.9
        }
    }
}

