//
//  RoutesViewModel.swift
//  Front
//
//  Created by Vinicius Alves Marques on 29/08/25.
//
//TOD

import Foundation

//TODO: fazer arquivo de CRUD juntos em uma classe estatica.

///BackEnd HTTP requests
class RoutesRequisition{
    
    //PROD
    
    static func getUsers() async throws -> ([GetUser]){
        guard let response = try? await Requester.sendRequest(to: "http://10.44.48.47:8080/users",method: .GET,headers:["Content-Type":"application/json"], body: nil)else{
            throw RequestError.failedRequest
        }
        guard let decodedData = try? DecodeModelHeir.DecodeUserList(data: response.0, typeStruct: []) else{
            throw DecodeErrors.badUsersListDecode
        }
        return decodedData
    }
    
    
    
    //GET em …/users/:id \(id), tem retorno se tem como é?
    //PROD
    
    static func getUsersId(id: UUID) async throws -> (HTTPResponse){
        //testar se o initi com valor padrao esta funcionando
        guard let response = try? await Requester.sendRequest(to: "http://10.44.48.47:8080/users/\(id)",method: .GET,headers:["Content-Type":"application/json"], body: nil)else{
            throw RequestError.failedRequest
        }
        return response.1
    }
    
    //PROD
    
    static func loginUser(password: String, email: String) async throws -> (GetUser){
        let authData = (email + ":" + password).data(using: .utf8)!.base64EncodedString()
        let postUserResponse : GetUser = GetUser()
        guard let response = try? await Requester.sendRequest(to: "http://10.44.48.47:8080/users/login",method: .POST,headers: [ "Authorization" : "Basic \(authData)" ], body: nil )else{
            throw RequestError.failedRequest
        }
        guard let decodedData = try? DecodeModelHeir.DecodeGetUser(data: response.0, typeStruct: postUserResponse) else{
            throw DecodeErrors.badPostUserResponseDecode
        }
        return decodedData
        
    }
    
    //PROD - Exige verificação no front da resposta HTTP - badrequest
    
    static func postUser(object: PostUser) async throws -> (PostUserResponse,HTTPResponse){
        let postUserResponse : PostUserResponse = PostUserResponse()
        guard let encodedData = try? EncodeModelHeir.EncodePostUser(structType: object) else{
            throw EncodeErrors.badPostUserEncode
        }
        guard let response = try? await Requester.sendRequest(to: "http://10.44.48.47:8080/users",method: .POST,headers: ["Content-Type":"application/json"], body: encodedData )else{
            throw RequestError.failedRequest
        }
        if(response.1 == .ok){
            guard let decodedData = try? DecodeModelHeir.DecodePostUserResponse(data: response.0, typeStruct: postUserResponse) else{
                throw DecodeErrors.badPostUserResponseDecode
            }
            return (decodedData,response.1)
        }
        return (postUserResponse,response.1)
    }
    
    //PROD
    
    static func DeleteUsersId(id: UUID, auth: String) async throws -> (HTTPResponse){
        //testar se o initi com valor padrao esta funcionando
        guard let response = try? await Requester.sendRequest(to: "http://10.44.48.47:8080/users/\(id)",method: .DELETE,headers:[ "Authorization" : "Basic \(auth)" ], body: nil)else{
            throw RequestError.failedRequest
        }
        return response.1
    }
    
    //PROD
    
    static func PatchUsersUpdateName(object: PatchUserUpdateName) async throws -> (PatchUserResponseUpdateName,HTTPResponse){
        let PatchUsersUpdateName : PatchUserResponseUpdateName = PatchUserResponseUpdateName()
        
        guard let encodedData = try? EncodeModelHeir.EncodeUserUpdateName(structType: object) else{
            throw EncodeErrors.badUsersUpdateNameEncode
        }
        guard let response = try? await Requester.sendRequest(to: "http://10.44.48.47:8080/users/updateName",method: .PATCH,headers: ["Content-Type":"application/json"], body: encodedData )else{
            throw RequestError.failedRequest
        }
        if(response.1 == .ok){
            guard let decodedData = try? DecodeModelHeir.DecodePatchUserResponseUpdateName(data: response.0, typeStruct: PatchUsersUpdateName) else{
                throw DecodeErrors.badPatchUserResponseUpdateNameDecode
            }
            return (decodedData,response.1)
        }
        return (PatchUsersUpdateName,response.1)
    }
    
    //PROD
    
    
    static func getAppointments() async throws -> ([GetAppointments]){
        guard let response = try? await Requester.sendRequest(to: "http://10.44.48.47:8080/appointments",method: .GET,headers:["Content-Type":"application/json"], body: nil)else{
            throw RequestError.failedRequest
        }
        guard let decodedData = try? DecodeModelHeir.DecodeGetAppointmentsList(data: response.0, typeStruct: []) else{
            throw DecodeErrors.badGetAppointmentsListDecode
        }
        return decodedData
    }
    
    //GET em …/users/:id \(id)
    //PROD
    
    static func getAppointmentsId(id: UUID) async throws -> (GetAppointments){
        //testar se o initi com valor padrao esta funcionando
        let appointments : GetAppointments = GetAppointments()
        guard let response = try? await Requester.sendRequest(to: "http://10.44.48.47:8080/appointments/\(id)",method: .GET,headers:["Content-Type":"application/json"], body: nil)else{
            throw RequestError.failedRequest
        }
        guard let decodedData = try? DecodeModelHeir.DecodeGetAppointment(data: response.0, typeStruct: appointments) else{
            throw DecodeErrors.badGetAppointmentDecode
        }
        return decodedData
    }
    
    //PROD
    
    static func postAppointments(object: PostAppointments) async throws -> (PostAppointmentsResponse){
        
        let postAppointmentsResponse: PostAppointmentsResponse = PostAppointmentsResponse()
        guard let encodedData = try? EncodeModelHeir.EncodePostAppointments(structType: object) else{
            throw EncodeErrors.badPostAppointmentsEncode
        }
        guard let response = try? await Requester.sendRequest(to: "http://10.44.48.47:8080/appointments",method: .POST,headers: ["Content-Type":"application/json"], body: encodedData )else{
            throw RequestError.failedRequest
        }
        guard let decodedData = try? DecodeModelHeir.DecodePostAppointmentsResponse(data: response.0, typeStruct: postAppointmentsResponse) else{
            throw DecodeErrors.badPostAppointmentsResponseDecode
        }
        return decodedData
        
    }
    
    //PROD
    
    static func patchAppointmentsPlace(object: PatchAppointmentsPlace, auth: String) async throws -> (PatchAppointmentsPlaceResponse){

            let patchAppointmentsPlaceResponse: PatchAppointmentsPlaceResponse = PatchAppointmentsPlaceResponse()
            guard let encodedData = try? EncodeModelHeir.EncodeAppointmentsPlace(structType: object) else{
                throw EncodeErrors.badAppointmentsPlaceEncode
            }
            guard let response = try? await Requester.sendRequest(to: "http://10.44.48.47:8080/appointments/place",method: .PATCH,headers: [ "Authorization" : "Basic \(auth)", "Content-Type" : "application/json"], body: encodedData )else{
                throw RequestError.failedRequest
            }
            guard let decodedData = try? DecodeModelHeir.DecodePatchAppointmentsPlaceResponse(data: response.0, typeStruct: patchAppointmentsPlaceResponse) else{
                throw DecodeErrors.badPatchAppointmentsPlaceResponseDecode
            }
            return decodedData
        
    }
    
    //PROD
    
    static func patchAppointmentsMentor(object: PatchAppointmentsMentor, auth: String) async throws -> (PatchAppointmentsMentorResponse){
        
        let PatchAppointmentsMentorResponse: PatchAppointmentsMentorResponse = PatchAppointmentsMentorResponse()
        guard let encodedData = try? EncodeModelHeir.EncodeAppointmentsMentor(structType: object) else{
            throw EncodeErrors.badAppointmentsMentorEncode
        }
        guard let response = try? await Requester.sendRequest(to: "http://10.44.48.47:8080/appointments/mentor",method: .PATCH,headers: [ "Authorization" : "Basic \(auth)", "Content-Type" : "application/json"], body: encodedData )else{
            throw RequestError.failedRequest
        }
        guard let decodedData = try? DecodeModelHeir.DecodePatchAppointmentsMentorResponse(data: response.0, typeStruct: PatchAppointmentsMentorResponse) else{
            throw DecodeErrors.badPatchAppointmentsMentorResponseDecode
        }
        return decodedData
    }
    
    //PROD
    
    static func deleteAppointmentsId(id: UUID,auth: String) async throws -> (HTTPResponse){
        guard let response = try? await Requester.sendRequest(to: "http://10.44.48.47:8080/appointments/\(id)",method: .DELETE,headers:[ "Authorization" : "Basic \(auth)", "Content-Type" : "application/json"], body: nil)else{
            throw RequestError.failedRequest
        }
        return response.1
    }
}
