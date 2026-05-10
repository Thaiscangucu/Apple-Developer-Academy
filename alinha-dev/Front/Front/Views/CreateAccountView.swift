//
//  Cadastro.swift
//  macOSFront
//
//  Created by Isabela Hissa Pinto on 20/08/25.
//

import SwiftUI

struct CreateAccountView: View {
    ///Sign Up Variables
    /// - Parameters:
    ///      - name: User's name
    ///      - email: User's e-mail
    ///      - password: User's defined password
    ///      - confirmPassword: User's password to check
    ///      - showAlert: It makes the alert appear
    ///      - alertContent: It's an touple with the alert messafes.
    /// - View Definition: This is responsable to sign up the user account.
    /// - Components: It contains four text fields (Name, E-mail, Password and Confirm Password);  Includes a button to confirm the sign up
    /// - Validation: Informs the user if some information is incorrect (Example: If the password doesn't match)
    ///> tip:The second VStack is a TextFieldComponent group.
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert = false
    @State private var alertContent: (String, String) = ("","")
    @State var eyeclose: Bool = true
    
    @Binding var path: NavigationPath
    
    var body: some View {
        
        HStack {
            VStack (spacing: 15){
                TextFieldComponent(name: $name, eyeclose: $eyeclose, typeEnum: .name, title: "name")
                
                
                
                TextFieldComponent(name: $email, eyeclose: $eyeclose, typeEnum: .email, title: "email@provider.com")
                
                
                if eyeclose == false{
                    ZStack{
                        TextFieldComponent(name: $password, eyeclose: $eyeclose, typeEnum: .password, title: "showPassword")
                        HStack{
                            Spacer()
                            EyeView(eyeclose: $eyeclose)
                        } .padding(.top, 40)
                            .padding(.trailing, 40)
                    }
                }
                else {
                    ZStack{
                        TextFieldComponent(name: $password, eyeclose: $eyeclose, typeEnum: .password, title: "Senha")
                        HStack{
                            Spacer()
                            EyeView(eyeclose: $eyeclose)
                        } .padding(.top, 40)
                            .padding(.trailing, 40)
                    }
                }
                
                
                
                if eyeclose == false{
                    ZStack{
                        TextFieldComponent(name: $confirmPassword, eyeclose: $eyeclose, typeEnum: .confirmPassword, title: "showPassword")
                        HStack{
                            Spacer()
                            EyeView(eyeclose: $eyeclose)
                        } .padding(.top, 40)
                            .padding(.trailing, 40)
                    }
                }
                else {
                    ZStack{
                        TextFieldComponent(name: $confirmPassword, eyeclose: $eyeclose, typeEnum: .confirmPassword, title: "Senha")
                        
                        HStack{
                            Spacer()
                            EyeView(eyeclose: $eyeclose)
                        } .padding(.top, 40)
                            .padding(.trailing, 40)
                    }
                }
                ConfirmButton(name: $name, email: $email, password: $password, confirmPassword: $confirmPassword, showAlert: $showAlert, alertContent: $alertContent, eyeclose: $eyeclose)
            }
        }.navigationTitle(Text("Cadastro"))
            .padding(.vertical, 30)
            .navigationBarTitleDisplayMode(.inline)
        
        Spacer()
    }
}



#Preview {
    @Previewable @State var path = NavigationPath()
    CreateAccountView(path: $path)
}
