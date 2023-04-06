//
//  RestaurantView.swift
//  easymanager
//
//  Created by Samuele Segrini on 06/04/23.
//

import SwiftUI

struct RestaurantView: View {
    @EnvironmentObject var restaurant : RestaurantViewModel
    @EnvironmentObject var printerManager : PrinterViewModel
    @EnvironmentObject var auth : AuthenticationViewModel
    var body: some View {
        VStack{
            Text("Benvenuto \(restaurant.restaurantCurrent.restaurantName)")
            HStack{
                Button {
                    printerManager.printXReport(user: auth.utente)
                } label: {
                    Text("Stampa Report finanziazio della Giornata").bold()
                        .padding()
                }
                    .buttonStyle(.borderedProminent)
                Button {
                    printerManager.printXZReport(user: auth.utente)
                } label: {
                    Text("Stampa Report e fai Chiusura").bold()
                        .padding()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(30)
        .navigationTitle("\(restaurant.restaurantCurrent.restaurantName)")
    }
}

struct RestaurantView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantView()
            .environmentObject(RestaurantViewModel())
            .environmentObject(PrinterViewModel())
            .environmentObject(AuthenticationViewModel())
    }
}
