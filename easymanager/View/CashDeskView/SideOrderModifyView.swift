//
//  SideOrderModifyView.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 28/02/23.
//

import SwiftUI

struct orderModify : View {

    @EnvironmentObject var auth: AuthenticationViewModel
    @EnvironmentObject var ordine : OrderViewModel
    @EnvironmentObject var prodotto : ProductViewModel
    
    @State private var showingProductOrder = false
    @State private var modificabile = Food.empty
    
    var body: some View {
        List {
            ForEach(ordine.selectedOption == "Tavolo" ? $ordine.ordineTavolo.orderFood : $ordine.ordineVuoto.orderFood, id:\.self) { $food in
                Button {
                    modificabile = food
                    ordine.prodottoModify = food
                    showingProductOrder.toggle()
                } label: {
                    if auth.visualizzazioneScontrino == "moderno"{
                        let count = food.foodVariants.filter{ $0.variantChecked == true }.count
                        VStack(spacing: 0){
                            HStack {
                                Text("\(food.foodQuantity, specifier: "%.0f")").strikethrough(food.foodReversed).font(.headline).bold()
                                VStack(alignment: .leading){
                                    //trattini
                                }.frame(width: 5)
                                HStack{
                                    Text(food.foodName).strikethrough(food.foodReversed).font(.headline).bold().lineLimit(2, reservesSpace: false)
                                    ZStack{
                                        Circle().frame(width: 15, height: 15)
                                        Text("\(food.foodPortata)")
                                    }
                                    Spacer()
                                }
                                Text("\(food.foodPrice * food.foodQuantity,format: .currency(code: "EUR"))") .strikethrough(food.foodReversed).font(.headline).foregroundColor(.accentColor).bold()
                            }
                            if  count != 0 {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(spacing: 0){
                                        Divider()
                                        VStack(alignment: .leading, spacing: 0){
                                            Divider()
                                        }.frame(width: 20)
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack{
                                                ForEach(food.foodVariants, id: \.self){ variant in
                                                    if variant.variantChecked ?? false {
                                                        HStack{
                                                            Image(systemName: "doc.plaintext")
                                                            Text(variant.variantName)
                                                                .padding(.trailing)
                                                            Text("\(variant.variantPrice, format: .currency(code: "EUR")) x\(food.foodQuantity, format: .number)")
                                                        }.font(.subheadline).foregroundColor(.secondary)
                                                    }else {
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.leading, 5)
                                    }
                                }.padding(.leading, 5)
                            }
                        }
                    }else {
                        HStack(alignment: .top) {
                            ZStack{
                                Rectangle()
                                    .cornerRadius(10)
                                    .frame(width: 50, height: 50)
                                    .padding(.trailing, 5)
                            }
                            VStack(alignment: .leading) {
                                HStack(alignment: .top){
                                    Text(food.foodName).strikethrough(food.foodReversed).font(.footnote).bold().lineLimit(2, reservesSpace: false)
                                    Text("x\(food.foodQuantity, specifier: "%.0f")").strikethrough(food.foodReversed).font(.caption2).foregroundColor(.gray)
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(food.foodVariants, id: \.self){ variant in
                                            if (variant.variantChecked ?? false){
                                                HStack(spacing: 1){
                                                    Image(systemName: "doc.plaintext")
                                                    Text("\(variant.variantName.capitalized)")
                                                }
                                                .strikethrough(food.foodReversed)
                                                .font(.caption2).foregroundColor(.secondary)
                                                .padding(.horizontal, 4)
                                                
                                            }
                                        }
                                    }
                                }
                            }
                            Spacer()
                            
                            //Dare in output prezzo del cibo (compreso di prezzo varianti)
                            Text("\(food.foodPrice * food.foodQuantity,format: .currency(code: "EUR"))") .strikethrough(food.foodReversed).font(.subheadline).foregroundColor(.accentColor).bold()
                        }
                    }
                }
                .disabled(food.foodReversed)
                .swipeActions {
                    if food.foodReversed {
                        Button("Aggiungi") {
                            withAnimation {
                                food.foodReversed = false
                            }
                        }
                        .tint(.green)
                    } else {
                        Button("Storna") {
                            
                            withAnimation {
                                food.foodReversed = true
                            }
                        }
                        .tint(.red)
                    }
                }
                .listRowSeparator(.hidden)
            }
            .onMove { from, to in
                if ordine.selectedOption == "Tavolo" {
                    ordine.ordineTavolo.orderFood.move(fromOffsets: from, toOffset: to)
                }else{
                    ordine.ordineVuoto.orderFood.move(fromOffsets: from, toOffset: to)
                }
            }
        }
        .sheet(isPresented: $showingProductOrder){
            NavigationStack{
                sheetModify(modificabile: $modificabile, showingProductOrder: $showingProductOrder)
            }
        }
        .listStyle(.plain)
    }
}
struct sheetModify : View {
    @Environment(\.horizontalSizeClass) var sizeClass

    @EnvironmentObject var dataSource: DataSource
    @EnvironmentObject var ordine : OrderViewModel
    
    @Binding var modificabile : Food
    @Binding var showingProductOrder : Bool
    
    @State private var selection : Bool = false
        
    var body: some View {
        VStack {
            HStack{
                VStack (alignment: .leading){
                    ZStack(alignment: .top){
                        Rectangle()
                            .cornerRadius(15)
                    }
                    .frame(height: 200)
                    
                    HStack {
                        Text(ordine.prodottoModify.foodName.capitalized)
                        Spacer()
                        Text("\(ordine.prodottoModify.foodPrice, format: .currency(code: "EUR"))").foregroundColor(dataSource.selectedTheme.accentColor)
                    }
                    .font(.headline)
                    .padding(.top)
                    
                    Divider()
                    
                    Stepper("Scegli la quantità : \(ordine.prodottoModify.foodQuantity, specifier: "%.0f")", value: $ordine.prodottoModify.foodQuantity).font(.subheadline)
                    if sizeClass == .compact {
                        List {
                            ForEach($ordine.prodottoModify.foodVariants, id: \.self){ $variant in
                                Button {
                                    variant.variantChecked?.toggle()
                                } label: {
                                    HStack {
                                        Image(systemName: variant.variantChecked == true ? "checkmark.circle.fill" :"circle")
                                        Text(variant.variantName)
                                            .font(.callout)
                                        Text("\(variant.variantPrice,format: .currency(code: "EUR"))")
                                    }
                                }
                            }
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                    }
                    Spacer()
                }
                if sizeClass != .compact{
                    VStack (alignment: .leading){
                        List {
                            ForEach($ordine.prodottoModify.foodVariants, id: \.self){ $variant in
                                Button {
                                    variant.variantChecked?.toggle()
                                } label: {
                                    HStack {
                                        Image(systemName: variant.variantChecked == true ? "checkmark.circle.fill" :"circle")
                                        Text(variant.variantName)
                                            .font(.callout)
                                        Text("\(variant.variantPrice,format: .currency(code: "EUR"))")
                                    }
                                }
                            }
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                        Spacer()
                    }
                    .frame(maxWidth: 250)
                }
            }
            .padding()
            Button {
                if ordine.selectedOption == "Tavolo" {
                    ordine.ordineTavolo.orderFood = ordine.modifyFood(exValore: modificabile)
                    showingProductOrder.toggle()
                } else {
                    ordine.ordineVuoto.orderFood = ordine.modifyFood(exValore: modificabile)
                    showingProductOrder.toggle()
                }
            } label: {
                ZStack {
                    Rectangle()
                        .foregroundColor(dataSource.selectedTheme.accentColor)
                        .frame(height: 70)
                    HStack {
                        Text("Salva Modifiche al prodotto \(ordine.prodottoModify.foodName)").font(.subheadline).foregroundColor(.white).bold()
                    }
                }
                .cornerRadius(15)
            }
            .padding()
            }
        .navigationTitle(ordine.prodottoModify.foodName)
        .navigationBarTitleDisplayMode(.inline)
        
    }
}
