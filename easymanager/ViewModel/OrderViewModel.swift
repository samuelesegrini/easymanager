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
                                
                                if list.id == "prova" {
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
            orderToModifyOrDelete = orderList.first { o in
                o.orderFood == orderToModifyOrDelete.orderFood && o.orderSenderID == orderToModifyOrDelete.orderSenderID && o.orderTable == orderToModifyOrDelete.orderTable && o.orderTime == orderToModifyOrDelete.orderTime && o.orderTotalPrice == orderToModifyOrDelete.orderTotalPrice
            } ?? OrderStruct.empty
            errorMessage = ""
        }catch{
            errorMessage = error.localizedDescription
            orderToModifyOrDelete = OrderStruct.empty
        }
    }
    func deleteData(order: OrderStruct){
        orderToModifyOrDelete = order
        orderToModifyOrDelete.id = orderList.first(where: { o in
            o.orderFood == orderToModifyOrDelete.orderFood && o.orderSenderID == orderToModifyOrDelete.orderSenderID && o.orderTable == orderToModifyOrDelete.orderTable
        })?.id
        
        print(orderToModifyOrDelete)
        if orderToModifyOrDelete.id != "" {
            db.collection("ordine").document(orderToModifyOrDelete.id ?? "").delete { error in
                if error == nil {
                    self.orderToModifyOrDelete = OrderStruct.empty
                    self.fetchAndMap()
                    print("Successo nell'eliminare l'ordine")
                }
            }
        }
    }
    func updateData(itemToUpdate: OrderStruct){
        orderToModifyOrDelete = itemToUpdate
        orderToModifyOrDelete.id = orderList.first(where: { o in
            o.orderSenderID == orderToModifyOrDelete.orderSenderID && o.orderTable == orderToModifyOrDelete.orderTable && o.orderTime == orderToModifyOrDelete.orderTime
        })?.id
        
        if let id = orderToModifyOrDelete.id {
            let docRef = db.collection("ordine").document(id)
            do {
                try docRef.setData(from: orderToModifyOrDelete)
                self.orderToModifyOrDelete = OrderStruct.empty
                self.fetchAndMap()
            }
            catch {
                print(error)
            }
        }
    }
    func addFood(id : String, food : [Food]){
        var ordine = OrderStruct.empty
        db.collection("ordine").document(id).getDocument { (document, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                do {
                    ordine = try document?.data(as: OrderStruct.self) ?? OrderStruct.empty
                    
                    ordine.orderFood.append(contentsOf: food)
                    
                    let totale = self.totalAmount(ordine: ordine)
                    self.updateData(itemToUpdate: OrderStruct(id: ordine.id, userRestaurantID: ordine.userRestaurantID, orderFood: ordine.orderFood, orderTime: ordine.orderTime, orderTotalPrice: totale, orderTable: ordine.orderTable, orderSenderID: ordine.orderSenderID))
                    
                } catch {
                    self.errorMessage = String(error.localizedDescription)
                }
            }
        }
    }
    func saveOrder(){
        do{
            try db.collection("salvataggioOrdine").addDocument(from: orderToModifyOrDelete)
            self.fetchAndMap()
            errorMessage = ""
        }catch{
            errorMessage = error.localizedDescription
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
                    cibo.append(Food(foodVariants: food.foodVariants, foodName: food.foodName, foodIva: food.foodIva, foodPortata: food.foodPortata, foodReversed: food.foodReversed, foodPrice: food.foodPrice, foodQuantity: food.foodQuantity))
                }
                return OrderStruct(userRestaurantID: list.userRestaurantID, orderFood: cibo, orderTime: list.orderTime, orderTotalPrice: list.orderTotalPrice, orderTable: list.orderTable, orderSenderID: list.orderSenderID)
            }
        }
        return ordineVuoto
    }
    func filterSearch(searchText: String) -> [OrderStruct] {
        if searchText.isEmpty {
            return orderList
        } else {
            return orderList.filter { $0.orderTable.localizedCaseInsensitiveContains(searchText)}
        }
    }
}

extension OrderViewModel {
    func totalAmount(ordine : OrderStruct) -> Double{
        var total : Double = 0
        
        for food in ordine.orderFood {
            if !food.foodReversed {
                for variant in food.foodVariants {
                    if variant.variantChecked ?? false {
                        total += (variant.variantPrice * food.foodQuantity)
                    }
                }
                total += (food.foodPrice * food.foodQuantity)
            }
        }
        return total
    }
    func totalFood(food : Food) -> Double{
        var total : Double = 0
        
        for variant in food.foodVariants {
            if variant.variantChecked ?? false {
                total += (variant.variantPrice * food.foodQuantity)
            }
        }
        total += (food.foodPrice * food.foodQuantity)

        return total
    }
    
    func DoubleProducts(prodotto : ProductsStruct, quantity : Double) -> [Food] {
        if selectedOption == "Tavolo" {
            let ord = ordineTavolo.orderFood.map { food in
                food.foodName == prodotto.productName && !food.foodReversed && food.foodVariants.filter({ $0.variantChecked == true }) == prodotto.productVariants.filter({ $0.variantChecked == true }) ?
                Food(foodVariants: food.foodVariants, foodName: food.foodName, foodIva: food.foodIva, foodPortata: food.foodPortata, foodReversed: food.foodReversed, foodPrice: food.foodPrice, foodQuantity: food.foodQuantity + quantity) : Food(foodVariants: food.foodVariants, foodName: food.foodName, foodIva: food.foodIva, foodPortata: food.foodPortata, foodReversed: food.foodReversed, foodPrice: food.foodPrice, foodQuantity: food.foodQuantity)
            }
            return ord
        } else {
            let ord = ordineVuoto.orderFood.map { food in
                food.foodName == prodotto.productName && !food.foodReversed && food.foodVariants.filter({ $0.variantChecked == true }) == prodotto.productVariants.filter({ $0.variantChecked == true }) ? Food(foodVariants: food.foodVariants, foodName: food.foodName, foodIva: food.foodIva, foodPortata: food.foodPortata, foodReversed: food.foodReversed, foodPrice: food.foodPrice, foodQuantity: food.foodQuantity + quantity) : Food(foodVariants: food.foodVariants, foodName: food.foodName, foodIva: food.foodIva, foodPortata: food.foodPortata, foodReversed: food.foodReversed, foodPrice: food.foodPrice, foodQuantity: food.foodQuantity)
            }
            return ord
        }
    }
    
    func checkDoubleProducts(prodotto : ProductsStruct) -> Bool {
        var ord = false
        if selectedOption == "Tavolo" {
            for food in ordineTavolo.orderFood {
                if food.foodName == prodotto.productName && !food.foodReversed && food.foodVariants.filter({ $0.variantChecked == true }) == prodotto.productVariants.filter({ $0.variantChecked == true }) {
                    ord = true
                }
            }
            return ord
        } else {
            for food in ordineVuoto.orderFood {
                if food.foodName == prodotto.productName && !food.foodReversed && food.foodVariants.filter({ $0.variantChecked == true }) == prodotto.productVariants.filter({ $0.variantChecked == true }) {
                    ord = true
                }
            }
            return ord
        }
    }
    
    func modifyFood(exValore : Food) -> [Food] {
        var ord = [Food]()
        if selectedOption == "Tavolo" {
            if ordineTavolo.orderFood.contains(exValore){
                //contiene exvalore
                ordineTavolo.orderFood.removeAll { food in
                    food == exValore
                }
                //exvalore eliminato
                if ordineTavolo.orderFood.contains(where: { food in
                    food.foodName == prodottoModify.foodName && !food.foodReversed && food.foodVariants.filter({ $0.variantChecked == true }) == prodottoModify.foodVariants.filter({ $0.variantChecked == true })}) {
                    
                    ord = ordineTavolo.orderFood.map { food in
                        food.foodName == prodottoModify.foodName && !food.foodReversed && food.foodVariants.filter({ $0.variantChecked == true }) == prodottoModify.foodVariants.filter({ $0.variantChecked == true })
                        ? Food(foodVariants: food.foodVariants, foodName: food.foodName, foodIva: food.foodIva, foodPortata: food.foodPortata, foodReversed: food.foodReversed, foodPrice: food.foodPrice, foodQuantity: food.foodQuantity + prodottoModify.foodQuantity)
                        : Food(foodVariants: food.foodVariants, foodName: food.foodName, foodIva: food.foodIva, foodPortata: food.foodPortata, foodReversed: food.foodReversed, foodPrice: food.foodPrice, foodQuantity: food.foodQuantity)
                    }
                    //mapping dell'array
                    
                    return ord
                }else {
                    ordineTavolo.orderFood.append(prodottoModify)
                    //aggiunta del valore nuovo
                    return ordineTavolo.orderFood
                }
            }
            //caso non accettato nell'ordine vuoto
            return ord
        }else {
            if ordineVuoto.orderFood.contains(exValore){
                //contiene exvalore
                ordineVuoto.orderFood.removeAll { food in
                    food == exValore
                }
                //exvalore eliminato
                if ordineVuoto.orderFood.contains(where: { food in
                    food.foodName == prodottoModify.foodName && !food.foodReversed && food.foodVariants.filter({ $0.variantChecked == true }) == prodottoModify.foodVariants.filter({ $0.variantChecked == true })}) {
                    
                    ord = ordineVuoto.orderFood.map { food in
                        food.foodName == prodottoModify.foodName && !food.foodReversed && food.foodVariants.filter({ $0.variantChecked == true }) == prodottoModify.foodVariants.filter({ $0.variantChecked == true })
                        ? Food(foodVariants: food.foodVariants, foodName: food.foodName, foodIva: food.foodIva, foodPortata: food.foodPortata, foodReversed: food.foodReversed, foodPrice: food.foodPrice, foodQuantity: food.foodQuantity + prodottoModify.foodQuantity)
                        : Food(foodVariants: food.foodVariants, foodName: food.foodName, foodIva: food.foodIva, foodPortata: food.foodPortata, foodReversed: food.foodReversed, foodPrice: food.foodPrice, foodQuantity: food.foodQuantity)
                    }
                    //mapping dell'array
                    
                    return ord
                }else {
                    ordineVuoto.orderFood.append(prodottoModify)
                    //aggiunta del valore nuovo
                    return ordineVuoto.orderFood
                }
            }
            //caso non accettato nell'ordine vuoto
            return ord
        }
    }
    var biggestNumber: Int? {
        let searchNumber = 0
        let filtered = orderList.filter { item in
            // Check if item contains searchString and a number greater than or equal to searchNumber
            if item.orderTable.contains(selectedOption) {
                let components = item.orderTable.components(separatedBy: .whitespaces)
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
            let components = item.orderTable.components(separatedBy: .whitespaces)
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
            if ordine.orderTable.contains(option){
                return true
            }
        }
        return false
    }
    
}
