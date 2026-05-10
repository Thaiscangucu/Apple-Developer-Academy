//
//  LoginView.swift
//  iOSFront
//
//  Created by Dayô Araújo on 21/08/25.
//
import SwiftData
import SwiftUI


/// Screen that appears for the user when he is not logged in and allows to login into the app.
///
/// In this view it contains some main components:
/// - Text Fields: Where the user can put you personal info that was previsously utilize in the sign up (email, password)
/// - Confirm Button: A button that finsh the process of login, and give the acess to the user.
/// - Sign up Button: If the user doesn't have a account already, it will send him into the Sign up View.
struct LoginView: View  {
    @Environment(\.dismiss) var dismiss
    @State private var email: String = ""
    @State private var password: String = ""
    
    @Binding var path: NavigationPath

    @Query var user: [User]
    
    var body: some View {

            if user.isEmpty {
                VStack (alignment: .center, spacing: 20){
                    CardView()//6
                    
                    FieldView(email: $email, password: $password)
                        .padding(.top, 35)
                    
                    JoinButton(email: $email, password: $password)
                    
                    Spacer()
                
                    HStack(){
                        HStack{
                            
                            Button {
                                path.append(AppRoute.CreatAccoutView)
                            } label: {
                                
                                Text("Não tem conta?")
                                    .font(.footnote)
                                    .foregroundColor(.black)
                                Text("Criar")
                                    .font(.footnote)
                            }
                        }
                        Spacer()
                    }
                    .padding(.bottom, 37)

                }
                .padding(.horizontal, 30)
                .padding(.top, 30)
                .navigationTitle("Bem-vindo!")
                .onAppear(){
                    email = ""
                    password = ""
                }
            }
            else {
                QueueView(path: $path)
            }
        
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    LoginView(path: $path)
}









