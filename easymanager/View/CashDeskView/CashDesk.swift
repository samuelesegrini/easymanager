//
//  CashDesk.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import SwiftUI

struct CashDesk: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var auth: AuthenticationViewModel
    
    @EnvironmentObject var ordine : OrderViewModel
    @EnvironmentObject var prodotto : ProductViewModel
        
    @State private var selectedMain = "Prodotti"
    @State private var showingProduct : ProductsStruct? = nil
            
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let screenHeight = geometry.size.height
                HStack(spacing: 0) {
                    switch selectedMain {
                        //TODO: case Calcolatrice
                    case "Prodotti":
                        VStack{
                            ModifyOrderView(showingProduct: $showingProduct, selectedMain: $selectedMain)
                            Divider()
                                .foregroundColor(Color(UIColor.systemBackground))
                            if sizeClass == .compact {
                                CustomBottomComponent()
                            }
                        }
                    case "Preferiti":
                        VStack{
                            PreferitiView(selectedMain : $selectedMain)
                            if sizeClass == .compact {
                                CustomBottomComponent()
                            }
                        }
                    default :
                        VStack{
                            ModifyOrderView(showingProduct: $showingProduct, selectedMain: $selectedMain)
                            if sizeClass == .compact {
                                CustomBottomComponent()
                            }
                        }
                    }
                    
                    if sizeClass != .compact {
                        Spacer()
                        VStack{
                            ScontrinoView()
                        }
                        .frame(width: (screenWidth > 430) ? screenWidth / 3 : 0, height: screenHeight - screenHeight / 60)
                    }
                }
                .background(.ultraThinMaterial)
                .animation(.default, value: selectedMain)
            }
        }
    }
    @ViewBuilder
    func CustomBottomComponent() -> some View{
        ZStack {
            Rectangle()
                .cornerRadius(40)
                .foregroundColor(Color(UIColor.tertiarySystemBackground))

            HStack(spacing: 10){
                ZStack{
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(Color(UIColor.quaternarySystemFill))
                    HStack{
                        Text("Aggiunto :")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text(ordine.ordineVuoto.orderFood.first?.foodName ?? "Nessun Elemento")
                            .lineLimit(2)
                            .font(.footnote)
                            .animation(.default, value: ordine.ordineVuoto.orderFood)

                        Spacer()
                        Text("x\(ordine.ordineVuoto.orderFood.first?.foodQuantity ?? 0, format: .number)")
                            .font(.footnote)
                    }
                    .padding()
                    .hAllign(.leading)
                }
                NavigationLink {
                    ScontrinoView()
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(Color(UIColor.quaternarySystemFill))
                        VStack{
                            Image(systemName: "arrow.right")
                                .font(.system(size: 20))
                                .padding(.vertical, 2)
                            Text("Ricevuta").font(.caption2).foregroundColor(.secondary)
                        }
                        .padding()
                    }
                }
                .frame(width: 80)
            }
            .padding()
            .padding(.horizontal, 5)
        }
        .frame(height: 100)
        .padding(.horizontal)
        .padding(.bottom)
    }
}


struct CashDesk_Previews: PreviewProvider {
    static var previews: some View {
        CashDesk()
            .environmentObject(ProductViewModel())
            .environmentObject(AuthenticationViewModel())
            .environmentObject(OrderViewModel())
    }
}
