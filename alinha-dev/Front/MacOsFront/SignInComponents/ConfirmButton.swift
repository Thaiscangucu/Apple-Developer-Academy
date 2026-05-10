//
//  ConfirmButton.swift
//  macOSFront
//
//  Created by Isabela Hissa Pinto on 26/08/25.
//

import SwiftUI
//
//struct ConfirmButton: View {
//    @Binding var name: String
//    @Binding var email: String
//    @Binding var password: String
//    @Binding var confirmPassword: String
//    @Binding var showAlert: Bool
//    @Binding var role: String
//    @Binding var alertContent: (String, String)
//    @Binding var eyeclose: Bool
//    @ObservedObject var vm = SignInRequisitionViewModel()
//    
//    var body: some View {
//        Button {
//            if(password == confirmPassword && password.count > 0 && name.count >= 3 && isValidEmail(email) == true){
//                vm.createUser(user: SignInUser(name: name, email: email, password: password, confirmedPassword: confirmPassword))
//            } else{
//                alertContent = checkSingupContents(name: name, email: email, password: password, confirmPassword: confirmPassword)
//                showAlert = true
//                password = ""
//                confirmPassword = ""
//            }
//        } label: {
//            Text("Confirmar")
//                .bold()
//                .buttonStyle(.plain)
//                .cornerRadius(10)
//                .padding(5)
//        }.padding(.top, 20)
//        .alert(isPresented: $showAlert){
//            Alert(
//                title: Text("\(alertContent.0)"),
//                message: Text("\(alertContent.1)"),
//            )
//        }
//    }
//}

//#Preview {
//    ConfirmButton(name: .constant("Nome"), email: .constant("E-mail"), password: .constant("******"), confirmPassword: .constant("******"), showAlert: .constant(false), alertContent: .constant(("teste","teste2")), eyeclose: .constant(false))
//}
