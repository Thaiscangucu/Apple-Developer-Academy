//
//  MacMemberViewModel.swift
//  macOSFront
//
//  Created by João Pedro Pioltini de Oliveira on 29/08/25.
//

import Foundation
import CoreTransferable

struct DragableUser: Identifiable, Codable, Transferable {
    
    static var transferRepresentation: some TransferRepresentation{
        CodableRepresentation(contentType: .vCard)
    }
    var name: String
    var email: String
    var password: String
    var id: UUID
    var role: String
    
    init(name: String, email: String, password: String, id: UUID, role: String) {
        self.name = name
        self.email = email
        self.password = password
        self.id = id
        self.role = role
    }
}

class MacMemberViewModel: ObservableObject{
    @Published var selectedID: [UUID] = []
    
    func toggleMember(member: DragableUser){
        if selectedID.contains(member.id){
            selectedID.removeAll{ $0 == member.id}
        } 
        else{
            selectedID.append(member.id)
        }
        print(selectedID)
    }
    
    func deleteMember(members: inout [DragableUser]){
        members.removeAll{ member in
            selectedID.contains(member.id)
            
        }
    }
}


