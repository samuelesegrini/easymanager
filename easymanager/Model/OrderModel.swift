//
//  OrdersModel.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import Foundation
import FirebaseFirestoreSwift

struct OrderStruct : Codable, Identifiable, Hashable {
    @DocumentID var id : String?
    
    var userRestaurantID = "N1VqnVlgKcc1B7MuFBM0"

    var orderFood : [Food]
    var orderTime: Date
    var orderTotalPrice: Double
    var orderTable: String
    var orderSenderID: String
}

extension OrderStruct {
    static let empty = OrderStruct(userRestaurantID: "N1VqnVlgKcc1B7MuFBM0", orderFood: [], orderTime: Date(), orderTotalPrice: 0, orderTable: "", orderSenderID: "")
}

struct Food: Codable, Hashable  {
    var foodVariants : [Variants]
    var foodName: String
    var foodIva: String
    var foodPortata : Int
    var foodReversed: Bool
    var foodPrice: Double
    var foodQuantity: Double
}
extension Food {
    static let empty = Food(foodVariants: [], foodName: "", foodIva: "", foodPortata: 0, foodReversed: false, foodPrice: 0, foodQuantity: 0)
}

struct Variants: Codable, Hashable  {
    var variantChecked: Bool
    var variantName: String
    var variantPrice: Double
    var variantDescription: String
}
extension Variants {
    static let empty = Variants(variantChecked: false, variantName: "", variantPrice: 0, variantDescription: "")
}
