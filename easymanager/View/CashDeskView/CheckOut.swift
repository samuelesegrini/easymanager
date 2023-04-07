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
    @EnvironmentObject var auth : AuthenticationViewModel
        
    @State private var numeroConti = 1.0
    @State private var subtotale : Double = 0
    @State private var importoPagato : Double = 0
    
    @State private var payement : [pagamento] = []
    @State private var pagatoDef : Double = 0
    
    @State private var showTicket = false
    @State private var numberTicket : Double = 1
    @State private var valueTicket : Double = 1
    
    @State private var multiSelection = Set<Food>()
    @State var order : OrderStruct
    
    @State private var contanti : Double = 0
    @State private var carta : Double = 0
    @State private var ticket : Double = 0
    @State private var satispay : Double = 0

    let grid = [
            ["7", "8", "9", "X"],
            ["4", "5", "6", "+"],
            ["1", "2", "3", "AC"],
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
                .onAppear{
                    subtotale = order.orderTotalPrice
                }
                
                displayFoodBuilder(order: order)
                
                if printerManager.receiptType != .preconto {
                    if printerManager.receiptType == .scontrinoFiscale {
                        Button {
                            self.isEditing.toggle()
                        } label: {
                            Text(self.isEditing ? "Annulla" : "Seleziona singoli alimenti")
                        }
                        .padding(.horizontal, 30)
                        
                        
                        Stepper("Dividi il conto alla romana tra \(numeroConti, format: .number)", value: $numeroConti, in: 1...50)
                            .padding(.bottom)
                            .onChange(of: numeroConti) { newValue in
                                if multiSelection.isEmpty {
                                    subtotale = order.orderTotalPrice / newValue
                                }else {
                                    subtotale = ordine.totalAmount(ordine: OrderStruct(userRestaurantID: "", orderFood: Array(multiSelection), orderTime: order.orderTime, orderTotalPrice: order.orderTotalPrice, orderTable: order.orderTable, orderSenderID: order.orderSenderID)) / newValue
                                }
                            }
                            .padding(.horizontal,30)
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
                    /// - Gestire errore di connessione alla stampante
                    
                    Button {
                        ordine.ordineVuoto = OrderStruct.empty
                        /// - Stampa Preconto con la stampante
                        /// - azzerare ordinetavolo ?????????
                        /// - salvare l'ordine in un database a parte
                        
                        printerManager.sendXMLRequest(receipt: order, subtotale: subtotale, pagamento: [], user: auth.utente)
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
                                if (variant.variantChecked ?? false){
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
                Text("\(ordine.totalFood(food: food),format: .currency(code: "EUR"))").strikethrough(food.foodReversed).font(.headline).foregroundColor(.accentColor)
            }
            .frame(height: 55)
        }
        .onChange(of: multiSelection){ newValue in
            if !newValue.isEmpty {
                subtotale = ordine.totalAmount(ordine: OrderStruct(userRestaurantID: "", orderFood: Array(
                    newValue.map{ food in
                    Food(foodVariants: food.foodVariants, foodName: food.foodName, foodIva: food.foodIva, foodPortata: food.foodPortata, foodReversed: food.foodReversed, foodPrice: ordine.totalFood(food: food), foodQuantity: food.foodQuantity)}),
                    orderTime: order.orderTime, orderTotalPrice: order.orderTotalPrice, orderTable: order.orderTable, orderSenderID: order.orderSenderID))
            }
        }
        .onAppear{
            numeroConti = 1
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
                        .font(.title)
                        .foregroundColor(.secondary)
                    Text("\(subtotale, format: .currency(code: "EUR"))")
                        .font(.largeTitle).bold()
                }
                .padding()
                Divider()
                    .frame(height: 130)
                VStack{
                    Text("Da Pagare")
                        .font(.title)
                        .foregroundColor(.secondary)
                    let diff = subtotale - pagatoDef
                    if diff > 0 {
                        Text("\(diff, format: .currency(code: "EUR"))")
                            .font(.largeTitle).bold()
                    }else{
                        Text("\(0, format: .currency(code: "EUR"))")
                            .font(.largeTitle).bold()
                    }
                }
                .padding()
                Divider()
                    .frame(height: 130)
                VStack{
                    Text("Resto")
                        .font(.title)
                        .foregroundColor(.secondary)
                    let resto = -(subtotale - pagatoDef)
                    if resto > 0 {
                        Text("\(resto, format: .currency(code: "EUR"))")
                            .font(.largeTitle).bold()
                    }else{
                        Text("\(0, format: .currency(code: "EUR"))")
                            .font(.largeTitle).bold()
                    }
                }
                .padding()
            }
            
            HStack{
                VStack{
                    Button {
                        carta = 0
                        contanti = subtotale
                        ticket = 0
                        satispay = 0
                        
                    } label: {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.green)
                                .cornerRadius(15)
                            VStack{
                                if contanti == 0 {
                                    Image(systemName: "banknote.fill")
                                        .font(.system(size: 30))
                                }else {
                                    Text("\(contanti, format: .currency(code: "EUR"))")
                                        .font(.title)
                                    Text("Contanti")
                                        .font(.subheadline)
                                }
                            }.foregroundColor(.white)
                        }
                    }
                    Button {
                        payement.append(pagamento(pagamentoTipo: 0, pagamentoImporto: contanti))
                    } label: {
                        Text("Aggiungi Pagamento")
                            .font(.footnote)
                    }
                }
                VStack{
                    Button {
                        carta = subtotale
                        contanti = 0
                        ticket = 0
                        satispay = 0
                        
                        
                    } label: {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.orange)
                                .cornerRadius(15)
                            VStack{
                                if carta == 0 {
                                    Image(systemName: "creditcard.fill")
                                        .font(.system(size: 30))
                                }else {
                                    Text("\(carta, format: .currency(code: "EUR"))")
                                        .font(.title)
                                }
                                Text("Carta")
                                    .font(.subheadline)
                            }.foregroundColor(.white)
                        }
                    }
                    Button {
                        payement.append(pagamento(pagamentoTipo: 2, pagamentoImporto: carta))
                    } label: {
                        Text("Aggiungi Pagamento")
                            .font(.footnote)

                    }
                }
                VStack{
                    Button {
                        carta = 0
                        contanti = 0
                        ticket = 0
                        satispay = subtotale
                        
                        
                    } label: {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.red)
                                .cornerRadius(15)
                            VStack{
                                if satispay == 0 {
                                    Image("2")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                }else {
                                    Text("\(satispay, format: .currency(code: "EUR"))")
                                        .font(.title)
                                }
                                Text("Satispay")
                                    .font(.subheadline)
                            }.foregroundColor(.white)
                        }
                    }
                    Button {
                        payement.append(pagamento(pagamentoTipo: 2, pagamentoImporto: satispay))
                    } label: {
                        Text("Aggiungi Pagamento")
                            .font(.footnote)
                    }
                }
                VStack{
                    Button {
                        carta = 0
                        contanti = 0
                        ticket = subtotale
                        satispay = 0
                        
                    } label: {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.blue)
                                .cornerRadius(15)
                            VStack{
                                if ticket == 0 {
                                    Image(systemName: "ticket.fill")
                                        .font(.system(size: 30))
                                }else {
                                    Text("\(ticket, format: .currency(code: "EUR"))")
                                        .font(.title)
                                }
                                Text("Ticket")
                                    .font(.subheadline)
                            }.foregroundColor(.white)
                            
                        }
                    }
                    Button {
                        payement.append(pagamento(pagamentoTipo: 3, pagamentoImporto: ticket))
                    } label: {
                        Text("Aggiungi Pagamento")
                            .font(.footnote)
                    }
                }
            }
            .frame(height: 100)
            .padding(.horizontal)
            .padding(.top)
            
            HStack{
                VStack{
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
                }
                .frame(maxWidth: 400, maxHeight: .infinity)
                .hAllign(.leading)
                .padding()
                .alert(isPresented: $showAlert){
                    Alert(
                        title: Text("Input non Valido"),
                        message: Text(visibleWorkings),
                        dismissButton: .default(Text("Okay"))
                    )
                }
                VStack{
                    HStack{
                        Text("IMPORTO")
                            .font(.headline)
                        Spacer()
                        Text("\(visibleWorkings)")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(.accentColor.opacity(0.2)))
                    
                    if ticket != 0 {
                        Stepper("Numbero di Ticket : \(numberTicket, format: .number)", value: $numberTicket)
                    }
                    List(payement){ pay in
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
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                .padding()
            }
            Spacer()
            Button {
                printerManager.sendXMLRequest(receipt: order, subtotale: subtotale, pagamento: payement, user: auth.utente)
                
                if order.orderTotalPrice == subtotale{
                    ordine.deleteData(order: order)
                    dismiss()
                }else {
                    if !multiSelection.isEmpty{
                        order.orderFood = order.orderFood.filter{ !Array(multiSelection).contains($0) }
                        order.orderTotalPrice = ordine.totalAmount(ordine: order)
                    }else{
                        ordine.deleteData(order: order)
                        dismiss()
                    }
                    if numeroConti > 1 {
                        numeroConti -= 1
                        order.orderTotalPrice -= subtotale
                    }else{
                        ordine.deleteData(order: order)
                        dismiss()
                    }
                }
            } label: {
                ZStack {
                    Rectangle()
                        .cornerRadius(15)
                    Text("Stampa Scontrino")
                        .foregroundColor(.white)
                        .font(.title3).bold()
                }
            }
            .disabled(payement.isEmpty)
            .frame(height: 70)
            .padding(.horizontal, 30)
            .padding(.bottom)
        }
        .onAppear{
            contanti = subtotale
            carta = 0
            ticket = 0
            satispay = 0
            
            pagatoDef = contanti + carta + satispay + ticket
        }
    }
    func buttonColor(_ cell: String) -> Color{
        if(cell == "AC" || cell == "⌦"){
            return .accentColor
        }
        if(cell == "-" || cell == "=" || operators.contains(cell)){
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
                pagatoDef = contanti + carta + satispay + ticket
                visibleWorkings = ""

            }else if carta != 0 {
                carta = visibleResults
                pagatoDef = contanti + carta + satispay + ticket
                visibleWorkings = ""

            }else if satispay != 0{
                satispay = visibleResults
                pagatoDef = contanti + carta + satispay + ticket
                visibleWorkings = ""

            }else{
                ticket = visibleResults * Double(numberTicket)
                pagatoDef = contanti + carta + satispay + ticket
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
