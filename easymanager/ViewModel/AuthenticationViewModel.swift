//
//  AuthenticationViewModel.swift
//  easymanager
//
//  Created by Samuele Segrini on 01/04/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth


enum AuthenticationState {
  case unauthenticated
  case authenticated
  case payement
}

@MainActor
class AuthenticationViewModel : ObservableObject {
    @Published var name = ""
    @Published var restaurantID = ""
    @Published var surname = ""
    @Published var email = ""
    @Published var roles = [String]()
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published var user: User?
    @Published var userToModifyOrDelete = UserStruct.empty

    
    @Published var visualizzazioneScontrino = "moderno"
    @Published var staffList = [UserStruct]()
    @Published var utente = UserStruct.empty
    @Published var errorMessage : String?

    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var timer: Timer?
    
    @Published var authenticationState: AuthenticationState = .unauthenticated
    
    init() {
        registerAuthStateHandler()
        fetchAndMap()
    }
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                if user != nil {
                    self.user = user
                    self.authenticationState = user == nil ? .unauthenticated : .authenticated
                    self.retrieveUserData(uid: user?.uid ?? "")
                    if self.utente.userRoles.contains("pos"){
                        self.startTimer()
                    }
                }else {
                    self.stopTimer()
                    self.user = nil
                    self.authenticationState = .unauthenticated
                }
            }
        }
    }
}

extension AuthenticationViewModel {
    private func retrieveUserData(uid: String) {
        listenerRegistration = db.collection("utente").document(uid).addSnapshotListener { [weak self] documentSnapshot, error in
            if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                do {
                    let user = try documentSnapshot.data(as: UserStruct.self)
                    self?.utente = user
                } catch {
                    self?.errorMessage = String(error.localizedDescription)
                }
            } else {
                self?.errorMessage = "Dati utente non trovati"
            }
        }
    }
    
    private func saveUserData(userToSave : UserStruct) {
        do {
            if userToSave.id == "" {
                try db.collection("utente").addDocument(from: userToSave)
            } else {
                try db.collection("utente").document(userToSave.id ?? "").setData(from: userToSave)
            }
            errorMessage = ""
        }catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func fetchAndMap() {
        if listenerRegistration == nil {
            listenerRegistration = db.collection("utente")
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                    
                    guard let documents = querySnapshot?.documents else {
                        self?.errorMessage = "No documents in 'utente' collection"
                        return
                    }
                    DispatchQueue.main.async {
                        self?.staffList = documents.compactMap { queryDocumentSnapshot in
                            let result = Result { try queryDocumentSnapshot.data(as: UserStruct.self) }
                            switch result {
                            case .success(let list):
                                // A Orders value was successfully initialized from the DocumentSnapshot.
                                self?.errorMessage = nil
                                
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
    func addData() {
        do{
            try db.collection("utente").addDocument(from: userToModifyOrDelete)
            self.fetchAndMap()
            userToModifyOrDelete = UserStruct.empty

        }catch {
            errorMessage = error.localizedDescription
            userToModifyOrDelete = UserStruct.empty
        }
    }
    func updateData(){
        do{
            try db.collection("utente").document(userToModifyOrDelete.id ?? "").setData(from: userToModifyOrDelete, merge: true)
            self.fetchAndMap()
            userToModifyOrDelete = UserStruct.empty

        }catch{
            errorMessage = error.localizedDescription
            userToModifyOrDelete = UserStruct.empty
        }
    }
}

extension AuthenticationViewModel {
    func LogInWithEmailPassword() async -> Bool {
        errorMessage = ""
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            if utente.userRoles.contains("pos"){
                self.startTimer()
            }
            errorMessage = ""
            name = ""
            surname = "" 
            email = ""
            roles = [String]()
            password = ""
            confirmPassword = ""
            restaurantID = ""
                        
            return true
        }
        catch  {
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }
    func signUpWithEmailPassword() async -> Bool {
        do  {
            try await Auth.auth().createUser(withEmail: userToModifyOrDelete.userEmail, password: password)
            
            saveUserData(userToSave: UserStruct(id: user?.uid, userName: userToModifyOrDelete.userName, userRestaurantID: userToModifyOrDelete.userRestaurantID, userSurname: userToModifyOrDelete.userSurname, userEmail: userToModifyOrDelete.userEmail, userRoles: userToModifyOrDelete.userRoles, userNOperator: userToModifyOrDelete.userNOperator))
                        
            name = ""
            surname = ""
            email = ""
            roles = [String]()
            password = ""
            confirmPassword = ""
            errorMessage = ""
            
            restaurantID = ""
            
            userToModifyOrDelete = UserStruct.empty
            
            return true
        }
        catch {
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }
    func signOut() {
        stopTimer()
        do {
            try Auth.auth().signOut()
            utente = UserStruct.empty
        }
        catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAccount() async -> Bool {
        stopTimer()
        do {
            //deleteUser(uid: user?.uid ?? "")
            try await user?.delete()
            return true
        }
        catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}

extension AuthenticationViewModel {
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: false) { [weak self] _ in
            self?.signOut()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
