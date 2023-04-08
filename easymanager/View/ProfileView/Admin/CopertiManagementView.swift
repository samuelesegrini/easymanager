//
//  CopertiManagementView.swift
//  easymanager
//
//  Created by Samuele Segrini on 08/04/23.
//

import SwiftUI

struct CopertiManagementView: View {
    @EnvironmentObject var table : TableViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showSaveCoperto = false
    @State private var savecoperto = false
    
    var body: some View {
        VStack{
            List(table.copertoList){ coperto in
                HStack{
                    Text(coperto.nomeCoperto)
                    Spacer()
                    Text("\(coperto.prezzoCoperto, format: .currency(code: "EUR"))")
                }
            }
        }
        .navigationTitle("Gestisci Coperti")
        .sheet(isPresented: $showSaveCoperto){
            NavigationStack{
                AddCoperto()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSaveCoperto.toggle()
                } label: {
                    Image(systemName: "plus")
                }

            }
        }
    }
    @ViewBuilder
    func AddCoperto() -> some View {
        VStack{
            Form{
                Section{
                    HStack{
                        Text("Nome Coperto").bold()
                        TextField("Obbligatorio", text: $table.copertoToModifyOrDelete.nomeCoperto)
                            .padding(.horizontal)
                            .keyboardType(.default)
                    }
                    HStack {
                        Text("Prezzo Coperto").bold()
                        TextField("Obbligatorio", value: $table.copertoToModifyOrDelete.prezzoCoperto, format: .currency(code: "EUR"))
                            .padding(.horizontal)
                            .keyboardType(.decimalPad)
                    }
                }header: {
                    Text("Informazioni Coperto")
                }
                Section{
                    Toggle("Vuoi salvare il Coperto?", isOn: $savecoperto)
                }
            }
            .navigationTitle("Aggiungi Categoria")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSaveCoperto = false
                    } label: {
                        Text("Annulla")
                    }
                }
            }
            Spacer()
            Button {
                table.addCoperto()
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
            .disabled(!savecoperto)
            .padding()
            .padding(.horizontal)
        }
    }
}

struct CopertiManagementView_Previews: PreviewProvider {
    static var previews: some View {
        CopertiManagementView()
            .environmentObject(TableViewModel())
    }
}
