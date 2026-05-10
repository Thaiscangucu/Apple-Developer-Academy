//
//  EncodeDecodeEnumsModel.swift
//  Front
//
//  Created by Vinicius Alves Marques on 01/09/25.
//

/// This enum is for the decode expected errors
public enum DecodeErrors: Error {
    case badDecode
    case badUserDecode
    case badUsersDecode
    case badPostUserResponseDecode
    case badPatchUserResponseUpdateNameDecode
    case badPostAppointmentsResponseDecode
    case badPatchAppointmentsPlaceResponseDecode
    case badPatchAppointmentsIsScheduleResponseDecode
    case badPatchAppointmentsCallStudentResponseDecode
    case badPatchAppointmentsIsDoneResponseDecode
    case badPatchAppointmentsMentorResponseDecode
    case badGetAppointmentsListDecode
    case badGetAppointmentDecode
    case badUsersListDecode
    case badPatchUserResponseUpdateRoleDecode
}

/// This enum is for the encode expected errors.
public enum EncodeErrors: Error {
    case badEncode
    case badPostUserEncode
    case badUsersUpdateNameEncode
    case badAppointmentsEncode
    case badAppointmentsIsDoneEncode
    case badAppointmentsPlaceEncode
    case badAppointmentsisScheduledEncode
    case badAppointmentsCallStudentEncode
    case badPostAppointmentsEncode
    case badAppointmentsMentorEncode
    case badUsersUpdateRoleEncode
}


