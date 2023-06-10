//
//  ContentView.swift
//  easymanager
//
//  Created by Samuele Segrini on 01/04/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth : AuthenticationViewModel
    @EnvironmentObject var dataSource: DataSource
    
    var body: some View {
        ForEach(0..<ThemeManager.themes.count, id: \.self){ theme in
            if ThemeManager.themes[theme].themeName == dataSource.selectedTheme.themeName{
                VStack{
                    switch auth.authenticationState {
                    case .authenticated :
                        WrapperView()
                            .tint(ThemeManager.themes[theme].accentColor)
                    case .unauthenticated :
                        OnBoardingView()
                            .tint(ThemeManager.themes[theme].accentColor)
                    case .payement :
                        Text("test")
                            .tint(ThemeManager.themes[theme].accentColor)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(DataSource())
    }
}
