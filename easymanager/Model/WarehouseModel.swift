//
//  WarehouseModel.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import Foundation
import FirebaseFirestoreSwift

struct WarehouseStruct: Codable, Identifiable {
    @DocumentID var id: String?
    
    var restaurantID: String
    
    var warehouseName: String
    var warehouseUnit: String
    var warehousePrice: Double
    var warehouseBarcode: Int
    var warehouseCost: Double
    var warehouseCategory: String
    var warehouseBrand: String
    var warehouseImage: String
    var warehouseSKU: String
    var warehouseQuantity: Double
    var warehouseIsInSale: Bool
    var warehouseExpiringDate: Date
    var warehouseSuppliersID: [String]
    var warehouseLocation: Adress
}
extension WarehouseStruct {
    static let empty = WarehouseStruct(restaurantID: "", warehouseName: "", warehouseUnit: "", warehousePrice: 0, warehouseBarcode: 0, warehouseCost: 0, warehouseCategory: "", warehouseBrand: "", warehouseImage: "", warehouseSKU: "", warehouseQuantity: 0, warehouseIsInSale: false, warehouseExpiringDate: Date(), warehouseSuppliersID: [], warehouseLocation: Adress.empty)
}

struct SupplierStruct : Codable, Identifiable {
    @DocumentID var id: String?
    
    var supplierName: String
    var supplierWebsite: URL?
    var supplierCategory: String
    var supplierInfo: [Adress]
}
extension SupplierStruct {
    static let empty = SupplierStruct(supplierName: "", supplierCategory: "", supplierInfo: [])
}
