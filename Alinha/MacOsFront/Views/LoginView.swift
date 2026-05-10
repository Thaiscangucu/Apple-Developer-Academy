//
//  ContentView.swift
//  MacOsFront
//
//  Created by Jonas Fernando Nascimento Melo on 20/08/25.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    
    @State var selectedBarItem: SideBarItem = .queue
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State var statusCode: HTTPResponse
    @Environment(\.modelContext) private var context
    
    @Query var userMac: [User]
    
    var body: some View {
        
        if userMac.isEmpty{
            NavigationStack{
                ZStack{
                    VStack {
                        Text("Bem vindo(a) !")
                            .font(.title3)
                            .padding(.bottom, 2)
                            .fontWeight(.semibold)
                            .padding (.bottom, 2 )
                        Text("Insira seus dados abaixo para acessar Alinha!")
                            .padding(.bottom, 2)
                        
                        Text("Email")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            .opacity(0.5)
                        
                        TextField("Untitled", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .padding(.top, -5)
                        
                        Text("Senha")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            .padding(.top)
                            .opacity(0.5)
                        
                        SecureField("", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .padding(.top, -5)
                        
                        Spacer()
                        
                        Button {
                            Task{
                                do{
                                    let (authID, getUser) = try await RoutesRequisition.loginUser(password: password, email: email)
                                    
                                    let user = User(authID: authID, imageName: "", name: getUser.name, email: getUser.email, role: getUser.role, id: getUser.id)
                                    context.insert(user)
                                    
                                    try context.save()
                                    
                                }catch{
                                    print("error save user")
                                }
                            }
                        } label:{
                            ZStack(){
                                RoundedRectangle(cornerRadius: 5)
                                    .frame(width: 70 , height: 20)
                                    .foregroundStyle(.highlight)
                                Text("Confirma")
                                    .foregroundStyle(.white)
                                
                            }
                        }
                        .shadow(radius: 3 , x: 0, y: 1)
                        .buttonStyle(PlainButtonStyle())
                        .padding(.top, 20)
                        
                        Text("Não possui conta?")
                            .padding(.top, 5)
                            .padding(.bottom, 1)
                        
                        NavigationLink{
                            SignUpView()
                        }label: {
                            Text("Criar conta")
                                .foregroundStyle(.blue)
                                .underline(true)
                                .navigationBarBackButtonHidden(true)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                    
                    Image("merfino")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .offset(x: 0, y: 20)
                }.background(.primaria)
            }
        } else {
            NavigationSplitView {
                VStack(alignment: .leading, spacing: 12) {
                    
                    Button {
                        selectedBarItem = .queue
                    } label: {
                        if selectedBarItem == .queue{
                            Image(systemName: "questionmark.bubble.fill")
                                .font(.largeTitle)
                                .foregroundStyle(Color.greenGreen)
                        }else{
                            Image(systemName: "questionmark.bubble.fill")
                                .font(.largeTitle)
                                .foregroundStyle(Color.darkGreen)
                            
                        }
                        
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        selectedBarItem = .membros
                    } label: {
                        if selectedBarItem == .membros{
                            Image(systemName: "person.2.fill")
                                .font(.largeTitle)
                                .foregroundStyle(Color.greenGreen)
                        }else{
                            Image(systemName: "person.2.fill")
                                .font(.largeTitle)
                                .foregroundStyle(Color.darkGreen)
                            
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Button {
                        selectedBarItem = .perfil
                    } label: {
                        if selectedBarItem == .perfil{
                            Image(systemName: "person.circle")
                                .font(.largeTitle)
                                .foregroundStyle(Color.greenGreen)
                        }else{
                            Image(systemName: "person.circle")
                                .font(.largeTitle)
                                .foregroundStyle(Color.darkGreen)
                            
                        }
                        
                    }
                    .buttonStyle(.plain)
                    
                }
                
                .padding()
                .navigationTitle("Sidebar")
            }
            detail: {
                switch selectedBarItem {
                case .queue:
                    MacQueueView()
                case .membros:
                    MacMamberTeam()
                case .perfil:
                    EditProfileView()
                }
            }
            .navigationSplitViewStyle(.balanced)
            .toolbarBackground(Color("LigthBlue"))
            
        }
        
    }
}

#Preview {
    LoginView(statusCode: HTTPResponse.ok)
}
