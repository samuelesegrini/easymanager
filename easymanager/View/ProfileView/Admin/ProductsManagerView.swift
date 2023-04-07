//
//  ProductsManagerView.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 30/03/23.
//

import SwiftUI

struct ProductsManagerView: View {
    @EnvironmentObject var product : ProductViewModel
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dismiss) var dismiss
    
    @State private var editSaveSheet : ProductsStruct?
    @State private var prod = ProductsStruct.empty
    
    @State private var addVariants = false
    @State private var newVariantName = ""
    @State private var ruolo = ""
    @State private var newIva = ""
    @State private var newVariantPrice = 0.00
    @State private var newVariantDescription = ""
    
    var body: some View {
        VStack{
            NavigationStack {
                if sizeClass != .compact{
                    Table(product.productList){
                        TableColumn("Nome", value: \.productName)
                        TableColumn("Menu", value: \.productMenu)
                        TableColumn("Categoria", value: \.productCategory)
                        
                        TableColumn("Prezzo") { item in
                            Text("\(item.productPrice, format: .currency(code: "EUR"))")
                        }
                        TableColumn("Modifica") { item in
                            Button {
                                ruolo = "edit"
                                editSaveSheet = item
                                prod = item
                            } label: {
                                Image(systemName: "square.and.pencil")
                            }
                        }
                        TableColumn("Fav") { item in
                            if item.productFavorite {
                                StarComponent()
                            }
                        }
                    }
                }else {
                    List{
                        Section{
                            ForEach(product.productList){ product in
                                Button {
                                    ruolo = "edit"
                                    editSaveSheet = product
                                    prod = product
                                } label: {
                                    HStack{
                                        Text(product.productName)
                                        Spacer()
                                        Image(systemName: "square.and.pencil")
                                    }
                                }
                            }
                        }
                        Section{
                            NavigationLink("Gestisci le Categorie") {
                                CategoryManagerView()
                            }
                            .foregroundColor(.accentColor)
                        }
                    }
                }
                
            }
        }
        .sheet(item: $editSaveSheet, content: { product in
            NavigationStack{
                editSaveProduct()
            }
        })
        .navigationTitle("Gestione Prodotti")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    ruolo = "save"
                    editSaveSheet = prod
                } label: {
                    Image(systemName: "plus")
                }

            }
        }
    }
    @ViewBuilder
    func editSaveProduct() -> some View {
        VStack {
            Form {
                Section{
                    HStack{
                        Text("Nome").bold()
                        TextField("Obbligatorio", text: $prod.productName)
                            .padding(.horizontal, 45)
                    }
                    Picker("Scegli Categoria", selection: $prod.productCategory) {
                        ForEach(product.categoryList){ category in
                            Text(category.categoryName).tag(category.categoryName)
                        }
                    }
                    HStack {
                        Text("Prezzo").bold()
                        TextField("Obbligatorio", value: $prod.productPrice, format: .currency(code: "EUR"))
                        
                            .keyboardType(.decimalPad)
                            .padding(.horizontal, 50)
                    }
                    Picker("IVA", selection: $prod.productIva) {
                        Text("22 %").tag("22")
                        Text("10 %").tag("10")
                        Text("4 %").tag("4")
                    }
                    HStack {
                        Text("Note").bold()
                        TextField("Facoltative", text: $prod.productDescription, axis: .vertical)
                            .lineLimit(3, reservesSpace: true)
                            .padding(.horizontal, 50)
                    }
                }header: {
                    Text("Informazioni Prodotto")
                }
                Section{
                    Picker("Scegli il listino", selection: $prod.productMenu) {
                        Text("Listino Pranzo").tag(0)
                        Text("Listino Cena").tag(1)
                        Text("Listino Aperitivo").tag(2)
                        Text("Listino Colazione").tag(3)
                    }
                    Toggle("Vuoi che sia uno dei prodotti preferiti?", isOn: $prod.productFavorite)
                }
                
                Section {
                    Button {
                        addVariants.toggle()
                    } label: {
                        HStack{
                            Image(systemName: "plus")
                            Text("Aggiungi Variante")
                        }
                    }
                }
                Section{
                    ForEach(prod.productVariants, id:\.self){ variant in
                        HStack{
                            Text(variant.variantName)
                                .lineLimit(3)
                            Spacer()
                            Text("\(variant.variantPrice, format: .currency(code: "EUR"))")
                            Spacer()
                            Text(variant.variantDescription)
                                .lineLimit(3, reservesSpace: true)
                        }
                    }
                }
            }
            .sheet(isPresented: $addVariants){
                NavigationStack{
                    HStack{
                        Text("Nome").bold()
                        TextField("Obbligatorio", text: $newVariantName)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                    HStack {
                        Text("Prezzo").bold()
                        TextField("Obbligatorio", value: $newVariantPrice, format: .currency(code: "EUR"))
                            .keyboardType(.decimalPad)
                            .padding(.horizontal, 50)
                    }
                    .padding(.vertical)
                    HStack {
                        Text("Note").bold()
                        TextField("Facoltative", text: $newVariantDescription, axis: .vertical)
                            .lineLimit(3, reservesSpace: true)
                            .padding(.horizontal, 50)
                    }
                    .padding(.vertical)
                    Spacer()
                    Button {
                        prod.productVariants.append(Variants(variantName: newVariantName, variantPrice: newVariantPrice, variantDescription: newVariantDescription))
                        addVariants = false
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .frame(height: 60)
                            HStack{
                                Image(systemName: "checkmark.seal.fill")
                                Text("Salva Variante").bold()
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .padding(.horizontal)
                }
                .padding(30)
                .navigationTitle("Aggiungi Variante")
            }
            .formStyle(.grouped)
            .navigationTitle("Prodotto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(id:"Annulla",placement: .navigationBarLeading){
                    Button("Annulla") {
                        dismiss()
                    }
                }
            }
            Spacer()
            Button {
                product.productToModifyOrDelete = prod
                if ruolo == "edit"{
                    product.updateData()
                }else if ruolo == "save"{
                    product.addData()
                }
                dismiss()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(height: 60)
                    HStack{
                        Image(systemName: "checkmark.seal.fill")
                        Text("Salva Modifica").bold()
                    }
                    .foregroundColor(.white)
                }
            }
            .padding()
            .padding(.horizontal)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear{
            if ruolo == "save"{
                prod = ProductsStruct.empty
            }
        }
    }
}

struct ProductsManagerView_Previews: PreviewProvider {
    static var previews: some View {
        ProductsManagerView()
            .environmentObject(ProductViewModel())
    }
}
