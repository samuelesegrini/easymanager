//
//  WrapperView.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import SwiftUI

struct WrapperView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @EnvironmentObject var auth : AuthenticationViewModel
    
    @State private var selectedTabView = 0
    @State private var showingSheet = false
    
    var body: some View {
        if sizeClass != .compact {
            NavigationSplitView {
                VStack {
                    if auth.utente.userRoles.filter({ $0 == "admin" }).isEmpty {
                        SideBarView()
                    }else{
                        if selectedTabView == 0 {
                            SideBarView()
                            
                        }else if selectedTabView == 1 {
                            TurniView()
                        }
                        Spacer()
                        Picker("Pagina", selection: $selectedTabView){
                            Image(systemName: "face.smiling.inverse").tag(0)
                            Image(systemName: "person.badge.clock").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding()
                    }
                }
                .navigationTitle("Easy Manager")
                .navigationBarTitleDisplayMode(sizeClass == .compact ? .inline : .large)
                .navigationSplitViewColumnWidth(min: 200, ideal: 300, max: 600)
                .background(.ultraThinMaterial)
            } detail: {
                if !auth.utente.userRoles.filter({ $0 == "pos"}).isEmpty {
                    CashDesk()
                    
                }else if !auth.utente.userRoles.filter({$0 == "cameriere"}).isEmpty {
                    OrdersView()
                }
            }
        }else {
            TabView {
                if auth.utente.userRoles.contains("cucina"){
                    CookingView()
                        .tabItem {
                            Label("Cucina", systemImage: "cooktop")
                        }
                }
                if !auth.utente.userRoles.filter({$0 == "pos"}).isEmpty {
                    CashDesk()
                        .tabItem {
                            Label("POS", systemImage: "wallet.pass")
                        }
                    DiningView()
                        .tabItem {
                            Label("Tavoli", systemImage: "table.furniture")
                        }
                }else if !auth.utente.userRoles.filter({$0 == "cameriere"}).isEmpty {
                    OrdersView()
                        .tabItem {
                            Label("Ordina", systemImage: "fork.knife")
                        }
                }
                ProfileView()
                    .tabItem{
                        Label("Profilo", systemImage: "person.crop.circle")

                    }
            }
            .tabViewStyle(.automatic)
        }
    }
}

struct WrapperView_Previews: PreviewProvider {
    static var previews: some View {
        WrapperView()
            .environmentObject(AuthenticationViewModel())
    }
}
