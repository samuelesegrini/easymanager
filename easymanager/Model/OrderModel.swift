//
//  OrdersModel.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import Foundation
import FirebaseFirestoreSwift

struct OrderStruct : Codable, Identifiable {
    @DocumentID var id : String?
    
    var userRestaurantID : String

    var orderFood : [Food]
    var orderTime: Date
    var orderTotalPrice: Double
    var orderTable: String
    var orderSenderID: String
}

extension OrderStruct {
    static let empty = OrderStruct(userRestaurantID: "", orderFood: [], orderTime: Date(), orderTotalPrice: 0, orderTable: "", orderSenderID: "")
}

struct Food: Codable, Hashable  {
    var foodVariants : [Variants]
    var foodName: String
    var foodPortata : Int
    var foodReversed: Bool
    var foodPrice: Double
    var foodQuantity: Double
}
extension Food {
    static let empty = Food(foodVariants: [], foodName: "", foodPortata: 0, foodReversed: false, foodPrice: 0, foodQuantity: 0)
}

struct Variants: Codable, Hashable  {
    var variantChecked: Bool?
    var variantName: String
    var variantPrice: Double
    var variantDescription: String
}
extension Variants {
    static let empty = Variants(variantName: "", variantPrice: 0, variantDescription: "")
}
