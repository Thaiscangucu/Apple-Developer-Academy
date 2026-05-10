//
//  HistoriaSocialView.swift
//  C8
//
//  Created by Thais Cangucu on 06/11/25.
//

import SwiftUI

//
//  Onboarding.swift
//  POC_Onboarding
//
//  Created by Jonas Fernando Nascimento Melo on 09/10/25.
//

import SwiftUI

struct PageInfo: Identifiable {
    let id = UUID()
    let image: String
    let body: String
}

let pages = [
    PageInfo(image: "ShowerBig", body: "Antes de cortarmos o cabelo, lavamos ele no lavatório. O chuveiro faz um barulho de água, que pode vir ou fria ou morninha!"),
    PageInfo(image: "DryerBig", body: "Após lavar o cabelo, o secador é usado. Ele faz um som alto e solta um vento quentinho."),
    PageInfo(image: "ScissorBig", body: "Como o som da tesoura quando corta o cabelo"),
    PageInfo(image: "Shaver", body: "A máquina de cortar cabelo também pode ser usada para quem quiser deixar o cabelo curtinho!")
]

struct historiaSocial: View {
    //Binding da varivel que verifica se a sheet ja subiu alguma vez
    @Binding var isWelcomeSheetShowing: Bool
    @State var paginaAtual: Int = 0
    var body: some View {
        VStack{
            TabView(selection: $paginaAtual){
                ForEach(pages.enumerated(), id: \.offset){ index, page in
                    Tab(value: index){
                        
                        Text("No cabeleireiro existem muitos sons")
                            .font(.body)
                            .bold()
                            .padding(.vertical, 30)
                        
                        Spacer()
                        
                        Image(page.image)
                            .resizable()
                            .scaledToFit()
                        
                        Text(page.body)
                            .padding()
                            .font(.custom("Nunito-Regular", size: 17))
                            .multilineTextAlignment(.center)
                        Spacer()
                        
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            if paginaAtual == 3 {
                Button {
                    isWelcomeSheetShowing.toggle()
                }
                label: {
                    HStack{
                        Text("Fim")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.vertical, 8)
                    }
                    .foregroundStyle(.darkPurple)
                    .frame(maxWidth: .infinity, maxHeight: 53)
                    .background{
                        RoundedRectangle(cornerRadius: 45)
                            .stroke(Color.darkPurple, lineWidth: 10)
                            .fill(.accentOrange)
                    }
                }
                .tint(.accentOrange)
                .padding(.horizontal)
            }
            else{
                // Botão Continuar
                Button {
                    paginaAtual += 1
                }
                label: {
                    HStack{
                        Image(systemName: "play.fill")
                        Text("Próximo")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.vertical, 8)
                    }
                    .foregroundStyle(.darkPurple)
                    .frame(maxWidth: .infinity, maxHeight: 53)
                    .background{
                        RoundedRectangle(cornerRadius: 45)
                            .stroke(Color.darkPurple, lineWidth: 10)
                            .fill(.accentOrange)
                    }
                }
                
                .tint(.accentOrange)
                .padding(.horizontal)
                
                // Botão de pular
                Button{
                    isWelcomeSheetShowing.toggle()
                }
                label:{
                    HStack{
                        Image(systemName: "square.fill")
                            .foregroundStyle(.accent)
                        Text("Pular")
                            .font(.title3)
                            .foregroundStyle(.accent)
                            .fontWeight(.semibold)
                            .padding(.vertical, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 53)
                    .background{
                        RoundedRectangle(cornerRadius: 45)
                            .stroke(Color.accent, lineWidth: 10)
                            .fill(.white)
                    }
                }
                .tint(.white)
                .padding()
            }
        }
        .onAppear{
            if paginaAtual == 0{
                SoundManager.instance.playSound(sound: .Shower)
            }
        }
        .onChange(of: paginaAtual){
            if paginaAtual == 1{
                SoundManager.instance.playSound(sound: .BlowDryer)
            }
            if paginaAtual == 2{
                SoundManager.instance.playSound(sound: .Scissor)
            }
            if paginaAtual == 3{
                SoundManager.instance.playSound(sound: .Shaver)
            }
        }
        .background(.ambientsBackground)
        //faz com que a sheet nao seja deletada
        .interactiveDismissDisabled()
        //Muda o tipo da tabview
        .tabViewStyle(.page)
        //onAppear que modigica as cores das bolinhas
        .onAppear(){
            UIPageControl.appearance().currentPageIndicatorTintColor = .label
            UIPageControl.appearance().pageIndicatorTintColor = .systemGray
        }
    }
}

#Preview {
    @Previewable @State var isWelcomeSheetShowing = true
    historiaSocial(isWelcomeSheetShowing: $isWelcomeSheetShowing)
}


