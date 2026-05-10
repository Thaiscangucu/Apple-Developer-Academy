//
//  ContentView.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 28/01/26.
//

//TODO: teclado esconde os campos na hora de digitar
import SwiftUI

struct WelcomeView: View {
    @Binding var firstTime: Bool
    
    @AppStorage("kidName") var kidName: String = ""
    @AppStorage("parentName") var parentName: String = ""
    @AppStorage("password") var password: String = ""
    @State var confirmedPassword: String = ""
    @State var passwordsEqual = true
    
    @State var isSecure = true
    
    var textFont: CGFloat = 16
    
    var body: some View {
        ZStack{
            Image("WelcomeBG")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack{
                // Greeting Message
                Greeting()
                    .padding(.trailing, 80)
                    .padding(.top)
                Spacer()
                
                ScrollView{
                    // Form (names + passwords)
                    smallRedAlert(text: "nome do cuidador(a) favorito!", textFont: 15, textWeight: .bold)
                    //                        .padding(.top, 250)
                    Textfield(input: $parentName)
                    
                    smallRedAlert(text: "nome da criança mais destemida!", textFont: 15, textWeight: .bold)
                    Textfield(input: $kidName)
                    
                    smallRedAlert(text: "senha para o(a) cuidador(a)", textFont: 15, textWeight: .bold)
                        .padding(.top)
                    Securefield(input: $password)
                    
                    smallRedAlert(text: "confirme a senha", textFont: 15, textWeight: .bold)
                    ZStack{
                        Rectangle()
                          .foregroundColor(.clear)
                          .frame(width: 269, height: 44)
                          .cornerRadius(22)
                          .overlay(
                            RoundedRectangle(cornerRadius: 22)
                              .inset(by: 1.5)
                              .stroke(Color(red: 0.84, green: 0.92, blue: 0.94), lineWidth: 3)
                          )
                        Group{
                            if isSecure{
                                SecureField("", text: $confirmedPassword)
                            }else{
                                TextField("", text: $confirmedPassword)
                            }
                        }
                        .foregroundStyle(.black)
                        .animation(.easeInOut(duration: 0.2), value: isSecure)
                        .frame(width: 234)
                        HStack{
                            Spacer()
                            Button(action: {
                                isSecure.toggle()
                            }, label: {
                                Image(systemName: !isSecure ? "eye.slash" : "eye" )
                                    .foregroundColor(Color(red: 0.63, green: 0.8, blue: 0.83))
                            })
                        }
                        .frame(width: 234)
                    }
                    
                    Text(passwordsEqual ? "" : "As senhas não coincidem")
                        .font(.system(size: 10))
                        .foregroundStyle(.red)
                        .padding(.bottom, 5)
                    
                    Button{
                        if password != confirmedPassword{
                            passwordsEqual = false
                        }
                        else{
                            firstTime.toggle()
                        }
                    }
                    label:{
                        bigButton(text: "estou pronto", thumbsUp: true)
                    }
                    .padding(.bottom, 50)
                }
                .padding(.top, 250)
                
            }
            
        }
    }
    
}
