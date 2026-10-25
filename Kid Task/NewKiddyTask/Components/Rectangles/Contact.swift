//
//  Contact.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 04/02/26.
//

import SwiftUI

struct Contact: View {
    var person: Person
    @Binding var isOpen: Bool
    var body: some View {
        if isOpen{
            HStack{
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 49, height: 39)
                    .background(.white)
                    .cornerRadius(10)
                VStack(alignment: .leading){
                    Text(person.name)
                        .font(.custom("Qilka", size: 18)
                            .weight(.bold)
                        )
                        .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                    Text(person.cargo)
                        .font(.system(size: 12))
                        .fontWeight(.light)
                        .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                }
                Spacer()
                Group{
                    Image(systemName: "phone.fill")
                    Image(systemName: "envelope.fill")
                }
                .foregroundColor(Color(red: 0.53, green: 0.67, blue: 0.73))
                .font(.system(size: 25))
            }
            .padding()
            .frame(width: 323, height: 60)
            .background{
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 323, height: isOpen ? 137 : 60)
                    .background(Color(red: 0.76, green: 0.86, blue: 0.88))
                    .cornerRadius(20)
                    .opacity(0.56)
            }
        }
        else{
            HStack{
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 49, height: 39)
                    .background(.white)
                    .cornerRadius(10)
                VStack(alignment: .leading){
                    Text(person.name)
                        .font(.custom("Qilka", size: 18)
                            .weight(.bold)
                        )
                        .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                    Text(person.cargo)
                        .font(.system(size: 12))
                        .fontWeight(.light)
                        .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                }
                Spacer()
                Group{
                    Image(systemName: "phone.fill")
                    Image(systemName: "envelope.fill")
                }
                .foregroundColor(Color(red: 0.53, green: 0.67, blue: 0.73))
                .font(.system(size: 25))
            }
            .onTapGesture {
                isOpen.toggle()
            }
            .padding()
            .frame(width: 323, height: 60)
            .background{
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 323, height: 60)
                    .background(Color(red: 0.76, green: 0.86, blue: 0.88))
                    .cornerRadius(20)
                    .opacity(0.56)
            }
            
        }
    }
}

//#Preview {
//    Contact()
//}
