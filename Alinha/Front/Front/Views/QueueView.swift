//
//  PickerMentorAluno.swift
//  iOSFront
//
//  Created by anshu Li on 27/08/25.
//
import SwiftUI
import SwiftData

///View for select the role on iOS
/// - Parameter role: Var for user role filter
struct QueueView: View {
    @Query var user: [User]
    let timer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    @State var cards: [GetAppointments] = []
    @Binding var path: NavigationPath
    var body: some View {
        VStack{
            if !cards.isEmpty {
                if user.first?.role == "mentor" {
                    PickerCategory(path: $path, cards: $cards, student: false)
                }
                else if user.first?.role == "student" {
                    PickerCategory(path: $path, cards: $cards, student: true)
                }
                else if user.first?.role == "adm" {
                    PickerCategory(path: $path,cards: $cards, student: false)
                }
            }
            else {
                ProgressView()
            }
            
        }
        .onReceive(timer){_ in
            Task {
                do {
                    cards = try await RoutesRequisition.getAppointments()
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    QueueView(path: $path)
}
