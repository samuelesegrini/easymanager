//
//  ProductsComponent.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 03/03/23.
//

import SwiftUI

struct ProductsComponent: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @Binding var showingProduct : ProductsStruct?
    
    @EnvironmentObject var prodotto : ProductViewModel
    @EnvironmentObject var ordine : OrderViewModel
    @State var preferiti : Bool
    
    @State private var searchText = ""

    private let adaptiveColumns = [
        GridItem(.adaptive(minimum: 133))
    ]
    
    private let adaptiveColumnsCateg = [
        GridItem(.adaptive(minimum: 70))
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            VStack{
                LazyVGrid(columns: adaptiveColumnsCateg) {
                    ForEach(prodotto.categoryList){ categoria in
                        Button {
                            searchText = categoria.categoryName
                        } label: {
                            ZStack{
                                RoundedRectangle(cornerRadius: 5)
                                    .foregroundColor(.accentColor)
                                    .opacity(0.17)
                                Text(categoria.categoryName)
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.borderless)
                        .frame(width: 70, height: 40)
                    }
                }
                .padding(.leading)
                .padding(.top)
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: adaptiveColumns){
                        ForEach(prodotto.filterSearch(searchText: searchText, preferiti: preferiti)) { prodotti in
                            Button {
                                let doubleProduct = ordine.checkDoubleProducts(prodotto: prodotti)
                                
                                if ordine.selectedOption == "Tavolo" {
                                    if doubleProduct {
                                        ordine.ordineTavolo.orderFood = ordine.DoubleProducts(prodotto: prodotti, quantity: 1)
                                    } else {
                                        ordine.ordineTavolo.orderFood.append(Food(foodVariants: prodotti.productVariants, foodName: prodotti.productName, foodIva: prodotti.productIva, foodPortata: 1, foodReversed: false, foodPrice: prodotti.productPrice, foodQuantity: 1))
                                    }
                                } else {
                                    if doubleProduct {
                                        ordine.ordineVuoto.orderFood = ordine.DoubleProducts(prodotto: prodotti, quantity: 1)
                                    } else {
                                        ordine.ordineVuoto.orderFood.append(Food(foodVariants: prodotti.productVariants, foodName: prodotti.productName, foodIva: prodotti.productIva, foodPortata: 1, foodReversed: false, foodPrice: prodotti.productPrice, foodQuantity: 1))
                                    }
                                }
                            } label: {
                                if sizeClass != .compact{
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.secondary, lineWidth: 2)
                                            .foregroundColor(.white)
                                        
                                        VStack(alignment: .leading) {
                                            /*ZStack{
                                                RoundedRectangle(cornerRadius: 15)
                                                    .frame(width: 120, height: 80)
                                                if prodotti.productFavorite {
                                                    StarComponent()
                                                        .vAllign(.top)
                                                        .hAllign(.trailing)
                                                }
                                            }*/
                                            Text(prodotti.productName.firstCapitalized).font(.title3).foregroundColor(.primary).lineLimit(3, reservesSpace: true)
                                                .multilineTextAlignment(.leading).bold()
                                            
                                            HStack(alignment: .bottom) {
                                                Text(prodotti.productCategory.firstCapitalized).font(.caption2).foregroundColor(.secondary)
                                                Spacer()
                                                Text("\(prodotti.productPrice, format: .currency(code: "EUR"))").bold().font(.subheadline)
                                            }
                                            Button {
                                                showingProduct = prodotti
                                            } label: {
                                                ZStack{
                                                    Rectangle()
                                                        .cornerRadius(15)
                                                        .opacity(0.15)
                                                    Text("Vedi varianti").font(.subheadline)
                                                }
                                                .foregroundColor(.accentColor)
                                            }
                                            .hAllign(.center)
                                        }
                                        .padding(10)
                                    }
                                    .cornerRadius(15)
                                    .frame(width: 133, height: 160)
                                } else {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.secondary, lineWidth: 2)
                                            .foregroundColor(.white)
                                        
                                        HStack{
                                            VStack(alignment: .leading) {
                                                HStack{
                                                    Text(prodotti.productName.firstCapitalized).font(.subheadline).foregroundColor(.primary).lineLimit(2, reservesSpace: false)
                                                        .multilineTextAlignment(.leading).bold()
                                                    Spacer()
                                                    if prodotti.productFavorite {
                                                        StarComponent()
                                                            .scaleEffect(0.6)
                                                    }
                                                }
                                                
                                                HStack(alignment: .bottom) {
                                                    Text(prodotti.productCategory.firstCapitalized).font(.caption2).foregroundColor(.secondary)
                                                    Spacer()
                                                    Text("\(prodotti.productPrice, format: .currency(code: "EUR"))").bold().font(.subheadline)
                                                }
                                                
                                                Button {
                                                    showingProduct = prodotti
                                                } label: {
                                                    ZStack{
                                                        Rectangle()
                                                            .cornerRadius(15)
                                                            .opacity(0.15)
                                                        Text("Vedi varianti").font(.subheadline)
                                                    }
                                                    .foregroundColor(.accentColor)
                                                }
                                            }
                                        }
                                        .padding(10)
                                        .hAllign(.leading)
                                    }
                                    .cornerRadius(15)
                                    .frame(width: 130, height: 110)
                                }
                            }
                        }
                    }
                    .padding(.leading)
                    .animation(.default, value: searchText)
                }
                .searchable(text: $searchText, placement: .automatic, prompt: "Cerca prodotti"){
                    ForEach(prodotto.categoryList){ category in
                        Text(category.categoryName).searchCompletion(category.categoryName)
                    }
                }
            }
        }
    }
}
