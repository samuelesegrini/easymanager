//
//  easymanagerApp.swift
//  easymanager
//
//  Created by Samuele Segrini on 01/04/23.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct easymanagerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var csManager = ColorSchemeManager()
    
    @StateObject var restaurant = RestaurantViewModel()
    @StateObject var auth = AuthenticationViewModel()
    @StateObject var table = TableViewModel()
    @StateObject var warehouse = WarehouseViewModel()
    @StateObject var order = OrderViewModel()
    @StateObject var product = ProductViewModel()
    @StateObject var booking = BookingViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
                .environmentObject(table)
                .environmentObject(warehouse)
                .environmentObject(restaurant)
                .environmentObject(order)
                .environmentObject(product)
                .environmentObject(booking)
                .environmentObject(DataSource())
                .environmentObject(csManager)
                .onAppear{
                    csManager.applyColorScheme()
                }
        }
    }
}
