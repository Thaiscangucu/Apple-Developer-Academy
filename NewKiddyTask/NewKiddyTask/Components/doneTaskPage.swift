//
//  doneTaskPage.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 04/02/26.
//

import SwiftUI

struct doneTaskPage: View {
    @ObservedObject var doneTask: Tarefa
    var body: some View {
        VStack{
            
            // Título tarefa
            Text(doneTask.title ?? "")
                .font(.custom("Qilka", size: 25)
                    .weight(.bold)
                )
                .foregroundColor(.textGray)
            
            
            // Data
            Text(doneTask.date ?? Date.now, format: .dateTime.day().month().year())
                .font(.system(size: 18)
                    .weight(.medium))
                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
                .padding(.top, -3)
            
            // Símbolos
//            HStack{
                //                Image(systemName: doneTask.symbols[0])
                //                Image(systemName: doneTask.symbols[1])
                //                Image(systemName: doneTask.symbols[2])
//            }
//            .font(.system(size: 35))
//            .foregroundColor(Color(red: 0.44, green: 0.57, blue: 1))
//            .padding(.top, 20)
            
            // Foto
            Text("depois 📸")
                .font(.system(size: 16)
                    .weight(.medium)
                )
                .foregroundColor(Color(red: 0.48, green: 0.48, blue: 0.48))
                .padding(.top, 5)
            
            
            if let data = doneTask.picAfter, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 229, height: 139)
                    .id(doneTask.id)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 21))
            }
            else {
                Image(systemName: "photo")
                    .foregroundColor(.gray)
            }
        }
    }
}

