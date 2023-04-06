//
//  SideBarView.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 29/11/22.
//

import SwiftUI

struct SideBarView: View {
    @EnvironmentObject var auth: AuthenticationViewModel
        
    var body: some View {
        VStack{
            List{
                if auth.utente.userRoles.contains("cucina"){
                    Section {
                        NavigationButton(title: "POS", imageName: "cooktop", color: .blue, nextView: CookingView())

                    }header: {
                        Text("Gestione Cucina")
                    }
                }
                    
                if !auth.utente.userRoles.filter({ $0 == "pos"}).isEmpty {
                    Section {
                        NavigationButton(title: "POS", imageName: "wallet.pass", color: .orange, nextView: CashDesk())

                    }header: {
                        Text("Cassa Ristorante")
                    }
                    
                }else if !auth.utente.userRoles.filter({$0 == "cameriere"}).isEmpty {
                    Section {
                        NavigationButton(title: "Ordina", imageName: "fork.knife", color: .yellow, nextView: OrdersView())
                        
                    }header: {
                        Text("Fai un Ordine")
                    }
                }
                Section {
                    NavigationButton(title: "Tavoli", imageName: "table.furniture", color: .purple, nextView: DiningView())
    
                }header: {
                    Text("Sala")
                }
                Section {
                    NavigationButton(title: "\(auth.utente.userName) \(auth.utente.userSurname)", imageName: "person.and.background.dotted", color: .green, nextView: ProfileView())

                } header: {
                    Text("Gestione Ristorante")
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            
        }
        .background(.ultraThinMaterial)
    }
}


struct NavigationButton<TargetView: View>: View {
    
    var title: String
    var imageName: String
    var color: Color
    var nextView: TargetView
    
    var body: some View {
        NavigationLink(destination: nextView) {
            HStack {
                ZStack{
                    Rectangle()
                        .cornerRadius(10)
                        .frame(width: 35,height: 35)
                        .foregroundColor(color)
                    Image(systemName: imageName).bold()
                        .foregroundColor(.white)
                }
                .padding(5)
                Text(title).font(.headline.bold())
                    .foregroundColor(.primary)
            }
        }
        .foregroundColor(.secondary)
    }
}
