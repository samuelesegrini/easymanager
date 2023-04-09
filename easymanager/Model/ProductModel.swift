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
    
    var userRestaurantID = "N1VqnVlgKcc1B7MuFBM0"

    var productName: String
    var productDescription: String
    var productPrice: Double
    var productFavorite: Bool
    var productCategory: String
    var productIva: String
    var productVariants: [Variants]
}

extension ProductsStruct {
    static let empty = ProductsStruct(userRestaurantID: "N1VqnVlgKcc1B7MuFBM0", productName: "", productDescription: "", productPrice: 0, productFavorite: false,  productCategory: "", productIva: "", productVariants: [])
}


struct CategoryStruct: Identifiable, Codable {
    @DocumentID var id : String?
    
    var userRestaurantID : String
    
    var categoryName : String
    var categoryDescription : String
}
extension CategoryStruct {
    static let empty = CategoryStruct(userRestaurantID: "", categoryName: "", categoryDescription: "")
}
