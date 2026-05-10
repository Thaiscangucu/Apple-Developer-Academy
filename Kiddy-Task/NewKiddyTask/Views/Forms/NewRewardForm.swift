//
//  NewTaskForm.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 28/01/26.
//
import SwiftUI
import PhotosUI

//TODO: Verificar se os textfields estão vazios
struct NewRewardForm: View {
    
    var viewModel: CoreDataViewModel
    
    @State var text = ""
    @State var name = ""
    @State var confirmedPassword = ""
    @AppStorage("password") var password: String = ""
    
    @Binding var isShowingSheet: Bool
    @State private var showPopup = false
    
    @State private var symbolsPicker = false
    @State var tempSelectedIcon: String = ""
    let colors: [String] = ["yellowRecompensa", "redRecompensa", "greenRecompensa"]
    let frequencies: [Int] = [1, 2, 3, 5, 10]
    
    @State var selected: Bool = false
    @State var selectedFrequency: Int16 = 0
    @State var selected2: Bool = false
    @State var selectedColor: String = ""
    
    @State var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(alignment: .center){
            
            // Nome da tarefa
            HStack(spacing: 0) {
                ZStack(alignment: .center) {
                    // Makes width grow with content
                    Text(name.isEmpty ? "Título" : name)
                        .font(.custom("Qilka", size: 38))
                        .opacity(0)
                        .padding(.horizontal, 4)
                        .layoutPriority(1)
                    
                    // Título
                    TextField("Título", text: $name)
                        .font(.custom("Qilka", size: 38))
                        .foregroundColor(.textGray)
                        .multilineTextAlignment(.center)
                }
                Text("\(Image(systemName: "pencil.and.outline"))")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.cinza2)
            }
            
            // O que devo fazer
            Text("Quantas vezes vamos fazer essa tarefa?")
                .font(.system(size: 17))
                .fontDesign(.rounded)
                .foregroundColor(.text)
                .padding(.top)
            
            //Botões frequência
            HStack(spacing: 4){
                ForEach(frequencies, id: \.self){ freq in
                    ZStack{
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 68, height: 46)
                            .cornerRadius(21)
                            .overlay(
                                RoundedRectangle(cornerRadius: 21)
                                    .inset(by: 1)
                                    .stroke(selectedFrequency == freq ? Color.accentColor : Color.buttonGray, lineWidth: 2)
                            )
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 58, height: 36)
                            .background(Color(red: 0.86, green: 0.92, blue: 0.94))
                            .cornerRadius(18)
                        
                        Text("\(freq)")
                            .font(.custom("Qilka", size: 26))
                            .foregroundColor(.text)
                    }
                    .onTapGesture {
                        selected.toggle()
                        selectedFrequency = Int16(freq)
                    }
                }
                
            }
            
            // SF symbols
            Text("Escolha um símbolo")
                .fontDesign(.rounded)
                .foregroundColor(Color(red: 0.14, green: 0.35, blue: 0.52))
                .padding(.top, 35)
            Button {
                symbolsPicker.toggle()
            }
            label : {
                if tempSelectedIcon == "" {
                    ZStack{
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 125, height: 29)
                            .cornerRadius(21)
                            .overlay(
                                RoundedRectangle(cornerRadius: 21)
                                    .inset(by: 1)
                                    .stroke(Color(red: 0.86, green: 0.92, blue: 0.94), lineWidth: 2)
                            )
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 117, height: 21)
                            .background(Color(red: 0.86, green: 0.92, blue: 0.94))
                            .cornerRadius(18)
                    }
                    .padding(.top, 5)
                } else {
                    Image(systemName: "\(tempSelectedIcon)")
                        .font(.largeTitle)
                        .foregroundStyle(.gray)
                        .padding(.top, 5)
                }
            }
            .sheet(isPresented: $symbolsPicker) {
                SingleSymbolPicker(tempSelectedIcon: $tempSelectedIcon)
                    .presentationDetents([.height(345)])
                    .interactiveDismissDisabled()
            }
            
            // Color Picker
            Text("Cor desta ficha")
                .foregroundColor(.text)
                .padding(.top, 23)
            HStack{
                ForEach(colors, id: \.self){ color in
                    ZStack{
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 44, height: 44)
                            .cornerRadius(13)
                            .overlay(
                                RoundedRectangle(cornerRadius: 13)
                                    .inset(by: 0.75)
                                    .stroke(selectedColor == color ? Color.accentColor : Color.buttonGray, lineWidth: 1.5)
                            )
                        Rectangle()
                            .frame(width: 38, height: 38)
                            .foregroundStyle(Color(color))
                            .cornerRadius(12)
                    }
                    .onTapGesture {
                        selected2.toggle()
                        selectedColor = color
                    }
                }
            }
            
            // Password
            Text("senha do o(a) cuidador(a)")
                .foregroundColor(.text)
                .padding(.bottom, -6)
                .padding(.top, 52)
            
            //TODO: Receber uma váriavel Binding
            Securefield(input: $confirmedPassword)
            
            // Button
            Button{
                //Check textfiels are empty
                if name.isEmpty || selectedFrequency == 0 || tempSelectedIcon.isEmpty || selectedColor.isEmpty{
                    alertTitle = "Campos Vazios"
                    alertMessage = "Por favor, preencha todos os campos."
                    showAlert.toggle()
                }
                if confirmedPassword == password {

                    viewModel.createRecompensa(title: name, freq: selectedFrequency, symbol: tempSelectedIcon, color: selectedColor)
                    isShowingSheet.toggle()
                    
                    
                } else {
                    alertTitle = "Senhas diferentes"
                    alertMessage = "A confirmação de senha não coincide."
                    showAlert.toggle()
                }
            }
            label:{
                bigButton(text: "concluído", thumbsUp: false)
                    .padding(.top, 5)
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}

