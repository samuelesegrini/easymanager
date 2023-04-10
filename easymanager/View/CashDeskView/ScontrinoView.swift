//
//  ScontrinoView.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 07/03/23.
//

import SwiftUI

struct ScontrinoView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var auth: AuthenticationViewModel

    @EnvironmentObject var ordine : OrderViewModel
    @EnvironmentObject var prodotto : ProductViewModel
        
    @State private var selectedMain = "Prodotti"
    @State private var selectedTable = ""
    
    @State private var orderSheet : OrderStruct? = nil
    @State private var showingTable = false

    var body: some View {
        VStack {
            Picker("tipologia", selection: $ordine.selectedOption) {
                ForEach(ordine.options, id:\.self){option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            switch ordine.selectedOption {
            case "Tavolo":
                if auth.visualizzazioneScontrino == "moderno" {
                    HStack(spacing: 1) {
                        Menu {
                            Picker("", selection: $selectedTable) {
                                ForEach(ordine.orderList.sorted{ s1, s2 in
                                    if let n1 = Int(s1.orderTable), let n2 = Int(s2.orderTable) {
                                        return n1 < n2
                                    } else {
                                        return s1.orderTable < s2.orderTable
                                    } }, id: \.self){ order in
                                    VStack{
                                        Text(order.orderTable).tag(order.orderTable)
                                    }.tag(order.orderTable)
                                }
                            }
                            .onChange(of: ordine.orderList, perform: { newValue in
                                selectedTable = ""
                                ordine.ordineTavolo = OrderStruct.empty
                            })

                        } label: {
                            ZStack(alignment: .leading){
                                Rectangle()
                                    .tint(Color(UIColor.secondarySystemBackground))
                                HStack{
                                    VStack(alignment: .leading) {
                                        Text(selectedTable == "" ? "Seleziona Tavolo" : "Tavolo : " + selectedTable).font(.headline).foregroundColor(.primary)
                                            .scaledToFill()
                                            .minimumScaleFactor(0.5)
                                            .lineLimit(1)
                                        let us = auth.staffList.first{ $0.id ==  ordine.ordineTavolo.orderSenderID} ?? UserStruct.empty
                                        Text("\(us.userName) \(us.userSurname)").font(.subheadline).foregroundColor(.secondary)
                                            .scaledToFill()
                                            .minimumScaleFactor(0.5)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.down").foregroundColor(.primary)
                                }
                                .padding(20)
                            }
                        }
                        .frame(minWidth: 100)
                        .onChange(of: selectedTable, perform: { newValue in
                            ordine.ordineTavolo = ordine.filterOrderbyTable(tavolo: newValue)
                        })
                    }
                    .frame(height: 65)
                    .cornerRadius(15)
                    .padding(.horizontal, 20)
                } else {
                    Button {
                        showingTable = true
                    } label: {
                        Text("Seleziona Tavolo").font(.subheadline)
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $showingTable) {
                        NavigationStack{
                            sheetTable()
                        }
                    }
                }
                VStack(alignment: .leading){
                    VStack {
                        orderModify()
                        Spacer()
                        Button {
                            ordine.ordineTavolo.orderTotalPrice = ordine.totalAmount(ordine: ordine.ordineTavolo)
                            ordine.updateData(itemToUpdate: ordine.ordineTavolo)
                            
                            ordine.ordineTavolo = ordine.filterOrderbyTable(tavolo: ordine.ordineTavolo.orderTable)
                            orderSheet = ordine.ordineTavolo

                        } label: {
                            ZStack {
                                Rectangle()
                                    .cornerRadius(15)
                                Text("CheckOut : \(ordine.totalAmount(ordine: ordine.ordineTavolo), format: .currency(code: "EUR"))")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                        }
                        .disabled(ordine.totalAmount(ordine: ordine.ordineTavolo).isZero)
                        .frame(height: 60)
                        .padding(.horizontal, 32)
                        .padding(.top)
                        .padding(.bottom, 8)
                        
                        .sheet(item: $orderSheet) { order in
                            VStack {
                                CheckOut(order: ordine.ordineTavolo)
                            }
                        }
                    }
                    Spacer()
                }
                
            default :
                VStack{
                    receiptViewBuilder()
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .padding(.trailing, sizeClass == .compact ? 0 : 20)
    }
    @ViewBuilder
    func receiptViewBuilder() -> some View {
        VStack{
            orderModify()
            
            let totalFoodPrice = ordine.totalAmount(ordine: ordine.ordineVuoto)
            
            Spacer()
            VStack {
                Button {                    
                    ordine.ordineVuoto.orderTable = "\(ordine.selectedOption)" + " \((ordine.biggestNumber ?? 0) + 1)"
                    ordine.ordineVuoto.orderTime = Date()
                    ordine.ordineVuoto.orderTotalPrice = ordine.totalAmount(ordine: ordine.ordineVuoto)
                    ordine.ordineVuoto.orderSenderID = auth.utente.id ?? ""
                    ordine.orderToModifyOrDelete = ordine.ordineVuoto
                    ordine.addData()
                    
                    ordine.ordineVuoto = ordine.filterOrderbyTable(tavolo: ordine.ordineVuoto.orderTable)
                    
                    orderSheet = ordine.ordineVuoto
                    ordine.orderToModifyOrDelete = OrderStruct.empty
                } label: {
                    ZStack {
                        Rectangle()
                            .cornerRadius(15)
                        Text("Completa Ordine \(ordine.totalAmount(ordine: ordine.ordineVuoto), format: .currency(code: "EUR"))")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .disabled(totalFoodPrice.isZero)
                .frame(height: 60)
                .padding(.horizontal)
                .padding()
                .sheet(item: $orderSheet) { order in
                    VStack {
                        CheckOut(order: ordine.ordineVuoto)
                    }
                }
            }
        }
    }
    func sheetTable() -> some View {
        VStack{
            List (ordine.orderList, id: \.self){ order in
                if ordine.options.contains(order.orderTable) {
                }else {
                    Button {
                        ordine.ordineTavolo = order
                        showingTable = false
                        
                    } label: {
                        HStack{
                            VStack(alignment:.leading) {
                                Text("Tavolo : " + order.orderTable).font(.subheadline).foregroundColor(.primary)
                                Text(order.orderTime.formatted()).font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.caption)
                        }
                    }
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .padding(.horizontal)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Ordini ai Tavoli")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showingTable.toggle()
                } label: {
                    Text("Annulla")
                }
            }
        }
    }
}

