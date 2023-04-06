//
//  OrdersView.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import SwiftUI

struct OrdersView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var auth: AuthenticationViewModel
    @EnvironmentObject var tavolo: TableViewModel
    @EnvironmentObject var order: OrderViewModel
    @EnvironmentObject var product: ProductViewModel
    
    @State private var showingSheet : TableStruct? = nil
    @State private var showingProduct : ProductsStruct? = nil
    @State private var noteTavolo = ""
    @State private var coperto = ""
    @State private var numeroCop = 0
    
    private let adaptiveColumns = [
        GridItem(.adaptive(minimum: 90))
    ]
    
    var body: some View {
        NavigationStack {
            if sizeClass != .compact {
                HStack{
                    ScrollView(showsIndicators: false){
                        DisplayTables()
                    }
                    .padding(.vertical)
                    .padding(.leading)
                    MyOrders()
                        .padding()
                        .frame(width: 400)
                }
            }else {
                DisplayTables()
            }
        }
        .background(.ultraThinMaterial)
        .navigationTitle("Nuovo Ordine")
        .navigationBarTitleDisplayMode(.inline)
    }
    @ViewBuilder
    func DisplayTables() -> some View {
        VStack {
            ZStack{
                Rectangle()
                    .fill(Color(UIColor.systemBackground))
                    .cornerRadius(15)
                VStack{
                    HStack{
                        Text("Tavoli Liberi")
                            .font(.headline)
                            .padding(.leading)
                    }.hAllign(.leading)
                    LazyVGrid(columns: adaptiveColumns){
                        ForEach(tavolo.filterStatus(filter: .free)) { table in
                            SingleTable(table, colore: .green)
                        }
                    }
                    .padding(.leading)
                    .padding(.bottom)
                }
                .padding()
            }
            ZStack{
                Rectangle()
                    .fill(Color(UIColor.systemBackground))
                    .cornerRadius(15)
                VStack{
                    HStack{
                        Text("Tavoli In Attensa di Ordinare")
                            .font(.headline)
                            .padding(.leading)
                    }.hAllign(.leading)
                    LazyVGrid(columns: adaptiveColumns){
                        ForEach(tavolo.filterStatus(filter: .waiting)) { table in
                            SingleTable(table, colore: .purple)
                        }
                    }
                    .padding(.leading)
                    .padding(.bottom)
                }
                .padding()
            }
            ZStack{
                Rectangle()
                    .fill(Color(UIColor.systemBackground))
                    .cornerRadius(15)
                VStack{
                    HStack{
                        Text("Tavoli Occupati")
                            .font(.headline)
                            .padding(.leading)
                    }.hAllign(.leading)
                    LazyVGrid(columns: adaptiveColumns){
                        ForEach(tavolo.filterStatus(filter: .occupied)) { tavolo in
                            SingleTable(tavolo, colore: .red)
                        }
                    }
                    .padding(.leading)
                    .padding(.bottom)
                }
                .padding()
            }
        }
        .sheet(item: $showingSheet) { tavolo in
            NavigationStack {
                switch tavolo.tableStatus {
                case "Libero":
                    TableLibero(tavolo.id ?? "")
                case "In Attesa":
                    TableInAttesa(tavolo.id ?? "")
                case "Occupato":
                    TableOccupato(tavolo.id ?? "")
                default:
                    Text("Non trovato")
                }
            }
        }
    }
    func SingleTable(_ tavolo : TableStruct, colore : Color) -> some View {
        Button {
            showingSheet = tavolo
        } label: {
            ZStack {
                Rectangle()
                    .frame(width: 80, height: 80)
                    .cornerRadius(15)
                    .foregroundColor(colore)
                RoundedRectangle(cornerRadius: 15)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [10.0]))
                    .frame(width: 90, height: 90)
                    .foregroundColor(colore)
                VStack {
                    Text(tavolo.tableName)
                    Text(tavolo.tableStatus)
                    Text("\(tavolo.tableSeats) posti")
                }
                .foregroundColor(.white)
            }
        }
    }
    func MyOrders() -> some View {
        VStack(alignment: .center){
            Circle()
                .frame(width: 80, height: 80)
                .padding(.top)
            Text(auth.utente.userName).font(.headline)
            HStack{
                ForEach(auth.utente.userRoles, id:\.self){ role in
                    Text(role + " ").font(.caption).foregroundColor(.secondary)
                }
            }
            
            Text("Tavoli gestiti da Te").font(.headline)
                .hAllign(.leading)
                .padding(.leading)
                .padding(.top)
            
            Table(order.orderList.filter{ $0.orderSenderID == auth.utente.id ?? "" }){
                TableColumn("Tavolo"){ item in
                    Text(item.orderTable).font(.subheadline)
                }
                TableColumn("Totale"){ item in
                    Text("\(item.orderTotalPrice, format: .currency(code: "EUR"))").font(.caption)
                }
                TableColumn("Orario"){ item in
                    Text(item.orderTime.formatted(date: .omitted, time: .shortened)).font(.caption)
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
    }
    @ViewBuilder
    func TableOccupato(_ id : String) -> some View {
        ForEach(tavolo.tableList.filter{$0.id == id}){ table in
            VStack(alignment: .leading){
                HStack{
                    Text("Tavolo \(table.tableName)").font(.headline)
                        .padding(.trailing)
                    Text(table.tableStatus).font(.caption).foregroundColor(.red)
                        .padding(10)
                        .background(
                            Rectangle()
                                .fill(.red.opacity(0.2))
                                .cornerRadius(15)
                        )
                }
                if table.waiterID == auth.utente.id {
                    Text("Ordini Attivi").bold()
                            .padding(.top)

                    HStack{
                        List(order.filterOrderbyTable(tavolo: table.tableName).orderFood, id: \.self){ food in
                            Text(food.foodName)
                        }.listStyle(.plain)
                    }
                    
                    Spacer()
                    NavigationLink {
                        OrderSheetView(tableId: table.id ?? "")
                    } label: {
                        ZStack{
                            Rectangle()
                                .fill(.secondary.opacity(0.3))
                                .frame(height: 50)
                                .cornerRadius(15)
                            Text("Fai un altro Ordine")
                        }.foregroundColor(.red)
                    }
                    .padding()
                }else{
                    VStack(alignment: .leading){
                        HStack{
                            Image(systemName: "exclamationmark.triangle").font(.title)
                            Text("Il tavolo è stato preso in carica da un altro cameriere, vuoi gestire tu il tavolo al suo posto?").bold()
                        }
                        .padding()
                        .foregroundColor(.red)
                        .background(
                            Rectangle()
                                .fill(.red.opacity(0.2))
                        )
                        .cornerRadius(15)
                        .frame(height: 100)
                        .hAllign(.center)
                        
                        List{
                            Section{
                                HStack{
                                    Text("Operatore").foregroundColor(.secondary)
                                    VStack(alignment: .trailing){
                                        Text(auth.staffList.first{ $0.id == table.waiterID}?.userName ?? "") .foregroundColor(.secondary).font(.caption).strikethrough(true)
                                        Text("\(auth.utente.userName) \(auth.utente.userSurname)").padding(.bottom, 5)
                                    }
                                    .hAllign(.trailing)
                                }
                                HStack{
                                    Text("Inizio Servizio").foregroundColor(.secondary)
                                    Text("\(table.tableServiceBegin.formatted(date: .omitted, time: .shortened))")
                                        .hAllign(.trailing)
                                }
                            }
                            HStack{
                                Text("Numero coperti").foregroundColor(.secondary)
                                Text("\(table.tableSeatsOccupied)")
                                    .hAllign(.trailing)
                            }
                        }.listStyle(.plain)
                        
                        Text("Ordini Attivi").bold()
                            .padding(.top)
                        HStack{
                            List(order.filterOrderbyTable(tavolo: table.tableName).orderFood, id: \.self){ food in
                                Text(food.foodName)
                            }.listStyle(.plain)
                        }
                        
                        Spacer()
                        NavigationLink {
                            OrderSheetView(tableId: table.id ?? "")
                        } label: {
                            ZStack{
                                Rectangle()
                                    .fill(.secondary.opacity(0.3))
                                    .frame(height: 50)
                                    .cornerRadius(15)
                                Text("Gestisci tu il Tavolo")
                            }.foregroundColor(.red)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            tavolo.updateData(table: TableStruct(id: table.id, userRestaurantID: table.userRestaurantID, waiterID: auth.utente.id ?? "", tableServiceBegin: table.tableServiceBegin, tableSeatsOccupied: table.tableSeatsOccupied, tableName: table.tableName, tableSeats: table.tableSeats, tableStatus: "Occupato"))
                        })
                        .padding()
                    }
                    .background(Rectangle()
                        .fill(Color(UIColor.systemBackground))
                        .cornerRadius(15)
                        .padding())
                }
                
            }
            .padding()
            .navigationTitle("Tavolo \(table.tableName)")
            .toolbar(.hidden)
        }
    }
    @ViewBuilder
    func TableLibero(_ id : String) -> some View {
        ForEach(tavolo.tableList.filter{$0.id == id}){ table in
            VStack(alignment: .leading){
                HStack{
                    Text("Tavolo \(table.tableName)").font(.headline)
                        .padding(.trailing)
                    Text(table.tableStatus).font(.caption).foregroundColor(.green)
                        .padding(10)
                        .background(
                            Rectangle()
                                .fill(.green.opacity(0.2))
                                .cornerRadius(15)
                        )
                }
                VStack(alignment: .leading){
                    Text("Il tavolo è libero vuoi prenderlo in consegna?").bold().padding(.vertical)
                    List{
                        Section{
                            HStack{
                                Text("Operatore").foregroundColor(.secondary)
                                Text("\(auth.utente.userName) \(auth.utente.userSurname)")
                                    .hAllign(.trailing)
                            }
                            HStack{
                                Text("Inizio Servizio").foregroundColor(.secondary)
                                Text(Date().formatted(date: .omitted, time: .shortened))
                                    .hAllign(.trailing)
                            }
                        }
                        HStack{
                            Picker("Prezzo Coperto", selection: $coperto) {
                                ForEach(tavolo.copertoList){ cop in
                                    Text(cop.nomeCoperto).tag(cop.nomeCoperto)
                                }
                            }
                        }
                        HStack{
                            Picker("Numero Coperti da Inserire", selection: $numeroCop) {
                                //Need for a non costant range to display current seats avaiable
                                ForEach(1..<table.tableSeats){ seat in
                                    Text("\(seat)").tag(seat)
                                }
                            }
                        }
                    }.listStyle(.plain)
                    Spacer()
                    NavigationLink {
                        OrderSheetView(tableId: table.id ?? "")
                    } label: {
                        ZStack{
                            Rectangle()
                                .fill(.secondary.opacity(0.3))
                                .frame(height: 50)
                                .cornerRadius(15)
                            Text("Rendi il tavolo In Attesa")
                        }.foregroundColor(.green)
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        tavolo.updateData(table: TableStruct(id: table.id, userRestaurantID: table.userRestaurantID, waiterID: auth.utente.id ?? "", tableServiceBegin: Date(), tableSeatsOccupied: table.tableSeatsOccupied, tableName: table.tableName, tableSeats: table.tableSeats, tableStatus: "In Attesa"))
                    })
                    .padding()
                }
                .background(Rectangle()
                    .fill(Color(UIColor.systemBackground))
                    .cornerRadius(15)
                    .padding())
            }
            .padding()
            .navigationTitle("Tavolo \(table.tableName)")
            .toolbar(.hidden)
        }
    }
    @ViewBuilder
    func TableInAttesa(_ id : String) -> some View {
        ForEach(tavolo.tableList.filter{$0.id == id}){ table in
            VStack(alignment: .leading){
                HStack{
                    Text("Tavolo \(table.tableName)").font(.headline)
                        .padding(.trailing)
                    Text(table.tableStatus).font(.caption).foregroundColor(.purple)
                        .padding(10)
                        .background(
                            Rectangle()
                                .fill(.purple.opacity(0.2))
                                .cornerRadius(15)
                        )
                }
                VStack(alignment: .leading){
                    HStack{
                        Image(systemName: "exclamationmark.triangle").font(.title)
                        Text("Il tavolo è in attesa di ordinare, vuoi gestire tu il tavolo e fare l'ordinazione?").bold()
                    }
                    .padding()
                    .foregroundColor(.purple)
                    .background(
                        Rectangle()
                            .fill(.purple.opacity(0.2))
                    )
                    .cornerRadius(15)
                    .frame(height: 100)
                    .hAllign(.center)
                    List{
                        Section{
                            HStack{
                                Text("Operatore").foregroundColor(.secondary)
                                VStack(alignment: .trailing){
                                    Text(auth.staffList.first{ $0.id == table.waiterID}?.userName ?? "").foregroundColor(.secondary).font(.caption).strikethrough(true)
                                    Text("\(auth.utente.userName) \(auth.utente.userSurname)").padding(.bottom, 5)
                                }
                                .hAllign(.trailing)
                            }
                            HStack{
                                Text("Inizio Servizio").foregroundColor(.secondary)
                                Text("\(table.tableServiceBegin.formatted(date: .omitted, time: .shortened))")
                                    .hAllign(.trailing)
                            }
                        }
                        HStack{
                            Text("Numero coperti").foregroundColor(.secondary)
                            Text("\(table.tableSeatsOccupied)")
                                .hAllign(.trailing)
                        }
                    }.listStyle(.plain)
                    Spacer()
                    NavigationLink {
                        OrderSheetView(tableId: table.id ?? "")
                    } label: {
                        ZStack{
                            Rectangle()
                                .fill(.secondary.opacity(0.3))
                                .frame(height: 50)
                                .cornerRadius(15)
                            Text("Ordina e Gestisci Tu il Tavolo")
                        }.foregroundColor(.purple)
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        tavolo.updateData(table: TableStruct(id: table.id, userRestaurantID: table.userRestaurantID, waiterID: auth.utente.id ?? "", tableServiceBegin: table.tableServiceBegin, tableSeatsOccupied: table.tableSeatsOccupied, tableName: table.tableName, tableSeats: table.tableSeats, tableStatus: "Occupato"))
                    })
                    .padding()
                }
                .background(Rectangle()
                    .fill(Color(UIColor.systemBackground))
                    .cornerRadius(15)
                    .padding())
            }
            .padding()
            .navigationTitle("Tavolo \(table.tableName)")
            .toolbar(.hidden)
        }
    }
}


struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersView()
            .environmentObject(TableViewModel())
            .environmentObject(OrderViewModel())
            .environmentObject(AuthenticationViewModel())
    }
}
