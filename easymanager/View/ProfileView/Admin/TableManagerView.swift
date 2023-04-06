//
//  TableManagerView.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 30/03/23.
//

import SwiftUI

struct TableManagerView: View {
    @EnvironmentObject var table : TableViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var editSaveSheet : TableStruct?
    @State private var tab = TableStruct.empty
    @State private var ruolo = ""
    
    var body: some View {
        VStack{
            NavigationStack {
                Table(table.tableList){
                    TableColumn("Nome", value: \.tableName)
                    
                    TableColumn("Sedute") { item in
                        Text("\(item.tableSeats)")
                    }
                    TableColumn("Modifica") { item in
                        Button {
                            ruolo = "edit"
                            editSaveSheet = item
                            tab = item
                        } label: {
                            Image(systemName: "square.and.pencil")
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
                    editSaveSheet = tab
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
                        TextField("Obbligatorio", text: $tab.tableName)
                            .padding(.horizontal, 45)
                    }
                    HStack {
                        Text("Sedute").bold()
                        TextField("Obbligatorio", value: $tab.tableSeats, format: .number)
                            .keyboardType(.decimalPad)
                            .padding(.horizontal, 50)
                    }
                }header: {
                    Text("Informazioni Tavolo")
                }
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
                if ruolo == "edit"{
                    table.updateData(table: tab)
                }else if ruolo == "save"{
                    table.addData()
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
    }
}

struct TableManagerView_Previews: PreviewProvider {
    static var previews: some View {
        TableManagerView()
            .environmentObject(TableViewModel())
    }
}
