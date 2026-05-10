//
//  ExtractedView.swift
//  Front
//
//  Created by João Pedro Pioltini de Oliveira on 26/08/25.
//
import SwiftUI
///  View focused on the button that is componentized to be used in the Sing in View.
///
///  Beside the customization of the button, it also have the logic to ask the information to the backend.
///
struct JoinButton: View {
    @Environment(\.modelContext) private var context
    @Binding var email: String
    @Binding var password: String
    @State var buttonTF: Bool = true
    
    var body: some View {
        Button {
            print("ligado")
            Task {
                let (authID, getUser) = try await RoutesRequisition.loginUser(password: password, email: email)
                
                let user = User(authID: authID, imageName: "", name: getUser.name, email: getUser.email, role: getUser.role, id: getUser.id, deviceToken: deviceToken_)
                
                context.insert(user)
                do{
                    try context.save()
                }catch{
                    print("error save user")
                }
                buttonTF = false
            }

//            isPresented.toggle()
//            Task {
//                do {
//                    statusCode = try await requisition.getUser(user: user)
//                    
//                    if statusCode == .ok {
//                        /*Creating an empty todo*/
//                        let userLogIn = UserInfoLogIn(name: "body.name", email: "body.email", password: "body.hash", photo: "body.photo")
//                        /*Savin todo*/
//                        context.insert(userLogIn)
//                        buttonTF = true
//                    }
//                } catch {
//                    //erro
//                    buttonTF = true
//                }
//                
//            }
        } label: {
            ZStack{
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 201, height: 40)
                    .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                
                    .cornerRadius(8)
                    .padding(.top, 13)
                Text("Entrar")
                    .foregroundStyle(.black)
                    .font(.callout)
                    .bold()
                    .padding(.top, 13)
            }
        }
        .disabled(buttonTF == false)
    }
}
