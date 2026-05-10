////
////  FieldView.swift
////  Front
////
////  Created by João Pedro Pioltini de Oliveira on 26/08/25.
////
//

import SwiftData
import SwiftUI
/// A View focused on the composition of the custom TextField
///
///
struct FieldView: View {
    @Binding var email: String
    @Binding var password: String
    private let baseColor: Color = .init(red: 232/255, green: 232/255, blue: 232/255)
    private let shadowColor: Color = .init(red: 197/255, green: 197/255, blue: 197/255)
    @State var eyeclose: Bool = false

    
    
    var body: some View {
        VStack(alignment: .leading){
            Text("e-mail")
                .font(.callout)
                .padding(.bottom,8)
                .bold()
            TextField("", text: $email)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(baseColor.gradient.shadow(.inner(color: shadowColor, radius: 5, x: 2, y: 2)))
                        .frame(width: 361, height: 40)
                        .foregroundStyle(Color(UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
                )
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
            
            VStack(alignment: .leading){
                Text("senha")
                    .font(.callout)
                    .bold()
                HStack{
                    if eyeclose == true{
                        TextField("\($password)", text: $password)
                            .frame(width: 300, height: 50)
                    }
                    else{
                        SecureField("", text: $password)
                            .frame(width: 300, height: 50)
                    }
                    EyeView(eyeclose: $eyeclose)
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(baseColor.gradient.shadow(.inner(color: shadowColor, radius: 5, x: 2, y: 2)))
                        .frame(width: 361, height: 40)
                        .foregroundStyle(Color(UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
                )
                .padding(.top,8)
            }
            
            .padding(.top,16)
        }
    }
}
/// A struct that create the component "EyeBind"
///
/// It creates the logic of the opened and closed eye to hide text password Text Field
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

