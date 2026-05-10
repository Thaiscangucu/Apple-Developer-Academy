//
//  EditProfileView.swift
//  iOSFront
//
//  Created by Lucca Pivoto on 26/08/25.
//

import Foundation
import SwiftUI
import SwiftData

/// Main structure where user profile information is passed and allows changing information such as password and icon, as well as logging out
///
/// Parameters:
///     - context: 
struct ProfileView: View{
    @Query var user : [User]
    @State var userIcon : String
    
    
    @Binding var path: NavigationPath

    @Environment(\.modelContext) private var context
    //Nome da imagem selecionada do assets
    
    @State var showingSheetProfile: Bool = false
    
    @State var showingSheetIcon: Bool = false
    var body: some View{
//        NavigationStack{
                VStack{
                    VStack{
                        ZStack{
                            //Caso a struct não receba uma string valida(o que é valida? nome de uma imagem do assets) o codigo quebrará
                            Image(user.first?.imageName ?? " ")
                                .resizable()
                                .scaledToFit()
                                .clipShape(Circle())
                                .frame(width: 217 , height: 217)
                                .foregroundStyle((Color(red: 0.75, green: 0.75, blue: 0.75)))
                                .padding(.top , 45)
                                .overlay(
                                    Button{
                                        showingSheetIcon.toggle()
                                    }label:{
                                        ZStack(){
                                            Circle()
                                                .frame(width: 32 , height: 32)
                                                .foregroundStyle((Color(red: 0.85, green: 0.85, blue: 0.85)))
                                            Image(systemName: "plus")
                                                .frame(width: 17 , height: 17)
                                        }
                                    }
                                        .padding(.top , 230)
                                        .padding(.leading , 135)
                                )
                        }
                        Text(user.first?.name ?? " ")
                            .font(.system(size: 32))
                            .fontWeight(.bold)
                            .foregroundStyle((Color(red: 0.85, green: 0.85, blue: 0.85)))
                    }
                    .padding(.bottom , 80)
                    HStack{
                        VStack(alignment: .leading){
                            Text("Nome")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                            Text(user.first?.name ?? " ")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundStyle(.gray)
                                .padding(.bottom , 40)
                            Text("e-mail")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                            Text(user.first?.email ?? " ")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundStyle(.gray)
                        }
                        .padding(.leading , 31)
                        Spacer()
                    }
                    .padding(.bottom , 140)
                    Button{
                        context.delete(user.first!)
                        do{
                            try context.save()
                        }catch{
                            print("error delete swiftData")
                        }
                        path = NavigationPath()
                    }label:{
                        ZStack{
                            RoundedRectangle(cornerRadius: 8)
                                .frame(width: 201 , height: 40)
                                .foregroundStyle((Color(red: 0.85, green: 0.85, blue: 0.85)))
                            Text("Log out")
                                .fontWeight(.bold)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .ignoresSafeArea()
                .background(.white)
//        }
        .toolbar{
            Button{
                showingSheetProfile.toggle()
                
            } label:{
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 17))
            }
        }
        .sheet(isPresented:  $showingSheetProfile){ SheetEditProfile()
        }
        .sheet(isPresented:  $showingSheetIcon){
            SheetEditIcon(user: user, selectedIcon: "")
        }
    }
}

#Preview {
//    @Previewable @State var path = NavigationPath()
//    
//    ProfileView(userIcon: "icon1", path: $path)
    
    ProfileView(userIcon: "icon1",path: .constant(NavigationPath()))
}

