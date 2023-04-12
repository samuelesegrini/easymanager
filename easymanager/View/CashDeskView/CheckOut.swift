//
//  provaview.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 22/11/22.
//

import SwiftUI

struct pagamento: Identifiable {
    var id = UUID()
    var pagamentoTipo : Int
    var pagamentoImporto : Double
}

struct CheckOut: View {
    @State private var isEditing = false

    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var ordine : OrderViewModel
    @EnvironmentObject var printerManager : PrinterViewModel
    @EnvironmentObject var table : TableViewModel
    @EnvironmentObject var auth : AuthenticationViewModel
        
    @State private var numeroConti = 1.0
    @State private var subtotale : Double = 0
    @State private var importoPagato : Double = 0
    
    @State private var payement : [pagamento] = []
    @State private var pagamentoTipo : String = "Contante"
    @State private var tastierinoSelection = false
    @State private var pagatoDef : Double = 0
    
    @State private var showTicket = false
    @State private var numberTicket : Double = 1
    @State private var valueTicket : Double = 1
    
    @State private var calcolator = false
    
    @State private var multiSelection = Set<Food>()
    @State var order : OrderStruct
    
    @State private var contanti : Double = 0
    @State private var elettronico : Double = 0
    @State private var ticket : Double = 0

    let grid = [
            ["7", "8", "9", "AC"],
            ["4", "5", "6", "x"],
            ["1", "2", "3", "+"],
            [",", "0", "=", "⌦"]
        ]
        
    let operators = ["+", "X"]
    
    @State var visibleWorkings = ""
    @State var visibleResults : Double = 0
    @State var showAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Picker(selection: $printerManager.receiptType, label: Text("Metodo Ricevuta")) {
                    ForEach(ReceiptType.allCases, id: \.self){ type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                displayFoodBuilder(order: order)
                
                if printerManager.receiptType != .preconto {
                    if printerManager.receiptType == .scontrinoFiscale {
                        Button {
                            self.isEditing.toggle()
                        } label: {
                            Text(self.isEditing ? "Annulla" : "Seleziona singoli alimenti")
                        }
                        .padding(.horizontal, 30)
                        
                        if multiSelection.isEmpty{
                            Stepper("Dividi il conto alla romana tra \(numeroConti, format: .number)", value: $numeroConti, in: 1...50)
                                .padding(.bottom)
                                .onChange(of: numeroConti) { newValue in
                                    if multiSelection.isEmpty {
                                        subtotale = order.orderTotalPrice / newValue
                                        print("Subtotale diviso \(newValue)")
                                    }else {
                                        subtotale = ordine.totalAmount(ordine: OrderStruct(userRestaurantID: "", orderFood: Array(multiSelection), orderTime: order.orderTime, orderTotalPrice: order.orderTotalPrice, orderTable: order.orderTable, orderSenderID: order.orderSenderID)) / newValue
                                    }
                                }
                                .padding(.horizontal,30)
                        }
                    }
                    VStack(spacing: .zero) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Subtotale").font(.subheadline)
                                Spacer()
                                
                                Text("\(subtotale, format: .currency(code: "EUR"))").font(.subheadline)
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.top)
                        .padding(.bottom, 8.0)
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.tertiarySystemGroupedBackground))
                        .cornerRadius(12.0, corners: [.topLeft, .topRight])
                        
                        receiptDrawComponent()
                        
                        HStack {
                            Text("Totale")
                            Spacer()
                            Text("\(order.orderTotalPrice, format: .currency(code: "EUR"))")
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical)
                        .padding(.bottom, 8.0)
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.tertiarySystemGroupedBackground))
                        .cornerRadius(12.0, corners: [.bottomLeft, .bottomRight])
                    }
                    .padding(.horizontal)
                    
                    NavigationLink {
                        PayementView()
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 15)
                            
                            Text("Pagamento di \(subtotale, format: .currency(code: "EUR"))")
                                .foregroundColor(.white)
                                .font(.title3).bold()
                        }
                    }
                    .frame(height: 70)
                    .padding()
                    
                }else {
                    Button {
                        printerManager.sendXMLRequest(receipt: order, subtotale: subtotale, pagamento: [], user: auth.utente)
                        ordine.ordineVuoto = OrderStruct.empty
                        dismiss()
                    } label: {
                        ZStack {
                            Rectangle()
                                .cornerRadius(15)
                            Text("Stampa Preconto")
                                .foregroundColor(.white)
                                .font(.title3).bold()
                        }
                    }
                    .frame(height: 70)
                    .padding()
                }
            }
            .onAppear{
                subtotale = order.orderTotalPrice
                print("Subtotale iniziale")
            }
            .navigationTitle("Scontrino")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    func displayFoodBuilder(order : OrderStruct) -> some View {
        List(order.orderFood, id:\.self, selection: $multiSelection){ food in
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(food.foodName).strikethrough(food.foodReversed).font(.headline).bold()
                    ScrollView(.horizontal,showsIndicators: false) {
                        HStack(spacing: 1){
                            ForEach(food.foodVariants, id:\.self){ variant in
                                if (variant.variantChecked){
                                    Text("\(variant.variantName.capitalized)").strikethrough(food.foodReversed)
                                        .font(.caption2)
                                        .padding(.horizontal)
                                        .padding(.vertical, 3)
                                        .background(Color.accentColor.opacity(0.2))
                                    Text(" ")
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                    HStack {
                        Text("\(food.foodQuantity, specifier: "%.0f")x").strikethrough(food.foodReversed).font(.caption2).foregroundColor(.gray)
                    }
                }
                Spacer()
                Text("\(ordine.totalFood(food: food), format: .currency(code: "EUR"))").strikethrough(food.foodReversed).font(.headline).foregroundColor(.accentColor)
            }
            .frame(height: 55)
        }
        .onChange(of: multiSelection){ newValue in
            if !newValue.isEmpty {
                subtotale = ordine.totalAmount(ordine: OrderStruct(userRestaurantID: "", orderFood: Array(
                    newValue.map{ food in
                        Food(foodVariants: food.foodVariants, foodName: food.foodName, foodIva: food.foodIva, foodPortata: food.foodPortata, foodReversed: food.foodReversed, foodPrice: food.foodPrice, foodQuantity: food.foodQuantity)}),
                    orderTime: order.orderTime, orderTotalPrice: order.orderTotalPrice, orderTable: order.orderTable, orderSenderID: order.orderSenderID))
            }
        }
        .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive))
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .padding(.horizontal)
    }
    @ViewBuilder
    func PayementView() -> some View {
        VStack{
            Text("Pagamento 1 di \(numeroConti, format: .number)")
                .foregroundColor(.secondary)
            HStack{
                VStack{
                    Text("Totale")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(subtotale, format: .currency(code: "EUR"))")
                        .font(.title3).bold()
                }
                .padding()
                Divider()
                    .frame(height: 80)
                VStack{
                    Text("Da Pagare")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    let diff = subtotale - pagatoDef
                    if diff > 0 {
                        Text("\(diff, format: .currency(code: "EUR"))")
                            .font(.title3).bold()
                    }else{
                        Text("\(0, format: .currency(code: "EUR"))")
                            .font(.title3).bold()
                    }
                }
                .padding()
                Divider()
                    .frame(height: 80)
                VStack{
                    Text("Resto")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    let resto = -(subtotale - pagatoDef)
                    if resto > 0 {
                        Text("\(resto, format: .currency(code: "EUR"))")
                            .font(.title3).bold()
                    }else{
                        Text("\(0, format: .currency(code: "EUR"))")
                            .font(.title3).bold()
                    }
                }
                .padding()
            }
            HStack{
                Button {
                    payement.append(pagamento(pagamentoTipo: 0, pagamentoImporto: subtotale))

                    if order.orderTotalPrice == subtotale {
                        printerManager.sendXMLRequest(receipt: order, subtotale: subtotale, pagamento: payement, user: auth.utente)
                        
                        var t = table.tableList.first{ t in
                            t.tableName == order.orderTable && t.waiterID == order.orderSenderID
                        } ?? TableStruct.empty
                        
                        t.tableStatus = "Libero"
                        t.tableSeatsOccupied = 0
                        t.waiterID = ""
                        
                        if t.id != ""{
                            table.updateData(table: t)
                        }
                        
                        if ordine.selectedOption == "Tavolo"{
                            ordine.orderToModifyOrDelete = ordine.ordineTavolo
                            ordine.saveOrder()

                            ordine.deleteData(order: ordine.ordineTavolo)
                            ordine.ordineTavolo = OrderStruct.empty
                            dismiss()
                        }else{
                            ordine.orderToModifyOrDelete = ordine.ordineVuoto
                            ordine.saveOrder()

                            ordine.deleteData(order: ordine.ordineVuoto)
                            ordine.ordineVuoto = OrderStruct.empty
                            dismiss()
                        }
                    }else {
                        //If user selected only some of the products
                        if !multiSelection.isEmpty{
                            order.orderFood = order.orderFood.filter{ Array(multiSelection).contains($0) }
                            
                            printerManager.sendXMLRequest(receipt: order, subtotale: subtotale, pagamento: payement, user: auth.utente)
                            
                            if ordine.selectedOption == "Tavolo"{
                                order.orderFood = order.orderFood.filter{ !Array(multiSelection).contains($0) }
                                order.orderTotalPrice = ordine.totalAmount(ordine: order)
                                
                                ordine.ordineTavolo = order
                            }else{
                                order.orderFood = order.orderFood.filter{ !Array(multiSelection).contains($0) }
                                order.orderTotalPrice = ordine.totalAmount(ordine: order)
                                
                                ordine.ordineVuoto = order
                            }
                        }else{
                            if numeroConti > 1 {
                                printerManager.sendXMLRequest(receipt: order, subtotale: subtotale, pagamento: payement, user: auth.utente)

                                if ordine.selectedOption == "Tavolo"{
                                    order.orderTotalPrice -= subtotale
                                    ordine.ordineTavolo.orderTotalPrice -= subtotale

                                }else{
                                    order.orderTotalPrice -= subtotale
                                    ordine.ordineVuoto.orderTotalPrice -= subtotale

                                }
                                numeroConti -= 1
                            }else{
                                var t = table.tableList.first{ t in
                                    t.tableName == order.orderTable && t.waiterID == order.orderSenderID
                                } ?? TableStruct.empty
                                
                                t.tableStatus = "Libero"
                                t.tableSeatsOccupied = 0
                                t.waiterID = ""
                                
                                if t.id != ""{
                                    table.updateData(table: t)
                                }
                                
                                if ordine.selectedOption == "Tavolo"{
                                    ordine.deleteData(order: ordine.ordineTavolo)
                                    ordine.ordineTavolo = OrderStruct.empty
                                    dismiss()
                                }else{
                                    ordine.deleteData(order: ordine.ordineVuoto)
                                    ordine.ordineVuoto = OrderStruct.empty
                                    dismiss()
                                }
                            }
                        }
                    }
                    payement = []
                    pagatoDef = 0
                    pagamentoTipo = "Contante"
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(.green)
                        Text("Contante")
                            .foregroundColor(.white)
                            .bold()
                    }
                }
                Button {
                    payement.append(pagamento(pagamentoTipo: 2, pagamentoImporto: subtotale))

                    if order.orderTotalPrice == subtotale {
                        printerManager.sendXMLRequest(receipt: order, subtotale: subtotale, pagamento: payement, user: auth.utente)
                        
                        var t = table.tableList.first{ t in
                            t.tableName == order.orderTable && t.waiterID == order.orderSenderID
                        } ?? TableStruct.empty
                        
                        t.tableStatus = "Libero"
                        t.tableSeatsOccupied = 0
                        t.waiterID = ""
                        
                        if t.id != ""{
                            table.updateData(table: t)
                        }
                        
                        if ordine.selectedOption == "Tavolo"{
                            ordine.orderToModifyOrDelete = ordine.ordineTavolo
                            ordine.saveOrder()

                            ordine.deleteData(order: ordine.ordineTavolo)
                            ordine.ordineTavolo = OrderStruct.empty
                            dismiss()
                        }else{
                            ordine.orderToModifyOrDelete = ordine.ordineVuoto
                            ordine.saveOrder()

                            ordine.deleteData(order: ordine.ordineVuoto)
                            ordine.ordineVuoto = OrderStruct.empty
                            dismiss()
                        }
                    }else {
                        //If user selected only some of the products
                        if !multiSelection.isEmpty{
                            order.orderFood = order.orderFood.filter{ Array(multiSelection).contains($0) }
                            
                            printerManager.sendXMLRequest(receipt: order, subtotale: subtotale, pagamento: payement, user: auth.utente)
                            
                            if ordine.selectedOption == "Tavolo"{
                                order.orderFood = order.orderFood.filter{ !Array(multiSelection).contains($0) }
                                order.orderTotalPrice = ordine.totalAmount(ordine: order)
                                
                                ordine.ordineTavolo = order
                            }else{
                                order.orderFood = order.orderFood.filter{ !Array(multiSelection).contains($0) }
                                order.orderTotalPrice = ordine.totalAmount(ordine: order)
                                
                                ordine.ordineVuoto = order
                            }
                        }else{
                            if numeroConti > 1 {
                                printerManager.sendXMLRequest(receipt: order, subtotale: subtotale, pagamento: payement, user: auth.utente)

                                if ordine.selectedOption == "Tavolo"{
                                    order.orderTotalPrice -= subtotale
                                    ordine.ordineTavolo.orderTotalPrice -= subtotale

                                }else{
                                    order.orderTotalPrice -= subtotale
                                    ordine.ordineVuoto.orderTotalPrice -= subtotale

                                }
                                numeroConti -= 1
                            }else{
                                var t = table.tableList.first{ t in
                                    t.tableName == order.orderTable && t.waiterID == order.orderSenderID
                                } ?? TableStruct.empty
                                
                                t.tableStatus = "Libero"
                                t.tableSeatsOccupied = 0
                                t.waiterID = ""
                                
                                if t.id != ""{
                                    table.updateData(table: t)
                                }
                                
                                if ordine.selectedOption == "Tavolo"{
                                    ordine.deleteData(order: ordine.ordineTavolo)
                                    ordine.ordineTavolo = OrderStruct.empty
                                    dismiss()
                                }else{
                                    ordine.deleteData(order: ordine.ordineVuoto)
                                    ordine.ordineVuoto = OrderStruct.empty
                                    dismiss()
                                }
                            }
                        }
                    }
                    payement = []
                    pagatoDef = 0
                    pagamentoTipo = "Contante"
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(.orange)
                        Text("Carta")
                            .foregroundColor(.white)
                            .bold()
                    }
                }
                Button {
                    payement.append(pagamento(pagamentoTipo: 2, pagamentoImporto: subtotale))

                    if order.orderTotalPrice == subtotale {
                        printerManager.sendXMLRequest(receipt: order, subtotale: subtotale, pagamento: payement, user: auth.utente)
                        
                        var t = table.tableList.first{ t in
                            t.tableName == order.orderTable && t.waiterID == order.orderSenderID
                        } ?? TableStruct.empty
                        
                        t.tableStatus = "Libero"
                        t.tableSeatsOccupied = 0
                        t.waiterID = ""
                        
                        if t.id != ""{
                            table.updateData(table: t)
                        }
                        
                        if ordine.selectedOption == "Tavolo"{
                            ordine.orderToModifyOrDelete = ordine.ordineTavolo
                            ordine.saveOrder()

                            ordine.deleteData(order: ordine.ordineTavolo)
                            ordine.ordineTavolo = OrderStruct.empty
                            dismiss()
                        }else{
                            ordine.orderToModifyOrDelete = ordine.ordineVuoto
                            ordine.saveOrder()

                            ordine.deleteData(order: ordine.ordineVuoto)
                            ordine.ordineVuoto = OrderStruct.empty
                            dismiss()
                        }
                    }else {
                        //If user selected only some of the products
                        if !multiSelection.isEmpty{
                            order.orderFood = order.orderFood.filter{ Array(multiSelection).contains($0) }
                            
                            printerManager.sendXMLRequest(receipt: order, subtotale: subtotale, pagamento: payement, user: auth.utente)
                            
                            if ordine.selectedOption == "Tavolo"{
                                order.orderFood = order.orderFood.filter{ !Array(multiSelection).contains($0) }
                                order.orderTotalPrice = ordine.totalAmount(ordine: order)
                                
                                ordine.ordineTavolo = order
                            }else{
                                order.orderFood = order.orderFood.filter{ !Array(multiSelection).contains($0) }
                                order.orderTotalPrice = ordine.totalAmount(ordine: order)
                                
                                ordine.ordineVuoto = order
                            }
                        }else{
                            if numeroConti > 1 {
                                printerManager.sendXMLRequest(receipt: order, subtotale: subtotale, pagamento: payement, user: auth.utente)

                                if ordine.selectedOption == "Tavolo"{
                                    order.orderTotalPrice -= subtotale
                                    ordine.ordineTavolo.orderTotalPrice -= subtotale

                                }else{
                                    order.orderTotalPrice -= subtotale
                                    ordine.ordineVuoto.orderTotalPrice -= subtotale

                                }
                                numeroConti -= 1
                            }else{
                                var t = table.tableList.first{ t in
                                    t.tableName == order.orderTable && t.waiterID == order.orderSenderID
                                } ?? TableStruct.empty
                                
                                t.tableStatus = "Libero"
                                t.tableSeatsOccupied = 0
                                t.waiterID = ""
                                
                                if t.id != ""{
                                    table.updateData(table: t)
                                }
                                
                                if ordine.selectedOption == "Tavolo"{
                                    ordine.deleteData(order: ordine.ordineTavolo)
                                    ordine.ordineTavolo = OrderStruct.empty
                                    dismiss()
                                }else{
                                    ordine.deleteData(order: ordine.ordineVuoto)
                                    ordine.ordineVuoto = OrderStruct.empty
                                    dismiss()
                                }
                            }
                        }
                    }
                    payement = []
                    pagatoDef = 0
                    pagamentoTipo = "Contante"
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(.red)
                        Text("Satispay")
                            .foregroundColor(.white)
                            .bold()
                    }
                }
                Button {
                    payement.append(pagamento(pagamentoTipo: 3, pagamentoImporto: subtotale))

                    if order.orderTotalPrice == subtotale {
                        printerManager.sendXMLRequest(receipt: order, subtotale: subtotale, pagamento: payement, user: auth.utente)
                        
                        var t = table.tableList.first{ t in
                            t.tableName == order.orderTable && t.waiterID == order.orderSenderID
                        } ?? TableStruct.empty
                        
                        t.tableStatus = "Libero"
                        t.tableSeatsOccupied = 0
                        t.waiterID = ""
                        
                        if t.id != ""{
                            table.updateData(table: t)
                        }
                        
                        if ordine.selectedOption == "Tavolo"{
                            ordine.orderToModifyOrDelete = ordine.ordineTavolo
                            ordine.saveOrder()

                            ordine.deleteData(order: ordine.ordineTavolo)
                            ordine.ordineTavolo = OrderStruct.empty
                            dismiss()
                        }else{
                            ordine.orderToModifyOrDelete = ordine.ordineVuoto
                            ordine.saveOrder()

                            ordine.deleteData(order: ordine.ordineVuoto)
                            ordine.ordineVuoto = OrderStruct.empty
                            dismiss()
                        }
                    }else {
                        //If user selected only some of the products
                        if !multiSelection.isEmpty{
                            order.orderFood = order.orderFood.filter{ Array(multiSelection).contains($0) }
                            
                            printerManager.sendXMLRequest(receipt: order, subtotale: subtotale, pagamento: payement, user: auth.utente)
                            
                            if ordine.selectedOption == "Tavolo"{
                                order.orderFood = order.orderFood.filter{ !Array(multiSelection).contains($0) }
                                order.orderTotalPrice = ordine.totalAmount(ordine: order)
                                
                                ordine.ordineTavolo = order
                            }else{
                                order.orderFood = order.orderFood.filter{ !Array(multiSelection).contains($0) }
                                order.orderTotalPrice = ordine.totalAmount(ordine: order)
                                
                                ordine.ordineVuoto = order
                            }
                        }else{
                            if numeroConti > 1 {
                                printerManager.sendXMLRequest(receipt: order, subtotale: subtotale, pagamento: payement, user: auth.utente)

                                if ordine.selectedOption == "Tavolo"{
                                    order.orderTotalPrice -= subtotale
                                    ordine.ordineTavolo.orderTotalPrice -= subtotale

                                }else{
                                    order.orderTotalPrice -= subtotale
                                    ordine.ordineVuoto.orderTotalPrice -= subtotale

                                }
                                numeroConti -= 1
                            }else{
                                var t = table.tableList.first{ t in
                                    t.tableName == order.orderTable && t.waiterID == order.orderSenderID
                                } ?? TableStruct.empty
                                
                                t.tableStatus = "Libero"
                                t.tableSeatsOccupied = 0
                                t.waiterID = ""
                                
                                if t.id != ""{
                                    table.updateData(table: t)
                                }
                                
                                if ordine.selectedOption == "Tavolo"{
                                    ordine.deleteData(order: ordine.ordineTavolo)
                                    ordine.ordineTavolo = OrderStruct.empty
                                    dismiss()
                                }else{
                                    ordine.deleteData(order: ordine.ordineVuoto)
                                    ordine.ordineVuoto = OrderStruct.empty
                                    dismiss()
                                }
                            }
                        }
                    }
                    payement = []
                    pagatoDef = 0
                    pagamentoTipo = "Contante"
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(.purple)
                        Text("Ticket")
                            .foregroundColor(.white)
                            .bold()
                    }
                }
            }
            .padding(.top)
            .frame(height: 150)
            /*HStack{
                Text("Seleziona tipo di Pagamento")
                Spacer()
                Picker("Scegli tipo di pagamento", selection: $pagamentoTipo) {
                    Text("Contante").tag("Contante")
                    Text("Pagamento Elettronico").tag("Pagamento Elettronico")
                    Text("Ticket").tag("Ticket")
                }.onChange(of: pagamentoTipo) { newValue in
                    if newValue == "Contante" {
                        elettronico = 0
                        contanti = subtotale
                        ticket = 0

                    }else if newValue == "Pagamento Elettronico" {
                        elettronico = subtotale
                        ticket = 0
                        contanti = 0

                    }else{
                        elettronico = 0
                        ticket = subtotale
                        contanti = 0
                    }
                }
            }*/
            Text("Con Satispay, Bancomat, etc. si intendono tutti i Pagamenti Elettronici con POS")
                .hAllign(.leading)
                .foregroundColor(.secondary)
                .font(.caption2)
                .padding(.bottom)
            Spacer()
            /*VStack(alignment: .leading){
                Button("Vuoi inserire Importo Manualmente?") {
                    tastierinoSelection.toggle()
                }
                Text("Di Default il Pagamento che andrai ad aggiungere coprirà l'intero importo da pagare, clicca qui per inserire manualmente l'importo")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom)
            .hAllign(.leading)
            
            HStack{
                Text("Importo Pagato in \(pagamentoTipo)")
                    .font(.footnote)
                Spacer()
                if pagamentoTipo == "Contante"{
                    Text("\(contanti , format: .currency(code: "EUR"))")
                }else if pagamentoTipo == "Pagamento Elettronico" {
                    Text("\(elettronico , format: .currency(code: "EUR"))")
                }else{
                    Text("\(ticket , format: .currency(code: "EUR"))")
                }
            }
            .padding(.bottom)
            .popover(isPresented: $tastierinoSelection) {
                HStack{
                    VStack{
                        if pagamentoTipo == "Ticket"{
                            Stepper("Numbero di Ticket : \(numberTicket, format: .number)", value: $numberTicket)
                                .padding()
                        }
                        HStack(alignment: .center){
                            Text("IMPORTO")
                                .font(.footnote)
                            Spacer()
                            Text(" \(visibleWorkings)")
                                .lineLimit(1, reservesSpace: true)
                                .bold()
                        }
                        .padding()
                        ForEach(grid, id: \.self){ row in
                            HStack{
                                ForEach(row, id: \.self){ cell in
                                    Button(action: { buttonPressed(cell: cell)}, label: {
                                        Text(cell)
                                            .foregroundColor(.primary)
                                            .bold()
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    })
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .foregroundColor(buttonColor(cell))
                                    )
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(width: 350, height: 350)
                    .hAllign(.leading)
                    .padding()
                    .alert(isPresented: $showAlert){
                        Alert(
                            title: Text("Input non Valido"),
                            message: Text(visibleWorkings),
                            dismissButton: .default(Text("Okay"))
                        )
                    }
                }
            }
            Button {
                if pagamentoTipo == "Contante"{
                    payement.append(pagamento(pagamentoTipo: 0, pagamentoImporto: contanti))
                }else if pagamentoTipo == "Pagamento Elettronico" {
                    payement.append(pagamento(pagamentoTipo: 2, pagamentoImporto: elettronico))
                }else{
                    payement.append(pagamento(pagamentoTipo: 3, pagamentoImporto: ticket))
                }
                var sum : Double = 0
                _ = payement.map{ p in
                    sum += p.pagamentoImporto
                    return true
                }
                pagatoDef = sum
                print(pagatoDef-subtotale)
            } label: {
                HStack{
                    Image(systemName: "square.and.arrow.down")
                    Text("Salva Pagamento")
                }.padding(.horizontal)
            }
            .buttonStyle(.bordered)
            
            Spacer()
            
            VStack{
                List(payement){ pay in
                    Section{
                        HStack{
                            if pay.pagamentoTipo == 0 {
                                Text("Contante")
                            }else if pay.pagamentoTipo == 1 {
                                //Assegno
                                Text("Assegno")
                            }else if pay.pagamentoTipo == 2 {
                                Text("Pagamento Elettronico")
                            }else if pay.pagamentoTipo == 3 {
                                Text("Ticket")
                            }
                            Spacer()
                            Text("\(pay.pagamentoImporto, format: .currency(code: "EUR"))")
                            Button {
                                payement.removeAll { p in
                                    pay.id == p.id
                                }
                                var sum : Double = 0
                                _ = payement.map{ p in
                                    sum += p.pagamentoImporto
                                    return true
                                }
                                pagatoDef = sum
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .padding()
            .frame(height: 150)
            

            if (subtotale - pagatoDef) > Double(0) {
                Button {
                } label: {
                    ZStack {
                        Rectangle()
                            .cornerRadius(15)
                        HStack{
                            Text("Aggiungi altri Pagamenti per \((subtotale-pagatoDef), format: .currency(code: "EUR"))")
                        }
                        .foregroundColor(.white)
                        .font(.headline)
                    }
                }
                .disabled(true)
                .frame(height: 70)
                .padding(.horizontal,60)
                .padding(.bottom)
            }else{
                Button {
                    //If payement is for all the order
                    
                } label: {
                    ZStack {
                        Rectangle()
                            .cornerRadius(15)
                        HStack{
                            Image(systemName: "printer.fill")
                            Text("Stampa Scontrino")
                        }
                        .foregroundColor(.white)
                        .font(.headline)
                    }
                }
                .frame(height: 70)
                .padding(.horizontal,60)
                .disabled(payement.isEmpty)
            }*/
        }
        .padding()
             
        .onAppear{
            payement = []
            contanti = subtotale
            elettronico = 0
            ticket = 0
            
            pagatoDef = contanti + elettronico + ticket
        }
    }
    func buttonColor(_ cell: String) -> Color{
        if(cell == "AC" || cell == "="){
            return .accentColor.opacity(0.5)
        }
        if(cell == "-" || cell == "x" || cell == "⌦" || operators.contains(cell)){
            return .accentColor.opacity(0.2)
        }
        return .clear
    }
        
    func buttonPressed(cell: String){
        switch (cell){
        case "AC":
            visibleWorkings = ""
            visibleResults = 0
        case "⌦":
            visibleWorkings = String(visibleWorkings.dropLast())
        case "=":
            visibleResults = calculateResults()
            if contanti != 0{
                contanti = visibleResults
                pagatoDef = contanti + elettronico + ticket
                visibleWorkings = ""

            }else if elettronico != 0 {
                elettronico = visibleResults
                pagatoDef = contanti + elettronico + ticket
                visibleWorkings = ""

            }else{
                ticket = visibleResults * Double(numberTicket)
                pagatoDef = contanti + elettronico + ticket
                visibleWorkings = ""
            }
        case "-":
            addMinus()
        case "X", "+":
            addOperator(cell)
        default:
            visibleWorkings += cell
        }
    }
        
    func addOperator(_ cell : String){
        if !visibleWorkings.isEmpty{
            let last = String(visibleWorkings.last!)
            if operators.contains(last){
                visibleWorkings.removeLast()
            }
            visibleWorkings += cell
        }
    }
        
    func addMinus(){
        if visibleWorkings.isEmpty || visibleWorkings.last! != "-"{
            visibleWorkings += "-"
        }
    }
        
    func calculateResults() -> Double{
        if(validInput()){
            var workings = visibleWorkings.replacingOccurrences(of: "%", with: "*0.01")
            workings = workings.replacingOccurrences(of: "X", with: "*")
            let expression = NSExpression(format: workings)
            let result = expression.expressionValue(with: nil, context: nil) as! Double
            return result
        }
        showAlert = true
        return 0
    }
    func validInput() -> Bool{
        if(visibleWorkings.isEmpty){
            return false
        }
        let last = String(visibleWorkings.last!)
        
        if(operators.contains(last) || last == "-"){
            if(last != "%" || visibleWorkings.count == 1){
                return false
            }
        }
        return true
    }
    func formatResult(val : Double) -> String{
        if(val.truncatingRemainder(dividingBy: 1) == 0){
            return String(format: "%.0f", val)
        }
        return String(format: "%.2f", val)
    }
}
struct CheckOut_Previews: PreviewProvider {
    static var previews: some View {
        CheckOut(order: OrderViewModel().ordineTavolo)
            .environmentObject(PrinterViewModel())
            .environmentObject(TableViewModel())
            .environmentObject(AuthenticationViewModel())
            .environmentObject(OrderViewModel())
    }
}
