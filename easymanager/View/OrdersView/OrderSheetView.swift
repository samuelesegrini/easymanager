//
//  OrderSheetView.swift
//  easymanager
//
//  Created by Samuele Segrini on 03/04/23.
//

import SwiftUI

struct OrderSheetView: View {
    @EnvironmentObject var auth: AuthenticationViewModel
    @EnvironmentObject var table: TableViewModel
    @EnvironmentObject var product: ProductViewModel
    @EnvironmentObject var order: OrderViewModel
    
    @Environment(\.dismiss) var dismiss
    @State var tableId : String
    @State private var showingProduct : ProductsStruct? = nil

    var body: some View {
        NavigationStack {
            ForEach(table.tableList.filter{ $0.id ==  tableId}){ table in
                VStack{
                    ProductsComponent(showingProduct: $showingProduct, preferiti: false)
                        .sheet(item: $showingProduct) { prodotto in
                            NavigationStack{
                                sheetOrdine(id: prodotto.id ?? "").onAppear{ product.copiaProdotto = prodotto}
                            }
                        }
                    
                    orderModify()
                    let totalFoodPrice = order.totalAmount(ordine: order.ordineVuoto)
                    VStack {
                        Button {
                            if order.orderList.filter({ order in
                                order.orderTable == table.tableName
                            }).isEmpty {
                                order.ordineVuoto.orderTotalPrice = totalFoodPrice
                                
                                order.ordineVuoto.orderTable = table.tableName
                                order.ordineVuoto.orderTime = Date()
                                order.orderToModifyOrDelete = order.ordineVuoto
                                
                                order.addData()
                                order.ordineVuoto = OrderStruct.empty
                                dismiss()
                            }else {
                                let idOrdine = order.orderList.first(where: { order in
                                    order.orderTable == table.tableName})?.id
                                order.addFood(id: idOrdine ?? "", food: order.ordineVuoto.orderFood)
                                order.ordineVuoto = OrderStruct.empty
                                dismiss()
                            }
                        } label: {
                            ZStack {
                                Rectangle()
                                    .cornerRadius(15)
                                Text("Completa Ordine \(totalFoodPrice, format: .currency(code: "EUR"))")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                        }
                        .disabled(totalFoodPrice.isZero)
                        .frame(height: 60)
                        .padding()
                    }
                }
            }
        }
        .navigationTitle(product.menuChoice)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarTitleMenu() {
                Button {
                    product.menuChoice = "Listino pranzo"
                } label: {
                    Text("Listino pranzo").font(.subheadline)
                }
                Button {
                    product.menuChoice = "Listino cena"
                } label: {
                    Text("Listino cena").font(.subheadline)
                }
                Button {
                    product.menuChoice = "Listino cocktail"
                } label: {
                    Text("Listino cocktail").font(.subheadline)
                }
            }
        }
    }
}


struct OrderSheetView_Previews: PreviewProvider {
    static var previews: some View {
        OrderSheetView(tableId: "")
            .environmentObject(TableViewModel())
            .environmentObject(AuthenticationViewModel())
            .environmentObject(OrderViewModel())
            .environmentObject(ProductViewModel())
    }
}
