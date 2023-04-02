//
//  ColorScheme.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import SwiftUI

enum SchemeManager: Int {
    case unspecified, light, dark
}

class ColorSchemeManager: ObservableObject {
    @AppStorage("colorScheme") var colorScheme : SchemeManager = .unspecified {
        didSet {
            applyColorScheme()
        }
    }
    
    func applyColorScheme(){
        keyWindow?.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: colorScheme.rawValue)!
    }
    var keyWindow : UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else {
                return nil
              }
        return window
    }
}
