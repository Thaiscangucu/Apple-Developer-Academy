import SwiftUI
import PhotosUI

struct LoadingView: View {
    
    @State var classificationLabel: String = ""
    @State var pickerImage: PhotosPickerItem?
    @State var selectedImage: UIImage?
    var coreMLViewModel: CoreMLViewModel = CoreMLViewModel()
    @State var isShowingSheet = false
    
    var body: some View {
        ZStack{
            VStack{
                Text("Coloque aqui uma foto sua\n para lermos suas emoções\n e te indicarmos uma música\n da Taylor Swift")
                    .multilineTextAlignment(.center)
                    .font(.title2)
                PhotosPicker(selection: $pickerImage,
                             matching: .images)
                {
                    ZStack{
                        RoundedRectangle(cornerRadius: 25)
                            .frame(width: 170, height:170)
                            .foregroundColor(Color("vinho"))
                        Image(systemName: "photo.on.rectangle")
                            .foregroundColor(.white)
                            .font(.system(size:80))
                    }
                }
            }
            .padding()
            .onChange(of: pickerImage) { oldValue, newValue in
                Task {
                    guard let imageData = try await pickerImage?.loadTransferable(type: Data.self) else { return }
                    guard let inputImage = UIImage(data: imageData) else { return }
                    selectedImage = inputImage
                    classificationLabel = coreMLViewModel.checkImage(selectedImage!)
                }
            }
            .onChange(of: selectedImage, { oldValue, newValue in
                isShowingSheet = true
            })
            .sheet(isPresented: $isShowingSheet){
                ResultPage(selectedImage: $selectedImage, classificationLabel: $classificationLabel)
                    .presentationDetents([.fraction(1.00), .fraction(1.00)])
            }
        }
        .ignoresSafeArea(.all)
    }
}


#Preview {
    LoadingView()
}
