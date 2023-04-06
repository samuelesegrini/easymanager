//
//  UserManagerView.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 30/03/23.
//

import SwiftUI
import FirebaseAuth

struct UserManagerView: View {
    @EnvironmentObject var auth: AuthenticationViewModel
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dismiss) var dismiss
    
    @State private var showingUser : UserStruct?
    @State private var addingUser = false
    
    @State private var name = ""
    @State private var surname = ""
    @State private var email = ""
    @State private var pin = ""
    @State private var ruoli = [String]()
    
    @State private var selectedAdmin = false
    @State private var selectedCucina = false
    @State private var selectedPos = false
    @State private var selectedCameriere = false
        
    var body: some View {
        VStack{
            if sizeClass == .compact {
                List {
                    ListSection("admin")
                    ListSection("pos")
                    ListSection("cameriere")
                    ListSection("cucina")
                }
            }else {
                HStack{
                    List{
                        ListSection("admin")
                    }
                    List{
                        ListSection("pos")
                    }
                }
                HStack{
                    List{
                        ListSection("cameriere")
                    }
                    List{
                        ListSection("cucina")
                    }
                }
            }
        }
        .sheet(item: $showingUser) { staff in
            NavigationStack{
                UserSheet(staff)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Gestione Utenti")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                //TODO: Adding new user as admin
                /*
                Button {
                    addingUser = true
                } label: {
                    Image(systemName: "plus")
                }
                .sheet(isPresented: $addingUser) {
                    AddUtente()
                }*/
            }
        }
    }
    @ViewBuilder
    func ListSection(_ role : String) -> some View {
        Section {
            ForEach(auth.staffList.filter{ $0.userRoles.contains(role) }) { staff in
                ListSection(staff, role)
            }
        } header: {
            HStack{
                Text(role.firstCapitalized)
                VStack{
                    Divider()
                }
            }
        }
    }
    @ViewBuilder
    func ListSection(_ staff : UserStruct ,_ role : String) -> some View {
        HStack {
            VStack(alignment: .leading){
                Text("\(staff.userName) \(staff.userSurname)")
                Text(staff.userEmail).font(.caption).foregroundColor(.secondary)
            }
            .padding(.vertical)
            Spacer()
            
            Button {
                name = staff.userName
                surname = staff.userSurname
                email = staff.userEmail
                ruoli = staff.userRoles
                
                showingUser = staff
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .buttonStyle(.borderedProminent)
            
            //TODO: delete user
            /*
            Button(role: .destructive) {
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.bordered)
            .tint(.red)
             */
        }
    }
    @ViewBuilder
    func AddUtente() -> some View {
        VStack {
            Form{
                Section{
                    HStack{
                        Text("Nome").bold()
                        TextField("Obbligatorio", text: $name)
                            .padding(.horizontal, 45)
                    }
                    HStack{
                        Text("Cognome").bold()
                        TextField("Obbligatorio", text: $surname)
                            .padding(.horizontal)
                    }
                    //TODO: Modify email
                    /*
                    HStack {
                        Text("Email").bold()
                        TextField("Obbligatorio", text: $email)
                            .padding(.horizontal, 50)
                    }*/
                    HStack {
                        Text("PIN").bold()
                        TextField("Obbligatorio", text: $pin)
                            .keyboardType(.decimalPad)
                            .padding(.horizontal, 50)
                    }
                }header: {
                    Text("Informazioni personali")
                }
                Section{
                    List{
                        Button {
                            selectedAdmin.toggle()
                            ruoli.append("admin")
                        } label: {
                            HStack{
                                Image(systemName: selectedAdmin ? "checkmark.circle.fill" : "circle")
                                Text("Admin").foregroundColor(.primary)
                            }
                        }
                        Button {
                            selectedPos.toggle()
                            ruoli.append("pos")
                        } label: {
                            HStack{
                                Image(systemName: selectedPos ? "checkmark.circle.fill" : "circle")
                                Text("Pos").foregroundColor(.primary)
                            }
                        }
                        Button {
                            selectedCameriere.toggle()
                            ruoli.append("cameriere")
                        } label: {
                            HStack{
                                Image(systemName: selectedCameriere ? "checkmark.circle.fill" : "circle")
                                Text("Cameriere").foregroundColor(.primary)
                            }
                        }
                        Button {
                            selectedCucina.toggle()
                            ruoli.append("cucina")
                        } label: {
                            HStack{
                                Image(systemName: selectedCucina ? "checkmark.circle.fill" : "circle")
                                Text("Cucina").foregroundColor(.primary)
                            }
                        }
                    }
                }header: {
                    HStack{
                        Text("Ruoli")
                        Spacer()
                        Text("Click per Aggiungere").font(.caption2)
                    }
                }footer: {
                    Text("I ruoli sono molto importanti a livello di gestione del personale e del ristorante in generale.\nRicordarsi che ogni ruolo ha una specifica funzione ed eliminarli risulterebbe in un cambiamento pratico alle mansioni dell'utente")
                }
            }
            .formStyle(.grouped)

            Spacer()
            Button {
                auth.userToModifyOrDelete = UserStruct(userName: name, userRestaurantID: "", userSurname: surname, userEmail: email, userRoles: ruoli, userNOperator: 5)
                
                signUp()
                
                dismiss()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(height: 60)
                    HStack{
                        Image(systemName: "plus.circle.fill")
                        Text("Aggiungi Utente").bold()
                    }
                    .foregroundColor(.white)
                }
            }
            .padding()
            .padding(.horizontal)
        }
        .onAppear{
            name = ""
            surname = ""
            email = ""
            pin = ""
            ruoli = [String]()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Crea Utente")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(id:"Annulla",placement: .navigationBarLeading){
                Button("Annulla") {
                    addingUser = false
                }
            }
        }
    }
    @ViewBuilder
    func UserSheet(_ user: UserStruct) -> some View {
        VStack {
            Form{
                Section{
                    HStack{
                        Text("Nome").bold()
                        TextField("Obbligatorio", text: $name)
                            .padding(.horizontal, 45)
                    }
                    HStack{
                        Text("Cognome").bold()
                        TextField("Obbligatorio", text: $surname)
                            .padding(.horizontal)
                    }
                    HStack {
                        Text("Email").bold()
                        TextField("Obbligatorio", text: $email)
                            .padding(.horizontal, 50)
                    }
                }header: {
                    Text("Informazioni personali")
                }
                
                Section{
                    List{
                        ForEach(ruoli, id: \.self) { role in
                            Text(role)
                        }.onDelete(perform: delete)
                    }
                }header: {
                    HStack{
                        Text("Ruoli")
                        Spacer()
                        Image(systemName: "arrow.left").font(.caption2).textCase(.lowercase)
                        Text("Swipe per eliminare").font(.caption2)
                    }
                }footer: {
                    Text("I ruoli sono molto importanti a livello di gestione del personale e del ristorante in generale.\nRicordarsi che ogni ruolo ha una specifica funzione ed eliminarli risulterebbe in un cambiamento pratico alle mansioni dell'utente")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Modifica Utente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(id:"Annulla",placement: .navigationBarLeading){
                    Button("Annulla") {
                        dismiss()
                    }
                }
            }
            Spacer()
            Button {
                auth.userToModifyOrDelete = UserStruct(id: user.id, userName: name, userRestaurantID: "", userSurname: surname, userEmail: email, userRoles: ruoli, userNOperator: auth.utente.userNOperator)
                auth.updateData()
                dismiss()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(height: 60)
                    HStack{
                        Image(systemName: "checkmark.seal.fill")
                        Text("Salva Modifica").bold()
                    }
                    .foregroundColor(.white)
                }
            }
            .padding()
            .padding(.horizontal)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    func delete(at offsets: IndexSet) {
        ruoli.remove(atOffsets: offsets)
    }
    func signUp() {
        Task {
            if await auth.signUpWithEmailPassword() == true {
                auth.authenticationState = .authenticated
            }
        }
    }
}

struct UserManagerView_Previews: PreviewProvider {
    static var previews: some View {
        UserManagerView()
            .environmentObject(AuthenticationViewModel())
    }
}
