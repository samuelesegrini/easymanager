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
    
    var userRestaurantID = "N1VqnVlgKcc1B7MuFBM0"
    var waiterID : String
    var tableServiceBegin : Date
    var tableSeatsOccupied : Int
    
    var tableName: String
    var tableSeats: Int
    var tableStatus: String
}

extension TableStruct {
    static let empty = TableStruct(id: "", userRestaurantID: "N1VqnVlgKcc1B7MuFBM0", waiterID: "", tableServiceBegin: Date(), tableSeatsOccupied: 0, tableName :"", tableSeats : 0, tableStatus: "Libero")
}

struct CopertoStruct : Codable, Identifiable {
    @DocumentID var id : String?
    
    var nomeCoperto: String
    var prezzoCoperto : Double
}
extension CopertoStruct {
    static let empty = CopertoStruct(nomeCoperto: "", prezzoCoperto: 0)
}
