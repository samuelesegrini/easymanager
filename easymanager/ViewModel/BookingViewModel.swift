//
//  BookingViewModel.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class BookingViewModel: ObservableObject, Identifiable {
    @Published var bookingList = [BookingStruct]()
    
    let db = Firestore.firestore()
    @Published var errorMessage: String?
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        fetchAndMap()
    }
    
    //TODO: create single variable per single input and update adddata
    @Published var bookingToModifyOrDelete = BookingStruct.empty
}

extension BookingViewModel {
    func fetchAndMap() {
        if listenerRegistration == nil {
            listenerRegistration = db.collection("prenotazione")
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                    
                    guard let documents = querySnapshot?.documents else {
                        self?.errorMessage = "No documents in 'prenotazione' collection"
                        return
                    }
                    DispatchQueue.main.async {
                        self?.bookingList = documents.compactMap { queryDocumentSnapshot in
                            let result = Result { try queryDocumentSnapshot.data(as: BookingStruct.self) }
                            switch result {
                            case .success(let list):
                                // A BookingStruct value was successfully initialized from the DocumentSnapshot.
                                self?.errorMessage = nil
                                
                                return list
                            case .failure(let error):
                                // A BookingStruct value could not be initialized from the DocumentSnapshot.
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
            try db.collection("prenotazione").addDocument(from: bookingToModifyOrDelete)
            self.fetchAndMap()
            errorMessage = ""
        }catch{
            errorMessage = error.localizedDescription
        }
    }
    func deleteData(){
        db.collection("prenotazione").document(bookingToModifyOrDelete.id ?? "").delete() { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.bookingList.removeAll{ book in
                        return book.id == self.bookingToModifyOrDelete.id
                    }
                }
                self.bookingToModifyOrDelete = BookingStruct.empty
            }else{
                self.errorMessage = error?.localizedDescription
                self.bookingToModifyOrDelete = BookingStruct.empty
            }
        }
    }
    func updateData(){
        do {
            try db.collection("prenotazione").document(bookingToModifyOrDelete.id ?? "").setData(from: bookingToModifyOrDelete, merge: true)
            self.fetchAndMap()
            self.bookingToModifyOrDelete = BookingStruct.empty
            
        }catch{
            errorMessage = error.localizedDescription
            bookingToModifyOrDelete = BookingStruct.empty
        }
    }
}
