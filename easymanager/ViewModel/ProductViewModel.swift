//
//  ProductViewModel.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class ProductViewModel: ObservableObject, Identifiable {
    @Published var categoryList = [CategoryStruct]()
    @Published var productList = [ProductsStruct]()
    
    let db = Firestore.firestore()
    @Published var errorMessage: String?
    private var listenerRegistrationProd: ListenerRegistration?
    private var listenerRegistrationCate: ListenerRegistration?
    
    init() {
        fetchAndMapProduct()
        fetchAndMapCategory()
    }
    
    //TODO: create single variable per single input and update adddata
    @Published var productToModifyOrDelete = ProductsStruct.empty
    @Published var categoryToModifyOrDelete = CategoryStruct.empty
    
    @Published var menuChoice = "Listino pranzo"
    @Published var copiaProdotto = ProductsStruct.empty
}

extension ProductViewModel {
    func fetchAndMapCategory() {
        if listenerRegistrationCate == nil {
            listenerRegistrationCate = db.collection("categoria")
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        self?.errorMessage = "No documents in 'categoria' collection"
                        return
                    }
                    DispatchQueue.main.async {
                        self?.categoryList = documents.compactMap { queryDocumentSnapshot in
                            let result = Result { try queryDocumentSnapshot.data(as: CategoryStruct.self) }
                            switch result {
                            case .success(let list):
                                // A CategoryStruct value was successfully initialized from the DocumentSnapshot.
                                self?.errorMessage = nil
                                
                                return list
                            case .failure(let error):
                                // A CategoryStruct value could not be initialized from the DocumentSnapshot.
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
    func fetchAndMapProduct() {
        if listenerRegistrationProd == nil {
            listenerRegistrationProd = db.collection("prodotto")
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        self?.errorMessage = "No documents in 'prodotto' collection"
                        return
                    }
                    DispatchQueue.main.async {
                        self?.productList = documents.compactMap { queryDocumentSnapshot in
                            let result = Result { try queryDocumentSnapshot.data(as: ProductsStruct.self) }
                            switch result {
                            case .success(let list):
                                // A ProductStruct value was successfully initialized from the DocumentSnapshot.
                                self?.errorMessage = nil
                                
                                if list.id == "prova" {
                                    return nil
                                }
                                
                                return list
                            case .failure(let error):
                                // A ProductStruct value could not be initialized from the DocumentSnapshot.
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
            try db.collection("prodotto").addDocument(from: productToModifyOrDelete)
            self.fetchAndMapProduct()
            errorMessage = ""
            productToModifyOrDelete = ProductsStruct.empty
        }catch{
            errorMessage = error.localizedDescription
        }
    }
    func deleteData(){
        db.collection("prodotto").document(productToModifyOrDelete.id ?? "").delete() { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.productList.removeAll{ product in
                        return product.id == self.productToModifyOrDelete.id
                    }
                }
                self.productToModifyOrDelete = ProductsStruct.empty
            }else{
                self.errorMessage = error?.localizedDescription
                self.productToModifyOrDelete = ProductsStruct.empty
            }
        }
    }
    func updateData(){
        do{
            try db.collection("prodotto").document(productToModifyOrDelete.id ?? "").setData(from: productToModifyOrDelete, merge: true)
            self.fetchAndMapProduct()
            productToModifyOrDelete = ProductsStruct.empty
        }catch {
            errorMessage = error.localizedDescription
            productToModifyOrDelete = ProductsStruct.empty
        }
    }
}

extension ProductViewModel {
    func filterSearch(searchText: String, preferiti : Bool) -> [ProductsStruct] {
        if preferiti {
            if searchText.isEmpty {
                return productList.filter{ $0.productFavorite }
            } else {
                return productList.filter { $0.productFavorite && ($0.productName.localizedCaseInsensitiveContains(searchText) || $0.productCategory.localizedCaseInsensitiveContains(searchText))}
            }
        } else {
            if searchText.isEmpty {
                return productList
            } else {
                return productList.filter { $0.productName.localizedCaseInsensitiveContains(searchText) || $0.productCategory.localizedCaseInsensitiveContains(searchText)}
            }
        }
        
    }
    func productTotal(prodotto: ProductsStruct) -> Double{
        var total : Double = 0
        
        for variant in prodotto.productVariants {
            if variant.variantChecked ?? false {
                total += (variant.variantPrice)
            }
        }
        total += (prodotto.productPrice)
        
        return total
    }
}

extension ProductViewModel {
    func addCategory(){
        do{
            try db.collection("categoria").addDocument(from: categoryToModifyOrDelete)
            self.fetchAndMapCategory()
            errorMessage = ""
            categoryToModifyOrDelete = CategoryStruct.empty
        }catch{
            errorMessage = error.localizedDescription
        }
    }
    func deleteCategory(){
        db.collection("categoria").document(categoryToModifyOrDelete.id ?? "").delete() { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.categoryList.removeAll{ categ in
                        return categ.id == self.categoryToModifyOrDelete.id
                    }
                }
                self.categoryToModifyOrDelete = CategoryStruct.empty
            }else{
                self.errorMessage = error?.localizedDescription
                self.categoryToModifyOrDelete = CategoryStruct.empty
            }
        }
    }
}
