//
//  File.swift
//  easymanager
//
//  Created by Samuele Segrini on 01/04/23.
//

import Foundation
import FirebaseFirestoreSwift

struct UserStruct: Identifiable, Codable  {
    @DocumentID var id: String?
     
    var userName : String
    var userRestaurantID : String
    var userSurname: String
    var userEmail: String
    var userRoles: [String]
}
extension UserStruct {
    static let empty = UserStruct(userName: "", userRestaurantID: "", userSurname: "", userEmail: "", userRoles: [])
    
}
