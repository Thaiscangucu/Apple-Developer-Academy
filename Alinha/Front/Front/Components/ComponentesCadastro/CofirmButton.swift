import SwiftUI

struct ConfirmButton: View {
    @Binding var name: String
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var showAlert: Bool
    @Binding var alertContent: (String, String)
    @Binding var eyeclose: Bool
    
    var body: some View {
        Button {
            if(password == confirmPassword && password.count > 8 /*&& isPasswordHasNumberAndCharacterSign(password: password)*/ && name.count >= 3 && isValidName(name: name) && isValidEmail(email)){
                Task {
                    try await RoutesRequisition.postUser(object: PostUser(name: name, email: email, password: password, confirmedPassword: confirmPassword, role: "student"))
                }
            } else {
                alertContent = checkSingupContents(name: name, email: email, password: password, confirmPassword: confirmPassword)
                showAlert = true
                password = ""
                confirmPassword = ""
            }
        } label: {
            DefaultButton(buttonName: "Cadastrar")
        }.padding(.top, 20)
        .alert(isPresented: $showAlert){
            Alert(
                title: Text("\(alertContent.0)"),
                message: Text("\(alertContent.1)"),
            )
        }
    }
}

#Preview {
    ConfirmButton(name: .constant("Nome"), email: .constant("E-mail"), password: .constant("******"), confirmPassword: .constant("******"), showAlert: .constant(false), alertContent: .constant(("teste","teste2")), eyeclose: .constant(false))
}

