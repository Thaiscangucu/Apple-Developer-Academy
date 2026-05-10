//
//  NewTaskForm.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 28/01/26.
//
import SwiftUI
import PhotosUI

//TODO: Verificar se os textfields estão vazios

struct NewTaskForm: View {
    
    @State var description = ""
    @State var taskName = ""
    @State var date = Date.now
    @State var selectedSymbols: [String] = []
    @State var selectedColor: String = ""
    @State private var selectedImage: String = ""
    @State var confirmedPassword = ""
    @AppStorage("password") var password: String = ""
    
    @State var selected: Bool = false
    
    @State private var symbolsPicker = false
    @State var tempSelectedIcon: String = ""
    @State private var scrollID: String?
    
    @State var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    
//    var colors: [Color] = [.blueTask, .pinkTask, .greenTask, .purpleTask, .yellowTask, .redTask]
    var colors: [String] = ["blueTask", "pinkTask", "greenTask", "purpleTask", "yellowTask", "redTask"]
    var images: [String] = ["bedroom"]
    
    @Binding var isShowingSheet: Bool
    @State private var showPopup = false
    
    var viewModel: CoreDataViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack(alignment: .center){
                
                // Nome da tarefa
                HStack(alignment: .center, spacing: 0){
                    TextField("Nome da tarefa", text: $taskName)
                        .font(.custom("Qilka", size: 38))
                        .bold()
                        .multilineTextAlignment(.center)
                        .frame(width: 300)
                        .foregroundColor(.textGray)
                    Image(systemName: "pencil.and.outline")
                        .font(.title)
                        .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                }
                .padding(.top)
                .frame(width: 370)
                
                // O que devo fazer
                Text("O que devo fazer?")
                    .fontDesign(.rounded)
                    .fontWeight(.medium)
                    .foregroundColor(.text)
                    .padding(.top, 14)
                Textfield2(input: $description)
                
                // Data e SF symbols
                HStack(spacing: 20){
                    VStack(spacing: 5){
                        Text("quando fazer?")
                            .fontDesign(.rounded)
                            .foregroundColor(.text)
                        ZStack{
                            DatePicker("", selection: $date, displayedComponents: [.date])
                                .background{
                                    RoundedRectangle(cornerRadius: 22)
                                        .foregroundStyle(Color(red: 0.8, green: 0.87, blue: 0.89))
                                }
                        }
                    }
                    .frame(width: 125)
                    
                    // Picker Símbolos
                    VStack(spacing: 5){
                        Text("símbolos (\(selectedSymbols.count)/3)")
                            .fontDesign(.rounded)
                            .foregroundColor(Color(red: 0.14, green: 0.35, blue: 0.52))
                        
                        Button {
                            symbolsPicker.toggle()
                        }
                        label : {
                            if tempSelectedIcon == "" {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 125, height: 29)
                                    .background(Color(red: 0.8, green: 0.87, blue: 0.89))
                                    .cornerRadius(22)
                            } else {
                                ForEach(selectedSymbols, id: \.self){ symbol in
                                    HStack{
                                        Image(systemName: "\(symbol)")
                                            .font(.title)
                                            .foregroundStyle(.gray)
                                            .padding(.top, 5)
                                    }
                                }
                            }
                        }
                        .sheet(isPresented: $symbolsPicker) {
                            SymbolsPickerView(tempSelectedIcon: $tempSelectedIcon, selectedSymbols: $selectedSymbols)
                                .presentationDetents([.height(345)])
                                .interactiveDismissDisabled()
                        }
                    }
                    .frame(width: 139)
                }
                
                // Image Picker
                Text("tipo da tarefa")
                    .fontDesign(.rounded)
                    .foregroundColor(.text)
                    .padding(.top, 23)
                ZStack {
                    VStack(spacing: 10) {
                        if selectedImage == "" {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: 269, height: 131)
                                    .foregroundStyle(Color(red: 0.86, green: 0.92, blue: 0.94))
                                Image("imagePicker")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 62, height: 48)
                            }
                            .onTapGesture {
                                withAnimation { showPopup = true }
                            }
                        }
                        
                        if showPopup {
                            VStack {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 0) {
                                        ForEach(images, id: \.self) { img in
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(Color.clear) // Mantém o fundo limpo para a imagem
                                                Image(img)
                                                    .resizable()
                                                    .scaledToFit()
                                            }
                                            .frame(width: 269, height: 131)
                                            .id(img)
                                        }
                                    }
                                    .scrollTargetLayout()
                                }
                                .scrollPosition(id: $scrollID)
                                .scrollTargetBehavior(.paging)
                                .frame(width: 269, height: 131)
                                .background(Color(red: 0.86, green: 0.92, blue: 0.94))
                                .cornerRadius(20)
                                HStack(spacing: 8) {
                                    ForEach(images, id: \.self) { img in
                                        Circle()
                                            .fill(scrollID == img ? Color.blue : Color.gray.opacity(0.4))
                                            .frame(width: 8, height: 8)
                                            .animation(.spring(), value: scrollID)
                                    }
                                }
                                .padding(.top, 8)
                            }
                            .onChange(of: scrollID) { _, newValue in
                                if let newValue {
                                    selectedImage = newValue
                                }
                            }
                            .onAppear {
                                if let firstImage = images.first {
                                    scrollID = firstImage
                                    selectedImage = firstImage
                                }
                            }
                        }
                    }
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
                            selected.toggle()
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
                    if taskName.isEmpty || description.isEmpty || selectedSymbols.isEmpty || selectedImage.isEmpty || selectedColor.isEmpty  {
                        alertTitle = "Campos Vazios"
                        alertMessage = "Por favor, preencha todos os campos."
                        showAlert.toggle()
                    } else {
                        if confirmedPassword == password {
                                viewModel.createTarefa(title: taskName, desc: description, done: false, image: selectedImage, symbols: selectedSymbols, color: selectedColor, date: date, picAfter: UIImage())
                                isShowingSheet.toggle()
                            
                        } else {
                            alertTitle = "Senhas diferentes"
                            alertMessage = "A confirmação de senha não coincide."
                            showAlert.toggle()
                        }
                    }
                    
                }
                label:{
                    bigButton(text: "concluído", thumbsUp: false)
                        .padding(.top, 20)
                }
                
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}
