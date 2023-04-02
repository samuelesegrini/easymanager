//
//  RestaurantModel.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import SwiftUI
import FirebaseFirestoreSwift

struct RestaurantStruct : Codable, Identifiable  {
    @DocumentID var id : String?
    
    var restaurantName : String
    var restaurantIva : Int
    var restaurantLocations : [Adress]
}
extension RestaurantStruct {
    static let empty = RestaurantStruct(restaurantName: "", restaurantIva: 0, restaurantLocations: [])
}

// MARK: Creation of an Adress struct for Company adresses
struct Adress : Codable, Hashable {
    var locationName : String
    var streetAddress : String
    var city : String
    var zip : String
    var phone : String
    var email : String
}
extension Adress {
    static let empty = Adress(locationName: "", streetAddress: "", city: "", zip: "", phone: "", email: "")
}
