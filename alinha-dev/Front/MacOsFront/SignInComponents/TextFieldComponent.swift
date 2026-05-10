//
//  Untitled.swift
//  Front
//
//  Created by Isabela Hissa Pinto on 26/08/25.
//

import SwiftUI

enum TypeEnum: String {
    case name
    case email
    case password
    case confirmPassword
    
    var title: String {
        switch self {
        case .name:
            return "Nome"
            
        case .email:
            return "E-mail"
            
        case .password:
            return "Senha"
            
        case .confirmPassword:
            return "Confirme sua senha"
            
        }
    }
}

struct TextFieldComponent: View {
    @Binding var name: String
    @Binding var eyeclose: Bool
    var typeEnum: TypeEnum
    var title: String
    
    var body: some View {
        if typeEnum == .name || typeEnum == .email || eyeclose == false {
            VStack(alignment: .leading, spacing: 15){
                Text(typeEnum.title)
                    .font(Font.custom("SF Pro",size:16).weight(.medium))
                TextField("", text: $name)
                    .textContentType(.name)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled(true)
                    .frame(width: 361)
                    .background(
                        ZStack{
                            Rectangle()
                                .stroke(Color(red: 0.15, green: 0.15, blue: 0.15))
                                .background(Color(red: 0.25, green: 0.25, blue: 0.25))
                                .frame(width: 361,height: 40)
                                .shadow(color: .black.opacity(0.45), radius: 3,x: 0, y:2)
                        }
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .cornerRadius(8))
            }
        } else {
            VStack(alignment: .leading, spacing: 20){
                Text(typeEnum.title)
                    .font(Font.custom("SF Pro",size:16).weight(.medium))
                SecureField("", text: $name)
                    .textContentType(.oneTimeCode)
                    .textContentType(.newPassword)
                    .textFieldStyle(.plain)
                    .frame(width: 361)
                    .background(
                        ZStack{
                            HStack{
                                Rectangle()
                                    .stroke(Color(red: 0.15, green: 0.15, blue: 0.15))
                                    .background(Color(red: 0.25, green: 0.25, blue: 0.25))
                                    .frame(width: 361,height: 40)
                                    .shadow(color: .black.opacity(0.45), radius: 3,x: 0, y:2)
                            }
                            EyeView(eyeclose: $eyeclose)
                        }
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .cornerRadius(8))
            }
        }
    }
}

struct EyeView: View {
    @Binding var eyeclose: Bool
    
    var body: some View {
        Button {
            eyeclose.toggle()
        }
        label: {
            if eyeclose {
                Image(systemName: "eye.slash")
            }
            else {
                Image(systemName: "eye")
            }
        }
    }
}

#Preview{
    TextFieldComponent(name: .constant(""), eyeclose: .constant(true), typeEnum: .email, title: "name")
}
