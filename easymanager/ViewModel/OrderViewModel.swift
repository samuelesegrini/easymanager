//
//  OrdersViewModel.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class OrderViewModel: ObservableObject, Identifiable {
    @Published var orderList = [OrderStruct]()
    
    let db = Firestore.firestore()
    @Published var errorMessage: String?
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        fetchAndMap()
    }
    
    //TODO: create single variable per single input and update adddata
    @Published var orderToModifyOrDelete = OrderStruct.empty
    
    @Published var ordineVuoto = OrderStruct.empty
    @Published var ordineTavolo = OrderStruct.empty
    
    @Published var selectedOption = "Portar Via"
    @Published var options = ["Portar Via", "Bancone", "Tavolo"]
    
    @Published var prodottoModify = Food.empty
}

extension OrderViewModel {
    func fetchAndMap() {
        if listenerRegistration == nil {
            listenerRegistration = db.collection("ordine")
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        self?.errorMessage = "No documents in 'ordine' collection"
                        return
                    }
                    DispatchQueue.main.async {
                        self?.orderList = documents.compactMap { queryDocumentSnapshot in
                            let result = Result { try queryDocumentSnapshot.data(as: OrderStruct.self) }
                            switch result {
                            case .success(let list):
                                // A OrderStruct value was successfully initialized from the DocumentSnapshot.
                                self?.errorMessage = nil
                                
                                if list.id == "prova" || list.restaurantID == ""{
                                    return nil
                                }
                                return list
                            case .failure(let error):
                                // A OrderStruct value could not be initialized from the DocumentSnapshot.
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
            try db.collection("ordine").addDocument(from: orderToModifyOrDelete)
            self.fetchAndMap()
            errorMessage = ""
        }catch{
            errorMessage = error.localizedDescription
        }
    }
    func deleteData(){
        db.collection("ordine").document(orderToModifyOrDelete.id ?? "").delete() { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.orderList.removeAll{ order in
                        return order.id == self.orderToModifyOrDelete.id
                    }
                }
                self.orderToModifyOrDelete = OrderStruct.empty
            }else{
                self.errorMessage = error?.localizedDescription
                self.orderToModifyOrDelete = OrderStruct.empty
            }
        }
    }
    func updateData(){
        do{
            try db.collection("ordine").document(orderToModifyOrDelete.id ?? "").setData(from: orderToModifyOrDelete, merge: true)
            self.fetchAndMap()
            orderToModifyOrDelete = OrderStruct.empty
        }catch {
            errorMessage = error?.localizedDescription
            orderToModifyOrDelete = OrderStruct.empty
        }
    }
}

extension OrderViewModel {
    func filterOrderbyTable(tavolo: String) -> OrderStruct{
        var cibo = [Food]()
        for list in self.orderList {
            if list.orderTable == tavolo {
                for food in list.orderFood {
                    cibo.append(Food(foodVariants: food.foodVariants, foodName: food.foodName, foodPortata: food.foodPortata, foodReversed: food.foodReversed, foodPrice: food.foodPrice, foodQuantity: food.foodQuantity))
                }
                return OrderStruct(orderFood: cibo, orderTime: list.orderTime, orderTotalPrice: list.orderTotalPrice, orderTable: list.orderTable, orderSenderID: list.orderSenderID)
            }
        }
        return ordineVuoto
    }
    func filterSearch(searchText: String) -> [OrderStruct] {
        if searchText.isEmpty {
            return ordersList
        } else {
            return ordersList.filter { $0.table.localizedCaseInsensitiveContains(searchText)}
        }
    }
}

extension OrderViewModel {
    func totalAmount(ordine : OrderStruct) -> Double{
        var total : Double = 0
        
        for food in ordine.food {
            if !food.foodStornato {
                total += (food.foodPrice * food.foodQuantity)
            }
        }
        return total
    }
    
    func DoubleProducts(prodotto : ProductsStruct, quantity : Double) -> [Food] {
        if selectedOption == "Tavolo" {
            let ord = ordineTavolo.food.map { food in
                food.foodName == prodotto.nome && !food.foodStornato && food.variants.filter({ $0.variantChecked == true }) == prodotto.variants.filter({ $0.variantChecked == true }) ?
                Food(variants: food.variants, foodName: food.foodName, foodPortata: food.foodPortata, foodStornato: food.foodStornato, foodPrice: food.foodPrice, foodQuantity: food.foodQuantity + quantity) : Food(variants: food.variants, foodName: food.foodName, foodPortata: food.foodPortata, foodStornato: food.foodStornato, foodPrice: food.foodPrice, foodQuantity: food.foodQuantity)
            }
            return ord
        } else {
            let ord = ordineVuoto.food.map { food in
                food.foodName == prodotto.nome && !food.foodStornato && food.variants.filter({ $0.variantChecked == true }) == prodotto.variants.filter({ $0.variantChecked == true }) ? Food(variants: food.variants, foodName: food.foodName, foodPortata: food.foodPortata, foodStornato: food.foodStornato, foodPrice: food.foodPrice, foodQuantity: food.foodQuantity + quantity) : Food(variants: food.variants, foodName: food.foodName, foodPortata: food.foodPortata, foodStornato: food.foodStornato, foodPrice: food.foodPrice, foodQuantity: food.foodQuantity)
            }
            return ord
        }
    }
    func checkDoubleProducts(prodotto : ProductsStruct) -> Bool {
        var ord = false
        if selectedOption == "Tavolo" {
            for food in ordineTavolo.food {
                if food.foodName == prodotto.nome && !food.foodStornato && food.variants.filter({ $0.variantChecked == true }) == prodotto.variants.filter({ $0.variantChecked == true }) {
                    ord = true
                }
            }
            return ord
        } else {
            for food in ordineVuoto.food {
                if food.foodName == prodotto.nome && !food.foodStornato && food.variants.filter({ $0.variantChecked == true }) == prodotto.variants.filter({ $0.variantChecked == true }) {
                    ord = true
                }
            }
            return ord
        }
    }

    func modifyFood(exValore : Food) -> [Food] {
        var ord = [Food]()
        if selectedOption == "Tavolo" {

            if ordineTavolo.food.contains(exValore){
                //contiene exvalore
                ordineTavolo.food.removeAll { food in
                    food == exValore
                }
                //exvalore eliminato
                if ordineTavolo.food.contains(where: { food in
                    food.foodName == prodottoModify.foodName && !food.foodStornato && food.variants.filter({ $0.variantChecked == true }) == prodottoModify.variants.filter({ $0.variantChecked == true })}) {

                    ord = ordineTavolo.food.map { food in
                        food.foodName == prodottoModify.foodName && !food.foodStornato && food.variants.filter({ $0.variantChecked == true }) == prodottoModify.variants.filter({ $0.variantChecked == true })
                        ? Food(variants: food.variants, foodName: food.foodName, foodPortata: food.foodPortata, foodStornato: food.foodStornato, foodPrice: food.foodPrice, foodQuantity: food.foodQuantity + prodottoModify.foodQuantity)
                        : Food(variants: food.variants, foodName: food.foodName, foodPortata: food.foodPortata, foodStornato: food.foodStornato, foodPrice: food.foodPrice, foodQuantity: food.foodQuantity)
                    }
                    //mapping dell'array

                    return ord
                }else {
                    ordineTavolo.food.append(prodottoModify)
                    //aggiunta del valore nuovo
                    return ordineTavolo.food
                }
            }
            //caso non accettato nell'ordine vuoto
            return ord
        }else {
            if ordineVuoto.food.contains(exValore){
                //contiene exvalore
                ordineVuoto.food.removeAll { food in
                    food == exValore
                }
                //exvalore eliminato
                if ordineVuoto.food.contains(where: { food in
                    food.foodName == prodottoModify.foodName && !food.foodStornato && food.variants.filter({ $0.variantChecked == true }) == prodottoModify.variants.filter({ $0.variantChecked == true })}) {

                    ord = ordineVuoto.food.map { food in
                        food.foodName == prodottoModify.foodName && !food.foodStornato && food.variants.filter({ $0.variantChecked == true }) == prodottoModify.variants.filter({ $0.variantChecked == true })
                        ? Food(variants: food.variants, foodName: food.foodName, foodPortata: food.foodPortata, foodStornato: food.foodStornato, foodPrice: food.foodPrice, foodQuantity: food.foodQuantity + prodottoModify.foodQuantity)
                        : Food(variants: food.variants, foodName: food.foodName, foodPortata: food.foodPortata, foodStornato: food.foodStornato, foodPrice: food.foodPrice, foodQuantity: food.foodQuantity)
                    }
                    //mapping dell'array

                    return ord
                }else {
                    ordineVuoto.food.append(prodottoModify)
                    //aggiunta del valore nuovo
                    return ordineVuoto.food
                }
            }
            //caso non accettato nell'ordine vuoto
            return ord
        }
    }

    var biggestNumber: Int? {
        let searchNumber = 0
        let filtered = ordersList.filter { item in
            // Check if item contains searchString and a number greater than or equal to searchNumber
            if item.table.contains(selectedOption) {
                let components = item.table.components(separatedBy: .whitespaces)
                for component in components {
                    if let number = Int(component), number >= searchNumber {
                        return true
                    }
                }
            }
            return false
        }
        
        // Find the biggest number in the filtered array
        let numbers = filtered.compactMap { item -> Int? in
            let components = item.table.components(separatedBy: .whitespaces)
            for component in components {
                if let number = Int(component) {
                    return number
                }
            }
            return nil
        }
        return numbers.max()
    }
    func checkContainsOptions(ordine : OrderStruct) -> Bool {
        for option in options {
            if ordine.table.contains(option){
                return true
            }
        }
        return false
    }

}
