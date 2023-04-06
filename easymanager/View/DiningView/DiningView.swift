//
//  DiningView.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import SwiftUI

struct DiningView: View {
    @EnvironmentObject var table : TableViewModel
    @EnvironmentObject var order: OrderViewModel
    @EnvironmentObject var auth: AuthenticationViewModel
    
    private let adaptiveColumns = [
        GridItem(.adaptive(minimum: 90))
    ]
    
    @State private var showingSheet : TableStruct? = nil

    var body: some View {
        //TODO: Create Table Map visualisation and functionalities
        
        VStack {
            DisplayTables()
            Spacer()
        }
    }
    @ViewBuilder
    func DisplayTables() -> some View {
        VStack {
            ScrollView(showsIndicators: false){
                HStack{
                    Text("Tavoli Liberi")
                        .font(.headline)
                        .padding(.leading)
                        .padding(.top)
                }.hAllign(.leading)
                LazyVGrid(columns: adaptiveColumns){
                    ForEach(table.filterStatus(filter: .free)) { table in
                        SingleTable(table, colore: .green)
                    }
                }
                .padding(.leading)
                .padding()
                HStack{
                    Text("Tavoli In Attesa")
                        .font(.headline)
                        .padding(.leading)
                }.hAllign(.leading)
                LazyVGrid(columns: adaptiveColumns){
                    ForEach(table.filterStatus(filter: .waiting)) { table in
                        SingleTable(table, colore: .purple)
                    }
                }
                .padding(.leading)
                .padding()
                HStack{
                    Text("Tavoli Occupati")
                        .font(.headline)
                        .padding(.leading)
                }.hAllign(.leading)
                LazyVGrid(columns: adaptiveColumns){
                    ForEach(table.filterStatus(filter: .occupied)) { table in
                        SingleTable(table, colore: .red)
                    }
                }
                .padding(.leading)
                .padding()
            }
        }
        .navigationTitle("Vista della Sala")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $showingSheet) { tavolo in
            VStack {
                NavigationStack {
                    switch tavolo.tableStatus {
                    case "Libero":
                        TableLibero(tavolo.id ?? "")
                    case "In Attesa":
                        TableInAttesa(tavolo.id ?? "")
                    case "Occupato":
                        TableOccupato(tavolo.id ?? "")
                    default :
                        SheetSingleTable()
                    }
                }
            }
        }
    }
    @ViewBuilder
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
    @ViewBuilder
    func SheetSingleTable() -> some View {
        Text("Errore nell'inserimento dello stato del tavolo").foregroundColor(.red)
    }
    @ViewBuilder
    func TableOccupato(_ id : String) -> some View {
        ForEach(table.tableList.filter{$0.id == id}){ table in
            
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
                VStack(alignment: .leading){
                    
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
                                Text("Orario di inizio servizio \(table.tableServiceBegin.formatted(date: .omitted, time: .shortened))")
                                    .hAllign(.trailing)
                            }
                        }
                        HStack{
                            Text("Numero coperti").foregroundColor(.secondary)
                            Text("\(table.tableSeatsOccupied)")
                                .hAllign(.trailing)
                        }
                    }.listStyle(.plain)
                    
                    HStack{
                        List(order.filterOrderbyTable(tavolo: table.tableName).orderFood, id: \.self){ food in
                            Text(food.foodName)
                        }.listStyle(.plain)
                    }
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
    func TableLibero(_ id : String) -> some View {
        ForEach(table.tableList.filter{$0.id == id}){ table in
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
                    Text("Il tavolo è libero").bold().padding(.vertical)
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
        ForEach(table.tableList.filter{$0.id == id}){ table in
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
                        Text("Il tavolo è in attesa di ordinare").bold()
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
                                    Text(auth.staffList.first{ $0.id == table.waiterID}?.userName ?? "")
                                }
                                 .hAllign(.trailing)
                            }
                            HStack{
                                Text("Inizio Servizio").foregroundColor(.secondary)
                                Text("fetch data di arrivo \(table.tableServiceBegin.formatted(date: .omitted, time: .shortened))")
                                    .hAllign(.trailing)
                            }
                        }
                        HStack{
                            Text("Numero coperti").foregroundColor(.secondary)
                            Text("\(table.tableSeatsOccupied)")
                                .hAllign(.trailing)
                        }
                    }.listStyle(.plain)
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

struct DiningView_Previews: PreviewProvider {
    static var previews: some View {
        DiningView()
            .environmentObject(TableViewModel())
            .environmentObject(OrderViewModel())
    }
}
