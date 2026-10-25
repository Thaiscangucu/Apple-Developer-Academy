//
//  SymbolsPickerVIew.swift
//  appMind
//
//  Created by André Contarelli Lima on 28/10/25.
//
import SwiftData
import SwiftUI

struct SingleSymbolPicker: View {
    @Environment(\.dismiss) private var dismiss
    
    let symbols = [
        // Cleaning & Maintenance
        "broom.fill",
        "bubbles.and.sparkles.fill",
        "trash.fill",
        "sink.fill",
        "text.bubble.fill",
        "shower.fill",
        "tshirt.fill",
        
        // Kitchen & Meals
        "fork.knife",
        "cart.fill",
        "cup.and.saucer.fill",
        
        // Garden & Outdoors
        "leaf.fill",
        "drop.fill",
        "sun.max.fill",
        "house.fill",
        "pencil.and.outline",
        "backpack.fill",
        "pencil",
        "eraser.fill",
        "book.closed.fill",
        "figure.pool.swim",
        "soccerball.inverse",
        "basketball.fill",
        "music.note",
        "graduationcap.fill",
        "abc",
        
        // Toys & Playtime
        "teddybear.fill",
        "puzzlepiece.fill",
        "balloon.fill",
        "gamecontroller.fill",
        "figure.and.child.holdinghands",
        "guitars.fill",
        
        // Baby & Toddler Care
        "moon.zzz.fill",
        
        // Health & Hygiene
        "bathtub.fill",
        "cross.case.fill",
        "figure.stand.dress",
        "figure.stand",
        "heart.fill",
        "star.fill"
    ]
    
    var columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)
    
    @State var selectedIcon: String = ""
    @Binding var tempSelectedIcon: String
    
    var body: some View {
        NavigationStack{
            ScrollView{
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(symbols.indices, id: \.self) { i in
                        let icon = symbols[i]
                        Button {
                            tempSelectedIcon = icon
                        } label: {
                            if tempSelectedIcon == icon {
                                Image(systemName: symbols[i])
                                    .font(.title)
                                    .foregroundStyle(.accent)
                            } else {
                                Image(systemName: symbols[i])
                                    .font(.title)
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                }
            }
            .background(.white)
            .toolbar {
                ToolbarItem(placement: .topBarLeading){
                    Button {
                        tempSelectedIcon = ""
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.text)
                    }
                }
                ToolbarItem(placement: .principal){
                    Text("Ícone")
                        .foregroundStyle(.text)
                }
                ToolbarItem(placement: .topBarTrailing){
                    Button{
                        dismiss()
                    }
                    label:{
                        Text("OK")
                            .foregroundStyle(.text)
                            .bold()
                    }
                }
            }
        }
    }
}
