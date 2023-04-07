//
//  CookingView.swift
//  easymanager
//
//  Created by Samuele Segrini on 06/04/23.
//

import SwiftUI

struct CookingView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var order : OrderViewModel
    @EnvironmentObject var auth : AuthenticationViewModel
    
    var body: some View {
        VStack{
            if sizeClass == .compact {
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(order.orderList){ order in
                        SingleOrder(order)
                            .frame(height: 500)
                    }
                }
            }else {
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        ForEach(order.orderList){ order in
                            SingleOrder(order)
                                .frame(minWidth: 400)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(.ultraThinMaterial)
        .navigationTitle("Cucina")
    }
    @ViewBuilder
    func SingleOrder(_ ordine: OrderStruct) -> some View{
        ZStack{
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(Color(UIColor.systemBackground))
            VStack(alignment: .leading){
                Text(ordine.orderTable)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                HStack{
                    Text("Tipi di Prodotti")
                    Spacer()
                    Text("\(ordine.orderFood.count)")
                }
                Spacer()
                ListProdotti(ordine)
            }
            .hAllign(.leading)
            .padding()
        }
        .padding(.horizontal)
        .padding(.top)

    }
    @ViewBuilder
    func ListProdotti(_ ordine : OrderStruct) -> some View {
        List{
            ForEach(ordine.orderFood, id: \.self) { food in
                Button {
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
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .padding(.vertical)
    }
}

struct CookingView_Previews: PreviewProvider {
    static var previews: some View {
        CookingView()
            .environmentObject(OrderViewModel())
            .environmentObject(AuthenticationViewModel())
    }
}
