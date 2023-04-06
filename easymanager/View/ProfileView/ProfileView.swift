//
//  ProfileView.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthenticationViewModel
    
    @State var presentingConfirmationDialog = false
    
    private func deleteAccount() {
        Task {
            if await auth.deleteAccount() == true {
                auth.authenticationState = .unauthenticated
            }
        }
    }
    
    private func signOut() {
        auth.signOut()
    }
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .center){
                HStack{
                    ZStack{
                        Circle()
                            .foregroundColor(Color.accentColor.opacity(0.15))
                        Circle()
                            .stroke(Color.accentColor, lineWidth: 2)
                        HStack(spacing: 0) {
                            Text(auth.utente.userName.prefix(1).capitalized)
                            Text(auth.utente.userSurname.prefix(1).capitalized)
                        }
                        .font(.title2)
                    }
                    .frame(width: 65 , height: 65)
                    
                    VStack(alignment: .leading){
                        Text("\(auth.utente.userName) \(auth.utente.userSurname)").font(.title2).bold()
                        Text("\(auth.utente.userEmail)").font(.subheadline).foregroundColor(.secondary)
                    }
                }
                .hAllign(.leading)
                .padding()
                    
                List{
                    Section{
                        NavigationLink("Il Tuo Ristorante", destination: RestaurantView())
                    }
                    Section{
                        NavigationLink("Impostazioni App", destination: ImpostazioniAppView())
                    }
                    if auth.utente.userRoles.contains("admin"){
                        Section{
                            NavigationLink {
                                NavigationStack {
                                    UserManagerView()
                                        .environmentObject(auth)
                                }
                            } label: {
                                HStack{
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 7).fill(.red).frame(width: 30, height: 30)
                                        Image(systemName: "person.crop.circle").scaledToFit().foregroundColor(.white)
                                    }
                                    .padding(.trailing, 5)
                                    Text("Gestione Dipendenti")
                                }
                            }
                            NavigationLink {
                                NavigationStack {
                                    ProductsManagerView()
                                }
                            } label: {
                                HStack{
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 7).fill(.green).frame(width: 30, height: 30)
                                        Image(systemName: "carrot.fill").scaledToFit().foregroundColor(.white)
                                    }
                                    .padding(.trailing, 5)
                                    Text("Gestione Prodotti")
                                }
                            }
                            NavigationLink {
                                NavigationStack {
                                    TableManagerView()
                                }
                            } label: {
                                HStack{
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 7).fill(.blue).frame(width: 30, height: 30)
                                        Image(systemName: "table.furniture.fill").scaledToFit().foregroundColor(.white)
                                    }
                                    .padding(.trailing, 5)
                                    Text("Gestione Tavoli")
                                }
                            }
                        }
                    }
                    //TODO: Search more non fiscal Printers
                    Section {
                        Button(role: .cancel, action: signOut) {
                            HStack {
                                Image(systemName: "signpost.left")
                                Text("Sign out")
                            }
                            .foregroundColor(.blue)
                            .hAllign(.center)
                        }
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Profilo")
            .navigationBarTitleDisplayMode(.inline)
        }
        .confirmationDialog("Eliminare un account è permanenten e puoi creare un account solo tramite il titolare. Vuoi continuare?",
                            isPresented: $presentingConfirmationDialog, titleVisibility: .visible) {
            Button("Elimina Account", role: .destructive, action: deleteAccount)
            Button("Cancel", role: .cancel, action: { })
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
