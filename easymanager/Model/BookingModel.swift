//
//  BookingModel.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import Foundation
import FirebaseFirestoreSwift

struct BookingStruct: Identifiable, Codable {
    @DocumentID var id: String?
    
    var userRestaurantID : String

    var bookingNumberOfPeople: Int
    var bookingContact: String
    var bookingDescription: String?
    var bookingName: String
    var bookingDate: Date
    var bookingTableId: String
}

extension BookingStruct {
    static let empty = BookingStruct(userRestaurantID: "", bookingNumberOfPeople: 0, bookingContact: "", bookingName: "", bookingDate: Date(), bookingTableId: "")
}
