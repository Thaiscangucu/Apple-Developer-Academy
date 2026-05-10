//
//  EditField.swift
//  Front
//
//  Created by André Contarelli Lima on 26/08/25.
//

import SwiftUI

///Struct that allows the user to edit its information as name and password. 
struct EditFieldView: View {
    ///
    ///Parameters: userName, oldPassword, newPassword and confirmationNewPassword
    ///
    ///That will check if the user input the right oldPassword and allows the user to change the password in the app.
    ///
    ///Verifies if the newPassword is inputed two times equally.
    @Binding var userName: String
    @Binding var oldPassword: String
    @Binding var newPassword: String
    @Binding var confirmationNewPassword: String
    
    @State var eyeclose1: Bool = false
    @State var eyeclose2: Bool = false
    
    private let baseColor: Color = .init(red: 232/255, green: 232/255, blue: 232/255)
    private let shadowColor: Color = .init(red: 197/255, green: 197/255, blue: 197/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nome")
                .font(.callout)
                .fontWeight(.bold)
                .padding(.leading, 24)
            
            TextField("", text: $userName)
                .padding(.leading, 30)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(baseColor.gradient.shadow(.inner(color: shadowColor, radius: 5, x: 2, y: 2)))
                        .frame(width: 370, height: 40)
                        .foregroundStyle(Color(UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
                )
            
            Text("Senha antiga")
                .font(.callout)
                .fontWeight(.bold)
                .padding(.leading, 24)
            TextField("", text: $oldPassword)
                .padding(.leading, 30)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(baseColor.gradient.shadow(.inner(color: shadowColor, radius: 5, x: 2, y: 2)))
                        .frame(width: 370, height: 40)
                        .foregroundStyle(Color(UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
                )
            
            Text("Nova senha")
                .font(.callout)
                .fontWeight(.bold)
                .padding(.leading, 24)
            HStack{
                if eyeclose1 == true{
                    TextField("\($newPassword)", text: $newPassword)
                        .padding(.leading, 30)
                        .frame(width: 350, height: 20)
                }
                else{
                    SecureField("", text: $newPassword)
                        .padding(.leading, 30)
                        .frame(width: 350, height: 20)
                        .textContentType(.oneTimeCode)
                }
                EyeNewPasswordView(eyeclose1: $eyeclose1)
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(baseColor.gradient.shadow(.inner(color: shadowColor, radius: 5, x: 2, y: 2)))
                    .frame(width: 370, height: 40)
                    .foregroundStyle(Color(UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
            )
            
            Text("Confirme sua nova senha")
                .font(.callout)
                .fontWeight(.bold)
                .padding(.leading, 24)
            HStack{
                if eyeclose2 == true{
                    TextField("\($confirmationNewPassword)", text: $confirmationNewPassword)
                        .padding(.leading, 30)
                        .frame(width: 350, height: 20)
                }
                else{
                    SecureField("", text: $confirmationNewPassword)
                        .padding(.leading, 30)
                        .frame(width: 350, height: 20)
                        .textContentType(.oneTimeCode)
                }
                EyeConfirmationPasswordView(eyeclose2: $eyeclose2)
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(baseColor.gradient.shadow(.inner(color: shadowColor, radius: 5, x: 2, y: 2)))
                    .frame(width: 370, height: 40)
                    .foregroundStyle(Color(UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
            )
        }
        Spacer()
            .padding(.top, 55)
    }
}

///Struct of the Eye SFSymbol that allows the user to see the password that its been writen.
struct EyeNewPasswordView: View {
    
    @Binding var eyeclose1: Bool
    
    private let baseColor: Color = .init(red: 232/255, green: 232/255, blue: 232/255)
    private let shadowColor: Color = .init(red: 197/255, green: 197/255, blue: 197/255)
    
    var body: some View {
        Button {
            eyeclose1.toggle()
        }
        label: {
            if eyeclose1 {
                Image(systemName: "eye.slash")
            }
            else {
                Image(systemName: "eye")
            }
        }
        .padding(.trailing, 30)
    }
}

///Struct of the Eye SFSymbol that allows the user to see the confirmation of its password that its been writen.
struct EyeConfirmationPasswordView: View {
    
    @Binding var eyeclose2: Bool
    
    private let baseColor: Color = .init(red: 232/255, green: 232/255, blue: 232/255)
    private let shadowColor: Color = .init(red: 197/255, green: 197/255, blue: 197/255)
    
    var body: some View {
        Button {
            eyeclose2.toggle()
        }
        label: {
            if eyeclose2 {
                Image(systemName: "eye.slash")
            }
            else {
                Image(systemName: "eye")
            }
            
        }
        .padding(.trailing, 30)
    }
}
