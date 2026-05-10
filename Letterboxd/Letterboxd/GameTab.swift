import SwiftUI


struct GameTab: View {
    let rectWidth: CGFloat = 125
    let rectHeight: CGFloat = 175

    var body: some View {
        GeometryReader{ i in
            
            ZStack{
                Image("tlou-background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
            }

            ZStack{
                Rectangle()
                    .frame(width: 850, height: 100)
                    .position(x: 1, y: 307)
                    .foregroundStyle(.black)
                    .blur(radius: 30)
                
                VStack{
                    HStack{
                        HStack{
                            VStack{
                                Text("The Last Of Us")
                                    .bold()
                                    .font(.title3)
                                    .padding(.bottom)
                                
                                Text("2013•CREATED BY")
                                    .font(.caption2)
                                    .padding(.trailing, 33)
                                
                                Text("Naughty Dog")
                                    .bold()
                                    .font(.subheadline)
                                    .padding(.trailing, 38)
                                HStack{
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 5)
                                            .frame(width: 95, height: 25)
                                            .padding()
                                            .foregroundStyle(.otherGray)
                                        HStack{
                                            Label("", systemImage: "play.fill")
                                            Text("TRAILER")
                                                .font(.caption)
                                                .bold()
                                        }
                                        .foregroundStyle(.gray)
                                    }
                                    .padding(.leading, 30)
                                    Text("PlayStation")
                                        .font(.caption)
                                }
                            }
                            
                            .padding(.top, -20)
                            .padding(.leading, -40)
                        }
                        .padding(.top, 55)
                        Spacer()
                        Image("tlou")
                            .resizable()
                            .frame(width: rectWidth, height: rectHeight)
                            .shadow(radius: 3)
                            .cornerRadius(3)
                            .border(.gray)
                            .cornerRadius(3)
                            .padding(.top)
                    }
                    .padding(3)
                    Text("Na história, os jogadores controlam Joel, um homem encarregado de escoltar uma adolescente chamada Ellie através de um Estados Unidos pós-apocalíptico. The Last of Us é jogado a partir de uma perspectiva em terceira pessoa, com os jogadores usando armas improvisadas e furtividade a fim de defenderem-se de humanos hostis e criaturas canibalísticas infectadas por uma mutação do Cordyceps.")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .padding(.leading, 10)
                    Rectangle()
                        .frame(width: 400, height: 1)
                    Text("RATINGS")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .padding(.leading, -190)
                    HStack{
                        VStack{
                            Spacer()
                            Label("", systemImage: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.accent)
                        }
                        BarChart(borderWidth: 25)
                        .padding(.top)
                        VStack{
                            Spacer()
                            Text("5.0")
                                .font(.title3)
                                .fontWeight(.light)
                           FiveStars()
                                .foregroundStyle(.accent)
                                .padding(.leading)
                        }
                    }
                    .padding()
                }
                .padding(.top, 203)
            }
        }
    }
}
