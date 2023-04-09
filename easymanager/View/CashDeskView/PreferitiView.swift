//
//  PreferitiView.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 03/03/23.
//

import SwiftUI

struct PreferitiView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    @EnvironmentObject var preferiti : ProductViewModel
    @EnvironmentObject var ordine : OrderViewModel
    @EnvironmentObject var prodotto : ProductViewModel
    
    @State private var showingProduct : ProductsStruct? = nil
    @State private var searchText = ""
    @Binding var selectedMain : String
    
    var body: some View {
        ProductsComponent(showingProduct: $showingProduct, preferiti: true)
            .sheet(item: $showingProduct) { product in
                NavigationStack{
                    sheetOrdine(id : product.id ?? "").onAppear{ preferiti.copiaProdotto = product }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button{
                       selectedMain = "Prodotti"
                    }label: {
                        if sizeClass == .compact {
                            Image(systemName: "frying.pan")
                        } else {
                            Text("Prodotto").bold()
                        }
                    }
                    .foregroundColor(.secondary)
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
                    .foregroundColor(.accentColor)
                }
            }

    }
}
