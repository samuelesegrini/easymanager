//
//  CategoryManagerView.swift
//  easymanager
//
//  Created by Samuele Segrini on 04/04/23.
//

import SwiftUI

struct CategoryManagerView: View {
    @EnvironmentObject var product : ProductViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showSaveCategory = false
    @State private var savecategory = false
    
    var body: some View {
        VStack{
            List{
                Text("Ciao")
            }
        }
        .navigationTitle("Gestisci Categorie")
        .sheet(isPresented: $showSaveCategory){
            NavigationStack{
                AddCategory()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSaveCategory.toggle()
                } label: {
                    Image(systemName: "plus")
                }

            }
        }
    }
    @ViewBuilder
    func AddCategory() -> some View {
        VStack{
            Form{
                Section{
                    HStack{
                        Text("Nome Categoria").bold()
                        TextField("Obbligatorio", text: $product.categoryToModifyOrDelete.categoryName)
                            .padding(.horizontal)
                    }
                    HStack {
                        Text("Note").bold()
                        TextField("Facoltative", text: $product.categoryToModifyOrDelete.categoryDescription, axis: .vertical)
                            .lineLimit(3, reservesSpace: true)
                            .padding(.horizontal, 50)
                    }
                }header: {
                    Text("Informazioni Categoria")
                }
                Section{
                    Toggle("Vuoi salvare la Categoria?", isOn: $savecategory)
                }
            }
            .navigationTitle("Aggiungi Variante")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSaveCategory = false
                    } label: {
                        Text("Annulla")
                    }
                }
            }
            Spacer()
            Button {
                product.addCategory()
                dismiss()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(height: 60)
                    HStack{
                        Image(systemName: "checkmark.seal.fill")
                        Text("Salva").bold()
                    }
                    .foregroundColor(.white)
                }
            }
            .padding()
            .padding(.horizontal)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct CategoryManagerView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryManagerView()
            .environmentObject(ProductViewModel())
    }
}
