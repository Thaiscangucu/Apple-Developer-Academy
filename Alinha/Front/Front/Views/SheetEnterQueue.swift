import SwiftUI
import SwiftData

/// View that alows the user to get on the line, by writing a description and selecting a role and a problem that needs to be solved.
/// - Parameter description: It's the variable that gets the user's description.
/// - Parameter role: It's the array that shows to the user the roles that can be selected by the picker.
/// - Parameter problem: It's the array that shows to the user the category problems that can be selected by the picker.
/// - Parameter selectRole: It's the variable that gets the chosen role and shows on the picker, alowing the view for the user.
/// - Parameter selectProblem: It's the variable that gets the chosen category problem and shows on the picker, alowing the view for the user.
/// - Parameter name: It's the variable that shows the user's name on the card.
struct SheetEnterQueue: View {
    @Query var user: [User]
    @Environment(\.dismiss) var dismiss
    @Binding var isClicked: Bool
    @State var path: String = ""
    @State var type: String = ""
    @State var description: String = ""
    @StateObject private var push = PushManager.shared
    
    var role = ["code", "design", "undefined"]
    var problem = ["doubt", "problem"]
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Descreva aqui, em poucas palavras, a sua dúvida", text: $description, axis: .vertical)
                    .multilineTextAlignment(.leading)
                    .lineLimit(8)
                    .padding(.horizontal, 20)
                
                List {
                    Section {
                        Picker("Dúvida", selection: $type) {
                            ForEach(problem, id: \.self) { i in
                                Text(i)
                            }
                        }
                        Picker("Categoria", selection: $path) {
                            ForEach(role, id: \.self) { i in
                                Text(i)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                    .bold()
                }
                .scrollContentBackground(.hidden)
            }
            .padding()
            .toolbar {
                ToolbarItem {
                    Button {
                        Task {
                            print("Esse é o token  que vai ser mandado: " + push.deviceTokenHex!)
                            let _ = try await RoutesRequisition.postAppointments(object: PostAppointments(mentor: "", student: user.first!.id.uuidString, token: push.deviceTokenHex!, appointmentPlace: "asd", description: description, type: type, path: path))
                        }
                        isClicked.toggle()
                        dismiss()
                    } label: {
                        Text("Criar")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                }
            }
        }
    }
}

#Preview{
    @Previewable @State var isClicked = false
    SheetEnterQueue(isClicked: $isClicked)
}
