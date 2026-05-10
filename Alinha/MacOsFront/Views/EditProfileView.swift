//
//  EditProfileView.swift
//  macOSFront
//
//  Created by Isabela Hissa Pinto on 01/09/25.
//

import SwiftUI
import SwiftData
/// View where the user can edit it's name and picture, and also delete his account.
/// - A side bar at the left helps the user to navigate between views.
/// - A button at the right side of the toolbar has the desctuctive role of deleting the user's account.
/// - Parameter Dimiss: Enable cancel action at the user edition.
/// - Parameter newName: It receives user new name after the edition.
/// - Parameter isAlert: Boolean that triggers the alert.
/// - Parameter showingSheet: Boolean that triggers the sheet.
struct EditProfileView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var newName: String = ""
    @State var isAlertDelete: Bool = false
    @State var isAlertLogout: Bool = false
//    @State var showingSheet: Bool = false
    
    @Environment(\.modelContext) private var context
    @Query var userMac : [User]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ligthYellow
                Image("Background")
                    .resizable()
                VStack{
                    HStack{
                        Text("Editar Perfil")
                            .font(.largeTitle)
                            .padding(.top, 16)
                            .padding(.leading, 20)
                            .foregroundStyle(Color.darkGreen)
                            .bold()
                        Spacer()
                    }
                    Spacer()
                }
                VStack {
                    Spacer()
                    ProfileCircleComponent(edit: true, width: 200, height: 200)
                        .padding(.bottom, 24)
                    
                    VStack(alignment: .leading) {
                        Text("Nome:")
                            .padding(.leading, -10)
                            .foregroundStyle(.gray)
                        
                        TextField("", text: $newName)
                            .frame(width: 180, height: 29)
                            .textFieldStyle(.plain)
                            .foregroundStyle(.black)
                            .background(
                                ZStack{
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(red: 0.95, green: 0.95, blue: 0.95))
                                        .background(Color(.white))
                                        .frame(width: 205, height: 29)
                                    
                                    
                                }.background(Color(red: 0.85, green: 0.85, blue: 0.85))
                                    .cornerRadius(8)
                                    .shadow(color: .black.opacity(0.25),radius: 3, x:0, y:1)
                            )
                        HStack {
                            Button("Cancelar"){
                                dismiss()
                                newName = ""
                            }
                            Button("Confirmar") {
                                Task{
                                    do{
                                        let patchUserUpdateName: PatchUserUpdateName = PatchUserUpdateName(id: userMac.first!.id ,name: newName)
                                        
                                        let (patchUserResponseUpdateName, _) = try await RoutesRequisition.PatchUsersUpdateName(object: patchUserUpdateName)
                                        userMac.first!.name = newName
                                    }
                                    catch{
                                        print(error.localizedDescription)
                                    }
                                }
                            }.buttonStyle(.borderedProminent)
                                .tint(Color("GreenGreen"))
                        }.padding(.leading, -10)
                    }
                    Spacer()
                }
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(role: .destructive) {
                    isAlertLogout.toggle()
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.forward")
                        .foregroundStyle(Color.darkGreen)
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(role: .destructive) {
                    isAlertDelete.toggle()
                } label: {
                    Image(systemName: "trash.fill")
                        .foregroundStyle(Color("LigthRed"))
                }
            }
        }
        .alert("Você irá se desconectar do aplicativo", isPresented: $isAlertLogout){
            Button("Logout", role: .destructive) {
                context.delete(userMac.first!)
                do{
                    try context.save()

                }catch{
                    print("error delete swiftData")
                }
            }
        }message: {
            Text("Você irá se desconectar do aplicativo")
        }
        .dialogIcon(Image(systemName: "exclamationmark.triangle"))
        .alert("Você quer apagar o seu perfil?", isPresented:$isAlertDelete) {
            Button("Apagar", role: .destructive) {
                Task{
                    do{
                        let _ = try await RoutesRequisition.DeleteUsersId(id: userMac.first!.id, auth: userMac.first!.authID)
                        context.delete(userMac.first!)
                        try context.save()

                    }
                    catch{
                        print(error.localizedDescription)
                    }
                }
            }
        } message: {
            Text("Isso apagará permanentemente seus dados")
        }
        .dialogIcon(Image(systemName: "exclamationmark.triangle"))
        .toolbarBackground(Color("LigthBlue"))
//        .sheet(isPresented: $showingSheet) {
//            ProfileSheetVIew()
//        }
    }
        
}

//#Preview {
//    EditProfileView()
//        .frame(width: 1464*0.4, height: 920*0.4)
//}
