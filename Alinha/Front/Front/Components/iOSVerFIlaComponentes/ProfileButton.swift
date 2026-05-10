//
//  ProfileButton.swift
//  iOSFront
//
//  Created by Jonas Fernando Nascimento Melo on 01/09/25.
//

import SwiftUI

struct ProfileButton: View {
    
    @Binding var path: NavigationPath

    
    var body: some View {
        Button {
            path.append(AppRoute.ProfileView)
        } label: {
            Image (systemName: "person.circle")
                .font(.headline)
                .foregroundColor(.blue)
        }

//        NavigationLink(destination:  ProfileView(userIcon: "icon1", path: $path), label: {
//            Image (systemName: "person.circle")
//                .font(.headline)
//                .foregroundColor(.blue)
//        })
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    
    ProfileButton(path: .constant(NavigationPath()))
}
