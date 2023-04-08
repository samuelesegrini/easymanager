//
//  TableViewModel.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class TableViewModel: ObservableObject, Identifiable {
    @Published var tableList = [TableStruct]()
    @Published var copertoList = [CopertoStruct]()
        
    let db = Firestore.firestore()
    @Published var errorMessage: String?
    private var listenerRegistration: ListenerRegistration?
    private var listenerCoperto: ListenerRegistration?
    
    init(){
        fetchAndMap()
        fetchCoperto()
    }
    @Published var tableName = ""
    @Published var tableSeats = 0
    @Published var tableStatus = ""
    
    @Published var tableToModifyOrDelete = TableStruct.empty
    @Published var copertoToModifyOrDelete = CopertoStruct.empty
}

extension TableViewModel {
    func fetchCoperto(){
        if listenerCoperto == nil {
            listenerCoperto = db.collection("coperto")
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        self?.errorMessage = "No documents in 'coperto' collection"
                        return
                    }
                    DispatchQueue.main.async {
                        self?.copertoList = documents.compactMap { queryDocumentSnapshot in
                            let result = Result { try queryDocumentSnapshot.data(as: CopertoStruct.self) }
                            switch result {
                            case .success(let list):
                                // A CopertoStruct value was successfully initialized from the DocumentSnapshot.
                                self?.errorMessage = nil
                            
                                return list
                            case .failure(let error):
                                // A CopertoStruct value could not be initialized from the DocumentSnapshot.
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
    func fetchAndMap() {
        if listenerRegistration == nil {
            listenerRegistration = db.collection("tavolo")
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                    
                    guard let documents = querySnapshot?.documents else {
                        self?.errorMessage = "No documents in 'tavolo' collection"
                        return
                    }
                    DispatchQueue.main.async {
                        self?.tableList = documents.compactMap { queryDocumentSnapshot in
                            let result = Result { try queryDocumentSnapshot.data(as: TableStruct.self) }
                            switch result {
                            case .success(let list):
                                // A TableStruct value was successfully initialized from the DocumentSnapshot.
                                self?.errorMessage = nil
                            
                                if list.id == "prova" {
                                    return nil
                                }
                                
                                return list
                            case .failure(let error):
                                // A TableStruct value could not be initialized from the DocumentSnapshot.
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
        do {
            try db.collection("tavolo").addDocument(from: tableToModifyOrDelete)
            self.fetchAndMap()
            
            tableToModifyOrDelete = TableStruct.empty

        }catch let error {
            self.errorMessage = error.localizedDescription
        }
    }
    func deleteData(){
        db.collection("tavolo").document(tableToModifyOrDelete.id ?? "").delete() { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.tableList.removeAll{ table in
                        return table.id == self.tableToModifyOrDelete.id
                    }
                }
                self.tableToModifyOrDelete = TableStruct.empty
            }else{
                self.errorMessage = error?.localizedDescription
                self.tableToModifyOrDelete = TableStruct.empty
            }
        }
    }
    func updateData(table : TableStruct){
        do{
            try db.collection("tavolo").document(table.id ?? "").setData(from: table, merge: true)
            self.fetchAndMap()
        }catch {
            errorMessage = error.localizedDescription
        }
    }
}

extension TableViewModel {
    func filterStatus(filter: TableStatusEnum) -> [TableStruct] {
        switch filter {
        case .occupied:
            return tableList.filter { $0.tableStatus == "Occupato"}
        case .free:
            return tableList.filter { $0.tableStatus == "Libero"}
        case .booked:
            return tableList.filter { $0.tableStatus == "Prenotato"}
        case .waiting:
            return tableList.filter { $0.tableStatus == "In Attesa"}
        }
    }
    func addCoperto(){
        do{
            try db.collection("coperto").addDocument(from: copertoToModifyOrDelete)
            self.fetchCoperto()
            errorMessage = ""
            copertoToModifyOrDelete = CopertoStruct.empty
        }catch{
            errorMessage = error.localizedDescription
        }
    }
    func deleteCoperto(){
        db.collection("coperto").document(copertoToModifyOrDelete.id ?? "").delete { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.copertoList.removeAll{ categ in
                        return categ.id == self.copertoToModifyOrDelete.id
                    }
                }
                self.copertoToModifyOrDelete = CopertoStruct.empty
            }else{
                self.errorMessage = error?.localizedDescription
                self.copertoToModifyOrDelete = CopertoStruct.empty
            }
        }
    }
}
