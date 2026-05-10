//
//  MacMember.swift
//  iOSFront
//
//  Created by anshu Li on 28/08/25.
//

import Foundation
import SwiftUI

///This is a identifiable struct
struct MacMember: Identifiable, Transferable, Codable{
    
    
    let id: Int
    var name: String
    var role: String
    static var transferRepresentation: some TransferRepresentation{
        CodableRepresentation(contentType: .vCard)
    }
}
/// members list

