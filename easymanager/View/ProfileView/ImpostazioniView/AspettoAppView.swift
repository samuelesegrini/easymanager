//
//  AspettoAppView.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 04/01/23.
//

import SwiftUI

struct AspettoAppView: View {
    @EnvironmentObject var csManager : ColorSchemeManager
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        NavigationStack{
            List{
                Section {
                    Picker(selection: $csManager.colorScheme) {
                        HStack {
                            ZStack{
                                Rectangle()
                                    .cornerRadius(7)
                                    .frame(width: 30,height: 30)
                                    .foregroundColor(.green.opacity(0.1))
                                Image(systemName: "circle.lefthalf.filled")
                                    .foregroundColor(.green)
                            }
                            .padding(5)
                            Text("Tema Sistema").font(.headline.bold()).foregroundColor(.primary)
                        }.tag(SchemeManager.unspecified)
                        HStack {
                            ZStack{
                                Rectangle()
                                    .cornerRadius(7)
                                    .frame(width: 30,height: 30)
                                    .foregroundColor(.orange.opacity(0.1))
                                Image(systemName: "sun.max.fill")
                                    .foregroundColor(.orange)
                                
                            }
                            .padding(5)
                            Text("Tema Chiaro").font(.headline.bold()).foregroundColor(.primary)
                        }.tag(SchemeManager.light)
                        HStack {
                            ZStack{
                                Rectangle()
                                    .cornerRadius(7)
                                    .frame(width: 30,height: 30)
                                    .foregroundColor(.blue.opacity(0.1))
                                Image(systemName: "moon.fill")
                                    .foregroundColor(.blue)
                            }
                            .padding(5)
                            Text("Tema Scuro").font(.headline.bold()).foregroundColor(.primary)
                        }.tag(SchemeManager.dark)
                    } label: {
                        
                    }
                    .pickerStyle(.inline)
                }
            }
        }
        .navigationTitle("Aspetto")
    }
}
