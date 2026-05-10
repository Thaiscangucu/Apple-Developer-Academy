//
//  TvQueueView.swift
//  tvOSFront
//
//  Created by Thais Cangucu on 29/08/25.
//

import SwiftUI

///a SwiftUI view that has the tvOS queue visualization and the window of the current student being attended.
///
///It fetches the students from the data set and through a ForEach, creates a Button for each student in a Scroll View.
///
///
///```swift
///ForEach(decoded_data) { usuario in
///    ZStack{
///        Button{
///        }
///       label:{
///            Text("\(usuario.name)")
///                .font(.largeTitle)
///                .foregroundStyle(.white)
///        }
///    }
///}
///```
/// Using a timer component,  the students are fetched from the data set and stored in the array ``decoded_data``
///```swift
///.onReceive(timer) { _ in
///     Task {
///         let (data, _)  = try await Requester.sendRequest(to:  "http://10.44.48.31:8080/users", method: .GET, headers: ["Content-Type":"application/json"], body: nil)
///         do {
///             decoded_data = try decode(data: data, objeto: decoded_data)
///             for aluno in decoded_data {
///                 print(aluno.name)
///             }
///         } catch {
///             print("erro supremo")
///         }
///     }
///}
///```
struct TvQueueView: View {
    
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var appointments: [GetAppointments] = []
    
    var body: some View {
        ZStack{
            Color.backgroundBeige
            Image("Background")
                .resizable()
                .scaledToFill()
            
            HStack(alignment: .top){
                    VStack(spacing: 38){
                        LastStudentCard(appointments: $appointments)
                        AvaliableMentors(appointments: $appointments)
                    }
                //TODO: se a fila ficar muito grande os objetos vao passar do limite da tela
                    VStack{
                        HStack(alignment: .top){
                            // 3 Code/Design/Other Queues
                            CodeQueueView(path: "code", appointments: $appointments)
                            DesignQueueView(path: "design", appointments: $appointments)
                            OtherQueueView(path: "undefined", appointments: $appointments)
                        }
                        // If there's no one in the queue Merfino shows up
                        if appointments.isEmpty{
                            Spacer()
                            Text("Parece que não tem\nninguém aqui ainda...")
                                .font(.system(size: 40, weight: .regular))
                                .foregroundColor(Color(red: 0.51, green: 0.51, blue: 0.51))
                            Image("Merfino")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 400)
                        }
                        Spacer()
                    }
                    .frame(height: 1000)
                }
        }
        // Fetch data every second from server
        .onReceive(timer) { _ in
            Task {
                do {
                    appointments  = try await RoutesRequisition.getAppointments()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}


#Preview {
    TvQueueView()
}



