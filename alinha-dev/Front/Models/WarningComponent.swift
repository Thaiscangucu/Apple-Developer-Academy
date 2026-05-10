//
//  WarningComponent.swift
//  Front
//
//  Created by Pedro Henrique L. Moreiras on 22/08/25.
//

import Foundation

/// This function is responsable to valid if an email matches the Regex pattern.
/// - Parameters:
///      - email: User's e-mail
/// - email Regex: A pattern that describes the possible elements in an email string.
/// - Returns: Returns a Bool if the user's email is valid.
func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,64}$"
    let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
    if emailPredicate.evaluate(with: email) == true {
        print ("email trueeeee")
    } else {
        print("email falseeee")
    }
    return emailPredicate.evaluate(with: email)
}

//func isPasswordHasNumberAndCharacterSign(password: String) -> Bool {
//    let passWordRegEx = "^[A-Za-z0-9 !\"#$%&'()*+,-./:;<=>?@\\[\\\\\\]^_`{|}~]"
//    let passwordTest = NSPredicate(format: "SELF MATCHES %@", passWordRegEx)
//    if passwordTest.evaluate(with: password) == true {
//        print ("senha trueeeee")
//    } else {
//        print("senha falseeee")
//    }
//    return passwordTest.evaluate(with: password)
//}

func isValidName(name: String) -> Bool {
    //Declaring the rule of characters to be used. Applying rule to current state. Verifying the result.
    let regex = "^(?=.{2,100}$)[A-Za-zÀ-ú][A-Za-zÀ-ú.'-]+(?: [A-Za-zÀ-ú.'-]+)* *$"
    let test = NSPredicate(format: "SELF MATCHES %@", regex)
    if test.evaluate(with: name) == true {
        print ("name trueeeee")
    } else {
        print("name falseeee")
    }
    let result = test.evaluate(with: name)
    
    return result
}

/// This function is responsable to choose which alert message will happen.
/// - Parameters:
///      - name: User's name
///      - email: User's e-mail
///      - password: User's defined password
///      - confirmPassword: User's password to check
/// - Returns: Returns two Strings to fill the alert content.
func checkSingupContents(name: String, email: String, password: String, confirmPassword: String) -> (String,String){
    
    if(password != confirmPassword){
        return("Senha Incorreta","Sua senha não é a mesma. Por favor, tente novamente.")
    }
    else if(password.count <= 8 ){
        return("Senha Curta","Sua senha deve ter mais caracteres!")
    }
    else if(!isValidEmail(email)) {
        return("Email Inválido","Certifique-se se o endereço de email está correto.")
        
    }
    else if(!isValidName(name: name)) {
        return("Nome Inválido", "Verique se seu nome está completo.")
    }
    
    return ("","")
}
