//
//  macMamberTeam.swift
//  iOSFront
//
//  Created by anshu Li on 28/08/25.
//

import SwiftUI
///This struct is using to implement a scrollView, with macMemberScroll the struct shows all de  role and respective members.
struct MacMamberTeam: View {
    
    @State var members: [GetUser] = []
    @State var dragMembers: [DragableUser] = []
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    @ObservedObject var macMemberViewModel: MacMemberViewModel = MacMemberViewModel()

    var body: some View {
        ZStack{
            Color.ligthYellow
            Image("Background")
                .resizable()
        ScrollView{
            
                VStack(alignment: .leading){
                    Text("Membros da equipe")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(Color.darkGreen)
                        .padding(.bottom, 25)

                    Text("Admin")
                        .foregroundStyle(Color.darkGreen)
                        .font(.title)
                        .padding(.leading, 56)
                        .fontWeight(.bold)
                        .padding(.bottom, -16)
                    MacScroll(role: "adm", members: $members, dragMembers: $dragMembers, macMemberViewModel: macMemberViewModel)
                        .padding(.leading, 48)
                        .padding(.bottom, 24)

                    
                    Text("Mentores")
                        .foregroundStyle(Color.darkGreen)
                        .font(.title)
                        .padding(.leading, 56)
                        .fontWeight(.bold)
                        .padding(.bottom, -16)
                    MacScroll(role: "mentor", members: $members, dragMembers: $dragMembers, macMemberViewModel: macMemberViewModel)
                        .padding(.leading, 48)
                        .padding(.bottom, 24)

                    
                    Text("Alunos")
                        .foregroundStyle(Color.darkGreen)
                        .font(.title)
                        .padding(.leading, 56)
                        .fontWeight(.bold)
                        .padding(.bottom, -16)
                    MacScroll(role: "student", members: $members, dragMembers: $dragMembers, macMemberViewModel: macMemberViewModel)
                        .padding(.leading, 48)
                        .padding(.bottom, 24)

                }
                .padding()
            }
        }
        .onReceive(timer){ _ in
            Task{
                do{
                    members = try await RoutesRequisition.getUsers()
                }
                catch{
                    print(error.localizedDescription)
                }
                
                for member in members{
                    dragMembers.append(DragableUser(name: member.name, email: member.email, password: member.password, id: member.id, role: member.role))
                }
            }
        }
        .background(Color.white)
        .toolbar{
            Button{
                macMemberViewModel.deleteMember(members: &dragMembers)
                print("member: ",dragMembers)
            }
            label: {
                Image(systemName: "trash")
                    .foregroundStyle(Color.red)
            }
        }
    }
}
    
#Preview {
    MacMamberTeam()
}
