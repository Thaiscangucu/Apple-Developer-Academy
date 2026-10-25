//
//  TaskView.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 03/02/26.
//

import SwiftUI
import PhotosUI


//TODO: Verificar se os textfields estão vazios
struct TaskView: View {
    @State var confirmedPassword = ""
    @State var incorrectPassword = false
    @AppStorage("password") var password: String = ""
    
    var viewModel: CoreDataViewModel
   
    @ObservedObject var task: Tarefa
    
    @Binding var sheet: Bool
    @State private var pickerImage: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showActionSheet = false
    @State private var showCamera = false
    @State private var showPhotosPicker = false
    
    @State var difficulty = "fácil"
    let options = ["fácil", "médio", "difícil"]
    
    var body: some View {
        VStack(alignment: .center){
            
            // Nome da tarefa
            HStack(alignment: .center){
                Text("Olá cuidador(a)!!")
                    .font(.custom("Qilka", size: 38))
                    .bold()
                    .frame(width: 323, alignment: .topLeading)
                    .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
            }
            Text("Nossa criança cumpriu essa tarefa?")
                .font(.system(size: 20))
                .foregroundColor(.text)
                .fontDesign(.rounded)
                .fontWeight(.medium)
                .padding(.bottom, 27)
            
            Text("Como foi o desempenho da nossa criança?")
                .font(.system(size: 17))
                .foregroundColor(.text)
                .fontDesign(.rounded)
//                .padding(.bottom, 39)
            
            Picker("", selection: $difficulty) {
                ForEach(options, id: \.self) { symbol in
                    Text(symbol)
                        .tag(symbol)
                }
            }
            .pickerStyle(.menu)
            .tint(.text)
            .background{
                Rectangle()
                    .foregroundColor(Color(red: 0.92, green: 0.96, blue: 0.96))
                    .frame(width: 100, height: 44)
                    .cornerRadius(13)
            }
            .padding(.bottom)
        
            
            Text("foto do depois ")
                .font(.system(size: 17))
                .foregroundColor(.text)
                .fontDesign(.rounded)
            
            // Image Picker
            Button {
                showActionSheet = true
            }
            label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.86, green: 0.92, blue: 0.94))
                        .frame(width: 269, height: 231)
                    
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 269, height: 231)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    } else {
                        Image("imagePicker") // Your icon
                            .resizable()
                            .frame(width: 62, height: 48)
                    }
                }
            }
            .confirmationDialog("Selecione uma foto", isPresented: $showActionSheet) {
                Button("Camera") { showCamera = true }
                Button("Galeria de fotos") { showPhotosPicker = true }
                Button("Cancelar", role: .cancel) { }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker(selectedImage: $selectedImage)
            }
            .photosPicker(isPresented: $showPhotosPicker, selection: $pickerImage, matching: .images)
            .onChange(of: pickerImage) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                        if let selectedImage = selectedImage {
                            task.picAfter = selectedImage.jpegData(compressionQuality: 0.8)
                        } else {
                            task.picAfter = nil
                        }
                    }
                }
            }
            
            // Password
            Text("senha do o(a) cuidador(a)")
                .foregroundColor(.text)
                .padding(.bottom, -6)
                .padding(.top, 52)
            
            Securefield(input: $confirmedPassword)
            
            Text(incorrectPassword ? "Senha incorreta" : "")
                .font(.system(size: 10))
                .foregroundStyle(.red)
                .padding(.bottom, 5)
            
            // Button
            Button{
                //                        viewModel.createTask(taskDate: date, imageAfter: imageAfter ?? UIImage(), imageBefore: imageBefore ?? UIImage(), isDone: false, name: "", taskTime: time)
                if confirmedPassword != password{
                    incorrectPassword.toggle()
                }
                else{
                    viewModel.taskToggle(task)
                    viewModel.getTarefas()
                    sheet.toggle()
                    
                }
            }
            label:{
                ZStack{
                    Image("RecButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 285)
                    Text("concluído!")
                        .font(.custom("Qilka", size: 28))
                        .foregroundColor(Color(red: 0.63, green: 0.8, blue: 0.83))
                        .frame(width: 139, height: 27, alignment: .topLeading)
                }
                .padding(.top, 20)
            }
            .ignoresSafeArea(.keyboard)
            
        }
    }
}


