//
//  DecodeStructsModel.swift
//  Front
//
//  Created by Vinicius Alves Marques on 29/08/25.
//
//TODO: DooC
import Foundation

///Base class
class DecodeModel{
    
    ///This function transforms a Json into a object
    static func decode<T:Codable>(data: Data, object: T) throws -> T{
        guard let decodeData = try? JSONDecoder().decode(T.self, from: data) else{
            throw DecodeErrors.badDecode
        }
        return decodeData
        
    }
    
}

///Outras herdando:

class DecodeModelHeir: DecodeModel{
    static func DecodeGetUser(data: Data, typeStruct: GetUser) throws ->  GetUser{
        guard let decodedData = try? decode(data: data, object: typeStruct)else{
            throw DecodeErrors.badUserDecode
        }
        return decodedData
    }
    
    static func DecodeUserList(data: Data, typeStruct: [GetUser]) throws ->  [GetUser]{
        guard let decodedData = try? decode(data: data, object: typeStruct)else{
            throw DecodeErrors.badUsersDecode
        }
        return decodedData
    }
    
    static func DecodePostUserResponse(data: Data, typeStruct: PostUserResponse) throws ->  PostUserResponse{
        guard let decodedData = try? decode(data: data, object: typeStruct)else{
            throw DecodeErrors.badPostUserResponseDecode
        }
        return decodedData
    }
    
    static func DecodePatchUserResponseUpdateName(data: Data, typeStruct: PatchUserResponseUpdateName) throws ->  PatchUserResponseUpdateName{
        guard let decodedData = try? decode(data: data, object: typeStruct)else{
            throw DecodeErrors.badPatchUserResponseUpdateNameDecode
        }
        return decodedData
    }
    
    static func DecodePatchUserResponseUpdateRole(data: Data, typeStruct: PatchUserResponseUpdateRole) throws ->  PatchUserResponseUpdateRole{
        guard let decodedData = try? decode(data: data, object: typeStruct)else{
            throw DecodeErrors.badPatchUserResponseUpdateRoleDecode
        }
        return decodedData
    }
    
    static func DecodeGetAppointmentsList(data: Data, typeStruct: [GetAppointments]) throws ->  [GetAppointments]{
        guard let decodedData = try? decode(data: data, object: typeStruct)else{
            throw DecodeErrors.badGetAppointmentsListDecode
        }
        return decodedData
    }
    
    static func DecodeGetAppointment(data: Data, typeStruct: GetAppointments) throws ->  GetAppointments{
        guard let decodedData = try? decode(data: data, object: typeStruct)else{
            throw DecodeErrors.badGetAppointmentDecode
        }
        return decodedData
    }
    
    static func DecodePostAppointmentsResponse(data: Data, typeStruct: PostAppointmentsResponse) throws ->  PostAppointmentsResponse{
        guard let decodedData = try? decode(data: data, object: typeStruct)else{
            throw DecodeErrors.badPostAppointmentsResponseDecode
        }
        return decodedData
    }
    
    static func DecodePatchAppointmentsPlaceResponse(data: Data, typeStruct: PatchAppointmentsPlaceResponse) throws ->  PatchAppointmentsPlaceResponse{
        guard let decodedData = try? decode(data: data, object: typeStruct)else{
            throw DecodeErrors.badPatchAppointmentsPlaceResponseDecode
        }
        return decodedData
    }
    
    static func DecodePatchAppointmentsIsScheduleResponse(data: Data, typeStruct: PatchAppointmentsIsScheduleResponse) throws ->  PatchAppointmentsIsScheduleResponse{
        guard let decodedData = try? decode(data: data, object: typeStruct)else{
            throw DecodeErrors.badPatchAppointmentsIsScheduleResponseDecode
        }
        return decodedData
    }
    
    static func DecodePatchAppointmentsCallStudentResponse(data: Data, typeStruct: PatchAppointmentsCallStudentResponse) throws ->  PatchAppointmentsCallStudentResponse{
        guard let decodedData = try? decode(data: data, object: typeStruct)else{
            throw DecodeErrors.badPatchAppointmentsCallStudentResponseDecode
        }
        return decodedData
    }
    
    static func DecodePatchAppointmentsIsDoneResponse(data: Data, typeStruct: PatchAppointmentsIsDoneResponse) throws ->  PatchAppointmentsIsDoneResponse{
        guard let decodedData = try? decode(data: data, object: typeStruct)else{
            throw DecodeErrors.badPatchAppointmentsIsDoneResponseDecode
        }
        return decodedData
    }
    
    static func DecodePatchAppointmentsMentorResponse(data: Data, typeStruct: PatchAppointmentsMentorResponse) throws ->  PatchAppointmentsMentorResponse{
        guard let decodedData = try? decode(data: data, object: typeStruct)else{
            throw DecodeErrors.badPatchAppointmentsCallStudentResponseDecode
        }
        return decodedData
    }
}




