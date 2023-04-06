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
    var userRestaurantID = "N1VqnVlgKcc1B7MuFBM0"
    var userSurname: String
    var userEmail: String
    var userRoles: [String]
    
    var userNOperator: Int
}
extension UserStruct {
    static let empty = UserStruct(userName: "", userRestaurantID: "N1VqnVlgKcc1B7MuFBM0", userSurname: "", userEmail: "", userRoles: [], userNOperator: 0)
    
}
