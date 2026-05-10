//
//  ProfileView.swift
//  iOSFront
//
//  Created by Pedro Henrique L. Moreiras on 29/08/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var showingSheet = false
    
    var body: some View {
        VStack{
            Button("Profile"){
                showingSheet.toggle()
            } .sheet(isPresented: $showingSheet) {
                ProfileSheetVIew()
            }
            
        } .frame(width: 500, height: 500)
    }
}

#Preview {
    ProfileView()
}
