//
//  Theme.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import UIKit
import Foundation
import SwiftUI

enum ThemeManager {
    static let themes : [Theme] = [teal(),cyan(),mint(),blue(),darkBlue(),indigo(),violet(),softPurple(),purple(),millenialPink(),darkGreen(),green(),yellow(),orange(),peach(),pink(),red(),gray(),brown()]
    
    static func getTheme(_ theme: Int) -> Theme{
        Self.themes[theme]
    }
}

protocol Theme{
    var accentColor : Color{get}
    var themeName : String{get}
}

struct red : Theme {
    var accentColor: Color = Color.red
    var themeName: String = "red"
}
struct peach : Theme {
    var accentColor: Color = Color(red: 231 / 255, green: 120 / 255, blue: 101 / 255)
    var themeName: String = "peach"
}
struct orange : Theme {
    var accentColor: Color = Color.orange
    var themeName: String = "orange"
}
struct yellow : Theme {
    var accentColor: Color = Color.yellow
    var themeName: String = "yellow"
}
struct green : Theme {
    var accentColor: Color = Color.green
    var themeName: String = "green"
}
struct darkGreen : Theme {
    var accentColor: Color = Color(red: 76 / 255, green: 163 / 255, blue: 128 / 255)
    var themeName: String = "darkGreen"
}
struct mint : Theme {
    var accentColor: Color = Color.mint
    var themeName: String = "mint"
}
struct teal : Theme {
    var accentColor: Color = Color.teal
    var themeName: String = "teal"
}
struct cyan : Theme {
    var accentColor: Color = Color.cyan
    var themeName: String = "cyan"
}
struct blue : Theme {
    var accentColor: Color = Color.blue
    var themeName: String = "blue"
}
struct darkBlue : Theme {
    var accentColor: Color = Color(red: 37 / 255, green: 81 / 255, blue: 178 / 255)
    var themeName: String = "darkBlue"
}
struct indigo : Theme {
    var accentColor: Color = Color.indigo
    var themeName: String = "indigo"
}
struct purple : Theme {
    var accentColor: Color = Color.purple
    var themeName: String = "purple"
}
struct violet : Theme {
    var accentColor: Color = Color(red: 130 / 255, green: 82 / 255, blue: 244 / 255)
    var themeName: String = "violet"
}
struct softPurple : Theme {
    var accentColor: Color = Color(red: 138 / 255, green: 90 / 255, blue: 226 / 255)
    var themeName: String = "softPurple"
}
struct magenta : Theme {
    var accentColor: Color = Color(red: 209 / 255, green: 47 / 255, blue: 94 / 255)
    var themeName: String = "magenta"
}
struct millenialPink : Theme {
    var accentColor: Color = Color(red: 233 / 255, green: 51 / 255, blue: 247 / 255)
    var themeName: String = "millenialPink"
}
struct pink : Theme {
    var accentColor: Color = Color.pink
    var themeName: String = "pink"
}
struct brown : Theme {
    var accentColor: Color = Color.brown
    var themeName: String = "brown"
}
struct gray : Theme {
    var accentColor: Color = Color(.gray)
    var themeName: String = "gray"
}

class DataSource: ObservableObject {
    @AppStorage("selectedTheme") var selectedThemeAS = 1{
        didSet{
            updateTheme()
        }
    }
    init(){
        updateTheme()
    }
    
    @Published var selectedTheme: Theme = orange()
    
    func updateTheme(){
        selectedTheme = ThemeManager.getTheme(selectedThemeAS)
    }
}
