//
//  TableModel.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import Foundation
import FirebaseFirestoreSwift

enum TableStatusEnum: String, Codable, Identifiable, CaseIterable {
    case free, booked, waiting, occupied
    
    var rawValue: String {
        switch self {
        case .free : return "Libero"
        case .booked : return "Prenotato"
        case .waiting : return "In Attesa"
        case .occupied : return "Occupato"
        }
    }
    
    var id: Self { self }
}

//TODO: Add tableShape to handle and save the shape of the table and the position of the table
struct TableStruct: Codable, Identifiable {
    @DocumentID var id : String?
    
    var userRestaurantID : String
    var tableName: String
    var tableSeats: Int
    var tableStatus: String
}

extension TableStruct {
    static let empty = TableStruct(userRestaurantID: "", tableName: "", tableSeats: 0, tableStatus: "Libero")
}
