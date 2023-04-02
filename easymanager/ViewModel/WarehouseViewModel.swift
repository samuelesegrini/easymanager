//
//  WarehouseViewModel.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class WarehouseViewModel: ObservableObject, Identifiable {
    @Published var warehouseList = [WarehouseStruct]()
    
    let db = Firestore.firestore()
    @Published var errorMessage: String?
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        fetchAndMap()
    }
    
    //TODO: create single variable per single input and update adddata
    @Published var warehouseToModifyOrDelete = WarehouseStruct.empty
}

extension WarehouseViewModel {
    func fetchAndMap() {
        if listenerRegistration == nil {
            listenerRegistration = db.collection("magazzino")
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        self?.errorMessage = "No documents in 'magazzino' collection"
                        return
                    }
                    DispatchQueue.main.async {
                        self?.warehouseList = documents.compactMap { queryDocumentSnapshot in
                            let result = Result { try queryDocumentSnapshot.data(as: WarehouseStruct.self) }
                            switch result {
                            case .success(let list):
                                // A WarehouseStruct value was successfully initialized from the DocumentSnapshot.
                                self?.errorMessage = nil
                                
                                if list.id == "prova" || list.restaurantID == ""{
                                    return nil
                                }
                                return list
                            case .failure(let error):
                                // A WarehouseStruct value could not be initialized from the DocumentSnapshot.
                                switch error {
                                case DecodingError.typeMismatch(_, let context):
                                    self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                                case DecodingError.valueNotFound(_, let context):
                                    self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                                case DecodingError.keyNotFound(_, let context):
                                    self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                                case DecodingError.dataCorrupted(let key):
                                    self?.errorMessage = "\(error.localizedDescription): \(key)"
                                default:
                                    self?.errorMessage = "Error decoding document: \(error.localizedDescription)"
                                }
                                return nil
                            }
                        }
                    }
                }
        }
    }
    func addData(){
        do{
            try db.collection("magazzino").addDocument(from: warehouseToModifyOrDelete)
            errorMessage = ""
        }catch{
            errorMessage = error.localizedDescription
        }
    }
    func deleteData(){
        db.collection("magazzino").document(warehouseToModifyOrDelete.id ?? "").delete() { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.warehouseList.removeAll{ warehouse in
                        return warehouse.id == self.warehouseToModifyOrDelete.id
                    }
                }
                self.warehouseToModifyOrDelete = WarehouseStruct.empty
            }else{
                self.errorMessage = error?.localizedDescription
                self.warehouseToModifyOrDelete = WarehouseStruct.empty
            }
        }
    }
    func updateData(){
        do {
            try db.collection("magazzino").document(warehouseToModifyOrDelete.id ?? "").setData(from: warehouseToModifyOrDelete, merge: true)
            self.fetchAndMap()
            self.warehouseToModifyOrDelete = WarehouseStruct.empty
            
        }catch{
            errorMessage = error.localizedDescription
            warehouseToModifyOrDelete = WarehouseStruct.empty
        }
    }
}
