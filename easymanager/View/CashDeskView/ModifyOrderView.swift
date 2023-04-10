//
//  ProdottiView.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 21/11/22.
//

import SwiftUI

struct ModifyOrderView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var ordine : OrderViewModel
    @EnvironmentObject var prodotto : ProductViewModel
    
    @State private var searchText = ""
    
    @Binding var showingProduct : ProductsStruct?
    @Binding var selectedMain : String
    
    var body: some View {
        ProductsComponent(showingProduct: $showingProduct, preferiti: false)
            .sheet(item: $showingProduct) { product in
                NavigationStack{
                    sheetOrdine(id: product.id ?? "").onAppear{ prodotto.copiaProdotto = product}
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                //TODO: calculator view
                ToolbarItem(placement: .navigationBarLeading) {
                    Button{
                       selectedMain = "Prodotto"
                    }label: {
                        if sizeClass == .compact {
                            Image(systemName: "frying.pan")
                        } else {
                            Text("Prodotto").bold()
                        }
                    }
                    .foregroundColor(.accentColor)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button{
                       selectedMain = "Preferiti"
                    }label: {
                        if sizeClass == .compact {
                            Image(systemName: "star")
                        } else {
                            Text("Preferiti").bold()
                        }
                    }
                    .foregroundColor(.secondary)
                }
            }
    }
}

struct sheetOrdine : View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var dataSource: DataSource
    
    @EnvironmentObject var ordine : OrderViewModel
    @EnvironmentObject var prodotto : ProductViewModel
    
    @State var id : String

    @State private var selection : Bool = false
    @State private var quant : Double = 1
        
    var body: some View {
                    
        VStack {
            HStack{
                VStack (alignment: .leading){
                    ZStack(alignment: .top){
                        Rectangle()
                            .cornerRadius(15)
                        if (prodotto.copiaProdotto.productFavorite == true) {
                            StarComponent()
                                .hAllign(.trailing)
                                .vAllign(.top)
                        }
                    }
                    .frame(height: 200)
                    
                    HStack {
                        Text(prodotto.copiaProdotto.productName.capitalized)
                        Spacer()
                        Text("\(prodotto.copiaProdotto.productPrice, format: .currency(code: "EUR"))").foregroundColor(dataSource.selectedTheme.accentColor)
                    }
                    .font(.headline)
                    .padding(.top)
                    Text(prodotto.copiaProdotto.productCategory).font(.caption).foregroundColor(.secondary)
                    
                    Text("\(prodotto.copiaProdotto.productDescription)").font(.caption)
                        .padding(.vertical)
                    Divider()
                    Stepper("Scegli la quantità : \(quant, specifier: "%.0f")", value: $quant).font(.subheadline)
                    if sizeClass == .compact {
                        List {
                            ForEach($prodotto.copiaProdotto.productVariants, id: \.self){ $variant in
                                Button {
                                    variant.variantChecked.toggle()

                                } label: {
                                    HStack {
                                        Image(systemName: variant.variantChecked == true ? "checkmark.circle.fill" : "circle")
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
                            ForEach($prodotto.copiaProdotto.productVariants, id: \.self){ $variant in
                                Button {
                                    variant.variantChecked.toggle()
                                } label: {
                                    HStack {
                                        Image(systemName: variant.variantChecked == true ? "checkmark.circle.fill" :"circle")
                                        Text(variant.variantName)
                                            .font(.footnote)
                                        Text("\(variant.variantPrice,format: .currency(code: "EUR"))")
                                            .hAllign(.trailing)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                        Spacer()
                    }
                    .frame(width: 250)
                }
            }
            .padding()
        }
        if Double(prodotto.copiaProdotto.productVariants.filter{ $0.variantChecked == true}.count) != quant && prodotto.copiaProdotto.productVariants.filter({ $0.variantChecked == true}).count > 1 {
            
            Text("Attenzione la quantità dei prodotti ed il numero di varianti selezionate non combaciano (Quant. \(quant, format: .number), N.Varianti \(prodotto.copiaProdotto.productVariants.filter{ $0.variantChecked == true}.count, format: .number)). \nInserire le varianti singolarmente")
                .foregroundColor(.red)
                .padding()
        }

        Button {
            //Controllo se esiste già un prodotto con queste caratteristiche, se si ne aumento la quantità
            let doubleProduct = ordine.checkDoubleProducts(prodotto: prodotto.copiaProdotto)

            if ordine.selectedOption == "Tavolo" {
                if doubleProduct {
                    ordine.ordineTavolo.orderFood = ordine.DoubleProducts(prodotto: prodotto.copiaProdotto, quantity: quant)
                } else {
                    ordine.ordineTavolo.orderFood.append(Food(foodVariants: prodotto.copiaProdotto.productVariants, foodName: prodotto.copiaProdotto.productName, foodIva: prodotto.copiaProdotto.productIva, foodPortata: 1, foodReversed: false, foodPrice: prodotto.copiaProdotto.productPrice, foodQuantity: quant))
                }
                
            } else {
                if doubleProduct {
                    ordine.ordineVuoto.orderFood = ordine.DoubleProducts(prodotto: prodotto.copiaProdotto, quantity: quant)
                } else {
                    ordine.ordineVuoto.orderFood.append(Food(foodVariants: prodotto.copiaProdotto.productVariants, foodName: prodotto.copiaProdotto.productName, foodIva: prodotto.copiaProdotto.productIva, foodPortata: 1, foodReversed: false, foodPrice: prodotto.copiaProdotto.productPrice, foodQuantity: quant))
                }
            }
        } label: {
            ZStack {
                Rectangle()
                    .foregroundColor(dataSource.selectedTheme.accentColor)
                    .frame(height: 70)
                HStack {
                    Text("Aggiungi all'ordine \(prodotto.copiaProdotto.productName)").font(.subheadline).foregroundColor(.white).bold()
                }
            }
            .cornerRadius(15)
        }
        .disabled(Double(prodotto.copiaProdotto.productVariants.filter{ $0.variantChecked == true}.count) != quant && prodotto.copiaProdotto.productVariants.filter({ $0.variantChecked == true}).count > 1)
        .padding()
        .navigationTitle(prodotto.copiaProdotto.productName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
