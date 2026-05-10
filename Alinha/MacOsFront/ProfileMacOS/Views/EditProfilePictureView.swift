//
//  EditProfilePictureView.swift
//  macOSFront
//
//  Created by Pedro Henrique L. Moreiras on 02/09/25.
//

import SwiftUI
import SwiftData

struct EditProfilePictureView: View {
    @Environment(\.dismiss) var dismiss
    @Query var userMac : [User]
    @State var imageName: String = ""
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var profiles:[String] = ["Profile1", "Profile2", "Profile3", "Profile4", "Profile5", "Profile6", "Profile7", "Profile8", "Profile9", "Profile10", "Profile11", "Profile12", "Profile13", "Profile14", "Profile15", "Profile16", "Profile17", "Profile18", "Profile19", "Profile20", "Profile21", "Profile22", "Profile23", "Profile24", "Profile25", "Profile26", "Profile27", "Profile28", "Profile29", "Profile30", "Profile31", "Profile32", "Profile33", "Profile34", "Profile35", "Profile36", "Profile37", "Profile38", "Profile39"]
    
    var body: some View {
        NavigationStack{
            VStack{
                Text("Editar Foto")
                    .font(.system(size: 16))
                    .bold()
                
                Text("Escolha sua imagem de perfil.")
                    .fontWeight(.light)
                    .padding(.bottom, 26)
                
                ScrollView{
                    LazyVGrid(columns: columns ,spacing: 26){
                        ForEach(profiles, id: \.self){ picture in
                            
                            Button{
                               imageName = picture
                            } label: {
                                Image(picture)
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 100, height: 100)
                                    .padding(.bottom, 2)
                            } .buttonStyle(.plain)
                            
                        }
                    }
                }
            } .frame(width: 520, height: 622)
                .padding(.top, 26)
                Button("OK"){
                    userMac.first!.imageName = imageName
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                    .tint(Color.ligthRed)
                    .padding(.leading, 450)
            }
        }
    }

#Preview {
    EditProfilePictureView()
}
