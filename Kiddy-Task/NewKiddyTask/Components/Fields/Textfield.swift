//
//  Textfield.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 28/01/26.
//
//269,44
import SwiftUI

struct Textfield: View {
    
    @Binding var input: String
    var width: CGFloat = 270
    var height: CGFloat = 42

    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 22)
                .frame(width: width, height: height)
                .foregroundStyle(Color(red: 0.92, green: 0.96, blue: 0.96))
            
            TextField("", text: $input)
                .frame(width: width - 35)
                .foregroundStyle(.black)
        }
    }
}

struct Textfield2: View {
    @Binding var input: String
    var width: CGFloat = 270
    var height: CGFloat = 42
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 22)
                .frame(width: width, height: height)
                .foregroundStyle(Color(red: 0.86, green: 0.92, blue: 0.94))

            
            TextField("", text: $input)
                .frame(width: width - 35)
                .foregroundStyle(.black)
        }
    }
}
