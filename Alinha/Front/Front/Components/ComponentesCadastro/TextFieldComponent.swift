//
//  Textfield.swift
//  Front
//
//  Created by Isabela Hissa Pinto on 21/08/25.
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
            VStack(alignment: .leading, spacing: 20){
                Text(typeEnum.title)
                    .font(Font.custom("SF Pro",size:16).weight(.medium))
                TextField("", text: $name)
                    .textContentType(.name)
                    .textFieldStyle(.plain)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .frame(width: UIScreen.main.bounds.width * 0.7)
                    .padding(.trailing,70)
                    .background(
                        ZStack{
                            Rectangle()
                                .stroke(Color(red: 0.85, green: 0.85, blue: 0.85))
                                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
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
                HStack{
                    SecureField("", text: $name)
                        .textContentType(.oneTimeCode)
                        .textContentType(.newPassword)
                        .textFieldStyle(.plain)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .frame(width: UIScreen.main.bounds.width * 0.7)
                        .padding(.trailing,70)
                        .background(
                            ZStack{
                                Rectangle()
                                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85))
                                    .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                                    .frame(width: 361,height: 40)
                                    .shadow(color: .black.opacity(0.45), radius: 3,x: 0, y:2)
                                
                                
                            }
                                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                                .cornerRadius(8)
                        )
                    
//                    EyeView(eyeclose: $eyeclose)
                }
               
            }
        }
    }
}

//struct TextFieldComponent: View {
//    @Binding var name: String
//    @Binding var eyeclose: Bool
//    var title: String
//
//    var body: some View {
//        if title == "name" {
//            VStack(alignment: .leading, spacing: 15){
//                Text("Nome")
//                    .padding(.leading, -10)
//                    .font(Font.custom("SF Pro",size:16).weight(.medium))
//                    .bold()
//                TextField(title, text: $name)
//                    .textContentType(.name)
//                    .textFieldStyle(.plain)
//                    .autocorrectionDisabled(true) // Adicionado :D
//                    .frame(width: 331)
//                    .padding(.leading, 5)
//                    .background(
//                        ZStack{
//                            Rectangle()
//                                .stroke(Color(red: 0.85, green: 0.85, blue: 0.85))
//                                .background(Color(UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
//                                .frame(width: 361,height: 40)
//                                .shadow(color: .black.opacity(0.45), radius: 3,x: 0, y:2)
//                        }
//                            .background(Color(UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
//                            .cornerRadius(8)
//                    )
//            }
//            .padding(.leading,30)
//        } else if title == "email@provider.com" {
//            TextField(title, text: $name)
//                .textContentType(.emailAddress)
//                .textFieldStyle(.plain)
//                .autocorrectionDisabled(true) // Adicionado :D
//            #if os(iOS)
//                .textInputAutocapitalization(.never)
//            #endif
//                .frame(width: 361)
//                .padding(.leading, 30)
//                .background(
//                    ZStack{
//                        Rectangle()
//                            .stroke(Color(red: 0.85, green: 0.85, blue: 0.85))
//                            .background(Color(UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
//                            .frame(width: 361,height: 40)
//                            .shadow(color: .black.opacity(0.45), radius: 3,x: 0, y:2)
//                    }
//                        .background(Color(UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
//                        .cornerRadius(8)
//                )
//
//        } else if title == "showPassword" {
//            HStack{
//
//                TextField(title, text: $name)
//
//                    .textContentType(.oneTimeCode)
//                    .textContentType(.newPassword)
//                    .textFieldStyle(.plain)
//#if os(iOS)
//                    .textInputAutocapitalization(.never)
//#endif
//                    .frame(width: 281)
//                    .padding(.leading, -50)
//
//                    .background(
//                            Rectangle()
//                                .stroke(Color(red: 0.85, green: 0.85, blue: 0.85))
//                                .background(Color(UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
//                                .frame(width: 361,height: 40)
//
//                                .shadow(color: .black.opacity(0.45), radius: 3,x: 0, y:2)
//                            .background(Color(UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
//                            .cornerRadius(8)
//
//                    )
//                EyeView(eyeclose: $eyeclose)
//            }
//            .padding(.leading, 80)
//        }
//        else {
//            HStack{
//
//                SecureField(title, text: $name)
//
//                    .textContentType(.oneTimeCode)
//                    .textContentType(.newPassword)
//                    .textFieldStyle(.plain)
//#if os(iOS)
//                    .textInputAutocapitalization(.never)
//#endif
//                    .frame(width: 281)
//                    .padding(.leading, -50)
//
//                    .background(
//                        ZStack{
//                            Rectangle()
//                                .stroke(Color(red: 0.85, green: 0.85, blue: 0.85))
//                                .background(Color(UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
//                                .frame(width: 361,height: 40)
//
//                                .shadow(color: .black.opacity(0.45), radius: 3,x: 0, y:2)
//                        }
//                            .background(Color(UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
//                            .cornerRadius(8)
//
//                    )
//                EyeView(eyeclose: $eyeclose)
//
//            }
//            .padding(.leading, 80)
//        }
//    }
//}

#Preview{
    TextFieldComponent(name: .constant("Digite seu nome"), eyeclose: .constant(true), typeEnum: .password, title: "name")
}
