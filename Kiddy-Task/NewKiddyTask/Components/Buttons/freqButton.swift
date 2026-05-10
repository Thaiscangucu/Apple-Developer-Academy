//
//  freqButton.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 03/02/26.
//

import SwiftUI

struct freqButton: View {
    var num: String
    @State var selected: Bool
    var body: some View {
        Button{
            selected.toggle()
            //select color
        }label: {
                ZStack{
                    Rectangle()
                      .foregroundColor(.clear)
                      .frame(width: 68, height: 46)
                      .cornerRadius(21)
                      .overlay(
                        RoundedRectangle(cornerRadius: 21)
                          .inset(by: 1)
                          .stroke(selected ? .accent : Color(red: 0.86, green: 0.92, blue: 0.94), lineWidth: 2)
                      )
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 58.09091, height: 36)
                        .background(Color(red: 0.86, green: 0.92, blue: 0.94))
                        .cornerRadius(18)
                    Text(num)
                        .font(
                            Font.custom("Qilka", size: 26.18182)
                                .weight(.bold)
                        )
                        .foregroundColor(Color(red: 0.14, green: 0.35, blue: 0.52))

                }
        }
    }
}

