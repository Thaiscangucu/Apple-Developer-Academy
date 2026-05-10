//
//  ProfileSheetVIew.swift
//  iOSFront
//
//  Created by Pedro Henrique L. Moreiras on 29/08/25.
//

import SwiftUI
/// A View That Show the User's Information and Give the Option to Edit and Log Out.
/// - Show the  the main informations of the user (Name, E-mail and Profile);
/// - It also contains two buttons: Edit Profile and Log Out.
/// - Parameter dismiss: A variable that it's responsable to the 'close' action (In this case, the profile sheet).
struct ProfileSheetVIew: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0){
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        ButtonDimissSheetComponent()
                    }.buttonStyle(.plain)
                    Spacer()
                }
                Spacer()
                VStack(spacing: 0) {
                    ProfileCircleComponent(edit: false, width: 100, height: 100)
                        .padding(.bottom, 16)
                    Text("Pepeu Gomes")
                        .font(.system(size: 20))
                        .fontWeight(.light)
                    
                    Text("pepeugomes@email.com")
                        .font(Font.custom("SF Pro", size: 20))
                        .fontWeight(.light)
                }
                .padding(.bottom,24)
                Spacer()
                VStack(alignment: .leading){
                    HStack(spacing: 12){
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.black)
                            .font(.system(size: 20))
                        
                        Text("Editar")
                            .font(.title3)
                            .fontWeight(.light)
                        Spacer()
                    }
                    .padding(.bottom, 1)
                    HStack{
                        Image(systemName: "rectangle.portrait.and.arrow.forward")
                            .foregroundStyle(.red)
                            .font(.system(size: 19))
                            .padding(.leading, 1)
                        
                        Text("Log Out")
                            .font(.title3)
                            .fontWeight(.light)
                        Spacer()
                    }
                    .padding(.bottom, 18)
                    
                    
                } .padding(.leading,32)
            }
            .frame(width: 360, height: 336)
        }
    }
}

#Preview {
    ProfileSheetVIew()
}

