//
//  HttpEnums.swift
//  Front
//
//  Created by Vinicius Alves Marques on 01/09/25.
//
//TODO: Revisar documentação

/// This enum is for the http methods
public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}
/// This enum is for the http expected errors
public enum RequestError: Error {
    case invalidURLString
    case failedRequest
}
/// Enum with all possible cases of HTTP Response from the BackEnd application
public enum HTTPResponse: Int {
    case ok = 200
    case badRequest = 400
    case unauthorized = 401
    case paymentRequired = 402
    case forbbiden = 403
    case notFound = 404
    case requestEntityTooLarge = 413
    case invalidRequest = 422
    case tooManyRequests = 429
    case internalServerError = 500
    case badGateway = 502
    case serviceUnavailable = 503
    case unknownResponse
    
    /// Var with all messages for each case
    public var message: String {
        switch self {
        case .ok:
            "Request completed successfully."
        case .badRequest:
            "The request encoding is invalid; the request can't be parsed as a valid JSON."
        case .unauthorized:
            "Accessing a protected resource without authorization or with invalid credentials."
        case .paymentRequired:
            "The account associated with the API key making requests hits a quota that can be increased by upgrading the Airtable account plan."
        case .forbbiden:
            "Accessing a protected resource with API credentials that don't have access to that resource."
        case .notFound:
            "Route or resource is not found."
        case .requestEntityTooLarge:
            "The request exceeded the maximum allowed payload size."
        case .invalidRequest:
            "The request data is invalid."
        case .tooManyRequests:
            "Rate limit exceeded. Please try again later."
        case .internalServerError:
            "The server encountered an unexpected condition."
        case .badGateway:
            "Airtable's servers are restarting or an unexpected outage is in progress."
        case .serviceUnavailable:
            "The server could not process your request in time. The server could be temporarily unavailable, or it could have timed out processing your request."
        case .unknownResponse:
            "Unknow response."
        }
    }
}
