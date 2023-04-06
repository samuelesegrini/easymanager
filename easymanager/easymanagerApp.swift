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
    @StateObject var order = OrderViewModel()
    @StateObject var product = ProductViewModel()
    @StateObject var printer = PrinterViewModel()
    @StateObject var table = TableViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(DataSource())
                .environmentObject(csManager)
                .onAppear{
                    csManager.applyColorScheme()
                }
                .environmentObject(auth)
                .environmentObject(table)
                .environmentObject(restaurant)
                .environmentObject(printer)
                .environmentObject(order)
                .environmentObject(product)
        }
    }
}
