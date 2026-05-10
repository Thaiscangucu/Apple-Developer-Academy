import SwiftUI
import SwiftData
/// View for showing the students queue on macOS
/// - Parameter person: this is a array of person properties
/// - Parameter pathSelected: this path that selected by user
/// - Parameter calledPersonCode: this is a Code Person that called by mentor
/// - Parameter calledPersonDesign: this is a Design Person that called by mentor
/// - Parameter calledPersonOther: this is a Other Person that called by mentor
/// - Parameter role: this role that selected by user
struct MacQueueUserView: View {
    
    @Query var userMac: [User]

    @Binding var appointments: [GetAppointments]
    @State private var pathSelected = 0
    
    var body: some View {
        VStack{
            HStack{
                Text("Fila de Perguntas")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.darkGreen)
                Spacer()
            }
            .padding()
            
            Picker("", selection: $pathSelected) {
                Text("Código").tag(0)
                Text("Design").tag(1)
                Text("Outros").tag(2)
            }
            .pickerStyle(.segmented)
            .colorMultiply(.picker)
            .colorScheme(.light)
            .padding(.horizontal)

            if pathSelected == 0 {
                ListHeaderView(appointments: $appointments, pathSelected: "Código")
            }
            else if pathSelected == 1 {
                ListHeaderView(appointments: $appointments, pathSelected: "Design")
            }
            else {
                ListHeaderView(appointments: $appointments, pathSelected: "Outros")
                
            }
            Spacer()
        }
    }
}

#Preview {
    @Previewable @State var appointments: [GetAppointments] = []
    MacQueueUserView(appointments: $appointments)
}








