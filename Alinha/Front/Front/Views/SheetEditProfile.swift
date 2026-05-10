//
//  SheetEditProfileView.swift
//  iOSFront
//
//  Created by André Contarelli Lima on 26/08/25.
//

import SwiftUI

/// Sheet that carries the Edit Field View functionalities, where the user edits their password information
struct SheetEditProfile: View {
    
    
    
    @Environment(\.dismiss) var dismiss
    
    @State var userName: String = ""
    @State var oldPassword: String = ""
    @State var newPassword: String = ""
    @State var confirmationNewPassword: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                EditFieldView(userName: $userName, oldPassword: $oldPassword, newPassword: $newPassword, confirmationNewPassword: $confirmationNewPassword)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Perfil")
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Salvar"){
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SheetEditProfile()
}
