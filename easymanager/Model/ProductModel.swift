//
//  ProductModel.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import Foundation
import FirebaseFirestoreSwift

struct ProductsStruct: Identifiable, Codable {
    @DocumentID var id: String?
    
    var userRestaurantID : String

    var productName: String
    var productPrice: Double
    var productFavorite: Bool
    var productMenu: String
    var productCategory: String
    var productVariants: [Variants]
}

extension ProductsStruct {
    static let empty = ProductsStruct(userRestaurantID: "", productName: "", productPrice: 0, productFavorite: false, productMenu: "", productCategory: "", productVariants: [])
}
