//
//  SignUpView.swift
//  macOSFront
//
//  Created by Enzo Ferroni on 29/08/25.
//

import SwiftUI

/// This view is where the user's data is posted once they register. Note: the route must be updated later.
///
/// - Paramethers: SignUpViewModel
struct SignUpView: View {
    
    func intToString() -> String{
            var role: String = ""
            switch(selected){
            case 1:
                role = "student"
            case 2:
                role = "mentor"
            case 3:
                role = "adm"
            default:
                role = "student"
            }
            return role
        }
    
    @State var name: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmedPassword: String = ""
    @State var role: String = ""
    @State var selected: Int = 0
    
    @Environment(\.dismiss) var dismiss
    var body: some View {
        
        NavigationStack{
            ZStack{
                VStack {
                    Text("Bem vindo(a) !")
                        .font(.title3)
                        .padding(.bottom, 2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 2)
                    
                    Text("Insira seus dados abaixo para acessar Alinha!")
                        .padding(.bottom,2)
                    Text("Nome:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .opacity(0.5)
                    
                    TextField("Untitled" , text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .padding(.top, -5)
                    
                    Text("Email:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.top)
                        .opacity(0.5)
                    
                    TextField("", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .padding(.top, -5)
                    
                    Text("Senha:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.top)
                        .opacity(0.5)
                    
                    SecureField("", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .padding(.top, -5)
                    
                    Text("Confirmar senha:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.top)
                        .opacity(0.5)
                    
                    SecureField("", text: $confirmedPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .padding(.top, -5)
                    
                    Text("Qual o tipo do seu perfil?")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.top)
                        .opacity(0.5)
                    
                    Picker(selection: $selected, label: Text("")) {
                        Text("Aluno").tag(1)
                        Text("Mentor").tag(2)
                        Text("Admin").tag(3)
                    }
                    .padding(.leading, 20)
                    .pickerStyle(.radioGroup)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 5)
                    //                Spacer()
                    HStack{
                        Button("Cancela") {
                            dismiss()
                        }
                        .padding(.top, 20)
                        
                        Button() {
                            Task{
                                do{
                                    let (_,_) = try await RoutesRequisition.postUser(object: PostUser(name: name, email: email, password: password, confirmedPassword: confirmedPassword, role: intToString()))
                                }catch{
                                    print(error.localizedDescription)
                                }
                            }
                            dismiss()
                        } label: {
                            ZStack(){
                                RoundedRectangle(cornerRadius: 5)
                                    .frame(width: 70 , height: 20)
                                    .foregroundStyle(.highlight)
                                Text("Confirma")
                                    .foregroundStyle(.white)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 20)
                        
                    }
                    
                    Text("Já possui conta?")
                        .padding(.top, 5)
                        .padding(.bottom, 1)
                    
                    Button(){
                        dismiss()
                    }label:{
                        Text("Entrar")
                            .foregroundStyle(.blue)
                            .underline(true)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                
                //            Image("merfino")
                //                .frame(maxWidth: .infinity, alignment: .leading)
                //                .frame(maxHeight: .infinity, alignment: .bottom)
                //                .offset(x: 0, y: 30)
            }
            .background(.primaria)
        }
    }
}

#Preview {
    SignUpView()
}
