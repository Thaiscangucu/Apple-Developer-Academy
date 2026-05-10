//
//  EncondeModel.swift
//  Front
//
//  Created by Vinicius Alves Marques on 01/09/25.
//
//TODO: DooC

import Foundation

///Base class
///T is a generic struct, that is no need to change paramenters.
///
///- Returns:
///   This function transforms an object into a Json

class EncodeModel{
    static func encode<T:Codable>(object: T) throws -> Data{
        guard let encodedData = try? JSONEncoder().encode(object) else{
            throw EncodeErrors.badEncode
        }
        return encodedData
    }
    
}

//Outras herdando:

class EncodeModelHeir: EncodeModel{
    
    static func EncodePostUser<PostUser:Codable>(structType: PostUser) throws -> Data {
        guard let EncodedData = try? encode(object: structType) else{
            throw EncodeErrors.badPostUserEncode
        }
        return EncodedData
    }
    
    static func EncodeUserUpdateName<PatchUserUpdateName:Codable>(structType: PatchUserUpdateName) throws -> Data {
        guard let EncodedData = try? encode(object: structType) else{
            throw EncodeErrors.badUsersUpdateNameEncode
        }
        return EncodedData
    }
    
    static func EncodeUserUpdateRole<PatchUserUpdateRole:Codable>(structType: PatchUserUpdateRole) throws -> Data {
        guard let EncodedData = try? encode(object: structType) else{
            throw EncodeErrors.badUsersUpdateRoleEncode
        }
        return EncodedData
    }
    
    static func EncodeAppointments<GetPostAppointments:Codable>(structType: GetPostAppointments) throws -> Data {
        guard let EncodedData = try? encode(object: structType) else{
            throw EncodeErrors.badAppointmentsEncode
        }
        return EncodedData
    }
    
    static func EncodePostAppointments<PostAppointments:Codable>(structType: PostAppointments) throws -> Data {
            guard let EncodedData = try? encode(object: structType) else{
                throw EncodeErrors.badPostUserEncode
            }
            return EncodedData
        }
    
    static func EncodeAppointmentsPlace<PatchAppointmentsPlace:Codable>(structType: PatchAppointmentsPlace) throws -> Data {
        guard let EncodedData = try? encode(object: structType) else{
            throw EncodeErrors.badAppointmentsPlaceEncode
        }
        return EncodedData
    }
    
    static func EncodeAppointmentsisScheduled<PatchAppointmentsIsSchedule:Codable>(structType: PatchAppointmentsIsSchedule) throws -> Data {
        guard let EncodedData = try? encode(object: structType) else{
            throw EncodeErrors.badAppointmentsisScheduledEncode
        }
        return EncodedData
    }
    
    static func EncodeAppointmentsCallStudent<PatchAppointmentsCallStudent:Codable>(structType: PatchAppointmentsCallStudent) throws -> Data {
        guard let EncodedData = try? encode(object: structType) else{
            throw EncodeErrors.badAppointmentsCallStudentEncode
        }
        return EncodedData
    }
    
    static func EncodeAppointmentsIsDone<PatchAppAppointmentsIsDone:Codable>(structType: PatchAppAppointmentsIsDone) throws -> Data {
        guard let EncodedData = try? encode(object: structType) else{
            throw EncodeErrors.badAppointmentsCallStudentEncode
        }
        return EncodedData
    }

    static func EncodeAppointmentsMentor<PatchAppAppointmentsMentor:Codable>(structType: PatchAppAppointmentsMentor) throws -> Data {
        guard let EncodedData = try? encode(object: structType) else{
            throw EncodeErrors.badAppointmentsCallStudentEncode
        }
        return EncodedData
    }

    
    
}


