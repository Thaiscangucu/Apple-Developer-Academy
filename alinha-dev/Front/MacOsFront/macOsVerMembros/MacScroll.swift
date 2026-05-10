//
//  macMemberScroll.swift
//  iOSFront
//
//  Created by anshu Li on 28/08/25.
//

import SwiftUI
import SwiftData
/// This struct filtered the member about his role, listed all member respective
///  - Parameter role: this atribute used to filter array `members` with same role
struct MacScroll: View {
    var role: String
    
    @Binding var members: [GetUser]
    @Binding var dragMembers: [DragableUser] 
    @State var memberIsTargeted = false
    @ObservedObject var macMemberViewModel: MacMemberViewModel 
    
    @Query var userMac: [User]

    func countRole(role: String) -> Int {
        members.filter { $0.role.caseInsensitiveCompare(role) == .orderedSame }.count
    }
    
    var body: some View {
        ScrollView(.horizontal){
            HStack{
                if countRole(role: role) != 0 {
                    ForEach($dragMembers, id: \.id){ $member in
                        if member.role == role {
                            PersonComponent(member: member, isPressed: macMemberViewModel.selectedID.contains(member.id), isDefault: false)
                                .draggable(member)
                                .dropDestination(for: DragableUser.self){ items, _ in
                                    for dropped in items {
                                        if let i = members.firstIndex(where: { $0.id == dropped.id }) {
                                            if countRole(role: "adm") != 1 || dropped.role != "adm" {
                                                Task{
                                                    do{
                                                        let user = PatchUserUpdateRole(id: members[i].id, role: role)

                                                        let _ = try await RoutesRequisition.PatchUsersUpdateRole(object: user, auth: userMac.first!.authID)
                                                        
                                                    }
                                                    catch{
                                                        print(error.localizedDescription)
                                                    }
                                                }
                                                
                                            }
                                        }
                                    }
                                    return true
                                } isTargeted: { isTarget in
                                    memberIsTargeted = isTarget
                                }
                                .onTapGesture {
                                    macMemberViewModel.toggleMember(member: member)
                                }
                        }
                    }
                }
                else {
                    PersonComponent(member: DragableUser(name: "", email: "", password: "", id: UUID(), role: ""), isPressed: macMemberViewModel.selectedID.contains(UUID()), isDefault: true)
                        .dropDestination(for: DragableUser.self) {items, _ in
                            for dropped in items {
                                if let i = members.firstIndex(where: { $0.id == dropped.id }) {
                                    members[i].role = role
                                }
                            }
                            return true
                        }
                }
            }
            .background(.white)
            .clipShape(
                RoundedRectangle(cornerRadius: 24)
            )
            .padding(.vertical)
        }
    }
}

//#Preview {
//    @Previewable @State var members: [GetUser] = []
//    MacScroll(role: "adm", members: $members)
//}
