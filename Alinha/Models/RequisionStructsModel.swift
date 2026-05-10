//
//  RequisionStructs.swift
//  Front
//
//  Created by Vinicius Alves Marques on 01/09/25.
//
import Foundation

//MARK: Users

struct GetUser : Codable{
    var name: String
    var email: String
    var password: String
    var id: UUID
    var role: String
    
    init(){
        self.name = ""
        self.email = ""
        self.password = ""
        self.id = UUID()
        self.role = ""
    }
}

struct PostUser : Codable{
    var name: String
    var email: String
    var password: String
    var confirmedPassword: String
    var role: String
    
    init(name: String, email: String, password: String, confirmedPassword: String, role: String) {
        self.name = name
        self.email = email
        self.password = password
        self.confirmedPassword = confirmedPassword
        self.role = role
    }
}

struct PostUserResponse : Codable {
    var id : UUID
    var email : String
    
    init() {
        self.id = UUID()
        self.email = ""
    }
}

struct PatchUserUpdateName : Codable {
    var id : UUID
    var name : String
    
    init(id: UUID, name: String) {
        self.id = id
        self.name = name
//    init() {
//        self.id = UUID(uuidString: "839FE942-4FFB-4890-8080-5927FF477381")!
//        self.name = "blblblblaaaa"
    }
}



struct PatchUserResponseUpdateName : Codable{
    var id: UUID
    var name: String
    var email: String
    var password: String
    var role: String
    
    init() {
        self.id = UUID()
        self.name = ""
        self.email = ""
        self.password = ""
        self.role = ""
    }
}

struct PatchUserUpdateRole : Codable {
    var id : UUID
    var role : String
    
    init(id: UUID, role: String) {
        self.id = id
        self.role = role
    }
    init() {
        self.id = UUID(uuidString: "EE05CEF6-DBD0-4E9D-B5BC-90F62C4DC444")!
        self.role = "student"
    }
}

struct PatchUserResponseUpdateRole : Codable{
    var id: UUID
    var name: String
    var email: String
    var password: String
    var role: String
    
    init() {
        self.id = UUID()
        self.name = ""
        self.email = ""
        self.password = ""
        self.role = ""
    }
}

//MARK: Users

//MARK: Agendamento

struct GetAppointments : Codable{
    var id : UUID
    var mentor : String
    var student : UUID
    var studentName : String
    var description : String
    var appointmentPlace: String
    var isScheduled: Bool
    var callStudent: Bool
    var isDone: Bool
    var createdAt: String
    var type: String
    var path: String
    
    init() {
        self.id = UUID()
        self.mentor = String()
        self.student = UUID()
        self.studentName = String()
        self.description = ""
        self.appointmentPlace = ""
        self.isScheduled = false
        self.callStudent = false
        self.isDone = false
        self.createdAt = String()
        self.type = ""
        self.path = ""
    }
}

struct PostAppointments : Codable{
    var mentor : String
    var student : String
    var deviceToken: String
    var appointmentPlace : String
    var description : String
    var type : String
    var path : String
    
    init(mentor: String, student: String, token: String, appointmentPlace: String, description: String, type: String, path: String) {
        self.mentor = mentor
        self.student = student
        self.deviceToken = token
        self.appointmentPlace = appointmentPlace
        self.description = description
        self.type = type
        self.path = path
    }
    
    init() {
        self.mentor = ""
        self.student = ""
        self.deviceToken = ""
        self.appointmentPlace = ""
        self.description = ""
        self.type = ""
        self.path = ""
    }
}

struct PostAppointmentsResponse : Codable{
    var id : UUID
    var mentor : UUID
    var student : UUID
    var description : String
    var appointmentPlace: String
    var isScheduled: Bool
    var callStudent: Bool
    var isDone: Bool
    var createdAt: String
    var type: String
    var path: String
    
    init() {
        self.id = UUID()
        self.mentor = UUID()
        self.student = UUID()
        self.description = ""
        self.appointmentPlace = ""
        self.isScheduled = false
        self.callStudent = false
        self.isDone = false
        self.createdAt = ""
        self.type = ""
        self.path = ""
    }
}

struct PatchAppointmentsPlace : Codable{
    var appointmentId: UUID
    var appointmentPlace: String
}

struct PatchAppointmentsPlaceResponse : Codable{
    var id : UUID
    var mentor : UUID
    var student : UUID
    var description : String
    var appointmentPlace: String
    var isScheduled: Bool
    var callStudent: Bool
    var isDone: Bool
    var createdAt: String
    var type: String
    var path: String
    
    init() {
        self.id = UUID()
        self.mentor = UUID()
        self.student = UUID()
        self.description = ""
        self.appointmentPlace = ""
        self.isScheduled = false
        self.callStudent = false
        self.isDone = false
        self.createdAt = ""
        self.type = ""
        self.path = ""
    }
}

struct PatchAppointmentsIsSchedule : Codable{
    var appointmentId: UUID
    var isScheduled: Bool
}

struct PatchAppointmentsIsScheduleResponse : Codable{
    var id : UUID
    var mentor : UUID
    var student : UUID
    var description : String
    var appointmentPlace: String
    var isScheduled: Bool
    var callStudent: Bool
    var isDone: Bool
    var createdAt: String
    var type: String
    var path: String
    
    init() {
        self.id = UUID()
        self.mentor = UUID()
        self.student = UUID()
        self.description = ""
        self.appointmentPlace = ""
        self.isScheduled = false
        self.callStudent = false
        self.isDone = false
        self.createdAt = ""
        self.type = ""
        self.path = ""
    }
}

struct PatchAppointmentsCallStudent : Codable{
    var appointmentId: UUID
    var callStudent: Bool
}

struct PatchAppointmentsCallStudentResponse: Codable{
    var id: UUID
    var mentor: UUID
    var student: UUID
    var description : String
    var appointmentPlace:String
    var isScheduled: Bool
    var callStudent: Bool
    var isDone: Bool
    var createdAt: String
    var type: String
    var path:String
    
    init() {
        self.id = UUID()
        self.mentor = UUID()
        self.student = UUID()
        self.description = ""
        self.appointmentPlace = ""
        self.isScheduled = false
        self.callStudent = false
        self.isDone = false
        self.createdAt = ""
        self.type = ""
        self.path = ""
    }
}

struct PatchAppointmentsIsDone: Codable{
    var appointmentId: UUID
    var callStudent: Bool
}

struct PatchAppointmentsIsDoneResponse: Codable{
    var id: UUID
    var mentor: UUID
    var student: UUID
    var description: String
    var appointmentPlace: String
    var isScheduled: Bool
    var callStudent: Bool
    var isDone: Bool
    var createdAt: String
    var type: String
    var path: String
    
    init() {
        self.id = UUID()
        self.mentor = UUID()
        self.student = UUID()
        self.description = ""
        self.appointmentPlace = ""
        self.isScheduled = false
        self.callStudent = false
        self.isDone = false
        self.createdAt = ""
        self.type = ""
        self.path = ""
    }
}

struct PatchAppointmentsMentor: Codable{
    var appointmentId: UUID
    var mentor: String
}

struct PatchAppointmentsMentorResponse: Codable{
    var id: UUID
    var mentor: UUID
    var student: UUID
    var description: String
    var appointmentPlace: String
    var isScheduled: Bool
    var callStudent: Bool
    var isDone: Bool
    var createdAt: String
    var type: String
    var path: String
    
    init() {
        self.id = UUID()
        self.mentor = UUID()
        self.student = UUID()
        self.description = ""
        self.appointmentPlace = ""
        self.isScheduled = false
        self.callStudent = false
        self.isDone = false
        self.createdAt = ""
        self.type = ""
        self.path = ""
    }
}

//MARK: Agendamento
