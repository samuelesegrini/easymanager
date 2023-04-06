//
//  RestaurantViewModel.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseFirestoreSwift

class RestaurantViewModel : ObservableObject {
    @Published var restaurantCurrent = RestaurantStruct.empty
    
    @Published var restaurantName = ""
    @Published var restaurantIva = 0
    @Published var restaurantLocations = [Adress]()
    
    @Published var restaurantList = [RestaurantStruct]()
    @Published var errorMessage : String?
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    init(){
        fetchAndMap()
    }
    
    func saveRestaurant() {
        let restaurantToSave = RestaurantStruct(restaurantName: restaurantName, restaurantIva: restaurantIva, restaurantLocations: restaurantLocations)
        let restaurantRef = db.collection("ristorante")
        do{
            try restaurantRef.addDocument(from: restaurantToSave)
            fetchAndMap()
            
            restaurantName = ""
            restaurantIva = 0
            restaurantLocations = [Adress]()
            
        }catch{
            errorMessage = error.localizedDescription
        }
    }
}

extension RestaurantViewModel {
    private func fetchAndMap() {
        if listenerRegistration == nil {
            listenerRegistration = db.collection("ristorante")
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                    
                    guard let documents = querySnapshot?.documents else {
                        self?.errorMessage = "No documents in 'ristorante' collection"
                        return
                    }
                    DispatchQueue.main.async {
                        self?.restaurantList = documents.compactMap { queryDocumentSnapshot in
                            let result = Result { try queryDocumentSnapshot.data(as: RestaurantStruct.self) }
                            switch result {
                            case .success(let list):
                                // A Orders value was successfully initialized from the DocumentSnapshot.
                                self?.errorMessage = nil
                                
                                if list.id == "N1VqnVlgKcc1B7MuFBM0"{
                                    self?.restaurantCurrent = list
                                }
                                if list.id == "prova" {
                                    return nil
                                }
                                return list
                            case .failure(let error):
                                // A Orders value could not be initialized from the DocumentSnapshot.
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
}
