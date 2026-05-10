//
//  ProfileCircleComponent.swift
//  macOSFront
//
//  Created by Isabela Hissa Pinto on 01/09/25.
//

import SwiftUI
/// Component Of The Profile Picture on The Profile Sheet View and Edit Profile View.
/// - Parameter Edit: A boolean variable responsable to show or not the edit button (It only shows if it’s the Edit Profile View);
/// - Parameter Width: A variable that receives a CGFloat, it’s used to define the width on the elements (Image, shapes, frames…);
/// - Parameter Height:A variable that receives a CGFloat, it’s used to define the hegight on the elements (Image, shapes, frames…).
struct ProfileCircleComponent: View {
    @State private var showingSheet = false
    var edit: Bool
    var width: CGFloat
    var height: CGFloat
    
    
    var body: some View {
        ZStack{
            Circle()
                .frame(width: width, height: height)
                .foregroundStyle(Color("DarkGreen"))
            
            Image(systemName: "person.fill")
                .font(.system(size: width - width * 0.3))
                .padding(.bottom, 16)
                .foregroundStyle(.white)
            if edit {
                Button{
                    showingSheet.toggle()
                } label: {
                    ZStack{
                        Circle()
                            .frame(width: 38, height: 38)
                            .foregroundStyle(.white)
                            .overlay(
                                Circle()
                                    .foregroundStyle(Color("GreenGreen"))
                                    .frame(width: 34, height: 34)
                            )
                        Image(systemName: "paintbrush.pointed.fill")
                            .foregroundStyle(.white)
                            .font(.system(size: 18))
                    }.padding(.top, width - 54)
                        .padding(.leading, height - 54)
                    
                } .buttonStyle(.plain)
                    .sheet(isPresented: $showingSheet){
                        EditProfilePictureView()
                    }
            }
        }
    }
}

#Preview {
    ProfileCircleComponent(edit: true, width: 200, height: 200)
        .frame(width: 400, height: 400)
}
