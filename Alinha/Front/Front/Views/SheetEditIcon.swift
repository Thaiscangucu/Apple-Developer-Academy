//
//  SheetEditIconView.swift
//  iOSFront
//
//  Created by Binho Gadelha on 26/08/25.
//

import SwiftUI

///Sheet that allows the user to select its icon and show it on the Profile View.
///
///
///
///     - user: user's secured information
///     - selectedIcon: variable used to confirm the selected icon
///     - tempSelectedIcon:temporarily saves the selected image
///
///     ///Parameters: selectedIcon (the icon previously selected by the user)
///
///
struct SheetEditIcon: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State var user: [User]
    @State var selectedIcon: String
    @State var tempSelectedIcon: String = ""
    
    let icons: [String] = ["icon1", "icon2", "icon3", "icon4", "icon5", "icon6", "icon7", "icon8"]
    
    //definir ainda formato da Grid. Atual: 3 lin e 3 col
    var columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    
    var body: some View {
        NavigationStack{
            ScrollView{
                
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(icons.indices, id: \.self) { i in
                        let icon = icons[i]
                        Button {
                            tempSelectedIcon = icon
                            
//                            selectedIcon = icon
                        } label: {
                            ZStack{
                                Circle()
                                .fill(.gray)
                                
                                   
                                
                                Image(icon)
                                    
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(Circle())
                                
                                Circle()
                                    .strokeBorder(tempSelectedIcon == icon ? .white : .clear, lineWidth:9)
                                    
                                Circle()
                                    .strokeBorder(tempSelectedIcon == icon ? .blue : .clear, lineWidth: 5)

                            }
                            .frame(width: 120)
                        }
                    }
                }
            }/*.navigationTitle("Ícone")*/
            .toolbar {
                ToolbarItem(placement: .topBarLeading){
                    Button ("Cancelar") {
                        dismiss()
                        //verificar funcionalidade, se o ícone selecionado nao esta sendo salvo
                    }
                }
                ToolbarItem(placement: .principal){
                    Text("Ícone")
                }
                ToolbarItem(placement: .topBarTrailing){
                    
                    Button("Salvar"){
                        //aplicar funcionalidade de salvar, definir ImagemSelecionada temporaria = ImagemAtual
                        selectedIcon = tempSelectedIcon
                        user.first?.imageName = selectedIcon
                        try? context.save()
                        dismiss()
                    }
                }
            }
        }
        
        
    }
}

#Preview {
    //depois passar $selectedIcon
    SheetEditIcon(user: [], selectedIcon: "icon1")
}

