
//TODO: testar a header "default" diretamente na função.
//TODO: Documentar encode e decode
//TODO: Documentar body null


import Foundation

public final class Requester {
    
    /// Function that wil send a request to the BackEnd application
    ///
    /// - Parameters:
    ///    - url: the url from the BackEnd application.
    ///    - method: the ``HTTPMethod`` that will be used.
    ///    - headers: Can be a specific header depending on the route used, otherwise default header:
    ///
    ///      ["Content-Type":"application/json"].
    ///    - body: The JSON serialization of the Record Data.
    ///
    /// - returns: A tuple with the Data received from the BackEnd application and the HTTP response: ``Models/HttpResponseModel``.
    ///
    /// The function used in ``RequisitionViewModel``, to make the CRUD:
    ///
    ///  ``Front/Models/RequisitionViewModel/createUser(user: SignInUser)``,
    ///
    ///   ``Front/Models/RequisitionViewModel/deleteUser(user: SignInUser)``,
    ///
    ///    ``Front/Models/RequisitionViewModel/getUser(user: SignInUser)`` and
    ///
    ///    ``Front/Models/RequisitionViewModel/updateUser(user: SignInUser)``
    ///
    ///
    /// - throws: a ``RequestError``: a ``RequestError/failedRequest`` or a ``RequestError/invalidURLString``.
    ///
    
    public static func sendRequest(to url: String, method: HTTPMethod, headers: [String : String], body: Data? = nil) async throws -> (Data, HTTPResponse) {
        guard let url: URL = URL(string: url) else {
            throw RequestError.invalidURLString
        }
        
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        
        guard let (data, response) = try? await URLSession.shared.data(for: request) else {
            throw RequestError.failedRequest
        }
        
        guard let response = response as? HTTPURLResponse else {
            throw RequestError.failedRequest
        }
        return (data, HTTPResponse(rawValue: response.statusCode) ?? .unknownResponse)
    }
}

//var user: User = User(name: "dayozinha123@gmail.com", senha: "123")
//func postGenerico(User: user) async -> (Data, HTTPResponse){
//    do {
//        let responses  = try await encode(objeto: user, to: "http://127.0.0.1:8080/persons", method: .POST, header: nil)
//        return responses
//    }
//    catch {
//        fatalError()
//    }
//}
