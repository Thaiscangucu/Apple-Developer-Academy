//
//  ContentView.swift
//  Challenge8
//
//  Created by Thaissaura on 09/10/25.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationStack{
            ZStack{
                Image("canos")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 290)
                VStack{
                    HStack{
                        NavigationLink{
                            AmbientView(background: "bkg", objetos: ["Scissor", "Shaver","BlowDryer","Shower"], ambiente: "Barber")
                        }label:{
                            AmbientComponent(icon: "scissors", title: "cabeleireiro")
                        }
                        Spacer()
                    }
                    
                    HStack{
                        Spacer()
                        NavigationLink{
                            AmbientView(background: "Airport", objetos: [ "Luggage","Speaker","Plastic","Airplane"], ambiente: "Airport")
                        }label:{
                            AmbientComponent(icon: "airplane", title: "aeroporto")
                        }
                    }
                    .offset(y: -45)
                    
                    HStack{
                        ZStack{
                            AmbientComponent(icon: "", title: "")
                            Text("Em Breve")
                                .fontWeight(.heavy)
                                .foregroundStyle(.white)
                        }
                        Spacer()
                    }
                    .offset(y: 10)
                    
                    HStack{
                        Spacer()
                        ZStack{
                            AmbientComponent(icon: "", title: "")
                            Text("Em Breve")
                                .fontWeight(.heavy)
                                .foregroundStyle(.white)
                        }
                    }
                    .offset(y: 40)
                    HStack{
                        ZStack{
                            AmbientComponent(icon: "", title: "")
                            Text("Em Breve")
                                .fontWeight(.heavy)
                                .foregroundStyle(.white)
                        }
                        Spacer()
                    }
                    .offset(y:50)
                    Spacer()
                }
                .padding(50)
                .frame(width: 460)
                //Navigation's title
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Ambientes")
                            .font(.custom("Nunito-Bold", size: 34))
                            .offset(x: -101, y: 30)
                    }
                }
            }
            .background(.ambientsBackground)
        }
    }
}

#Preview{
    ContentView()
}



