//
//  TemaAppView.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 24/12/22.
//

import SwiftUI

struct TemaAppView: View {
    @EnvironmentObject var dataSource: DataSource
    @Environment(\.horizontalSizeClass) var sizeClass
    
    let colorColumns = [
        GridItem(.adaptive(minimum: 55))
    ]
        
    var body: some View {
        NavigationStack{
            Form {
                Section{
                    LazyVGrid(columns: colorColumns){
                        ForEach(0..<ThemeManager.themes.count, id: \.self){ theme in
                            ZStack {
                                Circle()
                                    .fill(ThemeManager.themes[theme].accentColor)
                                    .frame(width: 44)
                                    .padding(5)
                                
                                if dataSource.selectedThemeAS == theme {
                                    Circle()
                                        .stroke(ThemeManager.themes[theme].accentColor, lineWidth: 3)
                                        .frame(width: 55)
                                }
                            }
                            .onTapGesture {
                                dataSource.selectedThemeAS = theme
                                dataSource.updateTheme()
                            }
                        }
                    }
                    .padding(10)
                }
                Section {
                    Button {
                        dataSource.selectedThemeAS = 3
                        dataSource.updateTheme()
                    } label: {
                        Text("Riportare alle condizioni Iniziali").bold().padding(.vertical,10)
                    }
                }footer:{
                    Text("L'opzione colore predefinita verrà impostata a blu")
                }
            }
        }
        .navigationTitle("Colore Dominante")
    }
}
