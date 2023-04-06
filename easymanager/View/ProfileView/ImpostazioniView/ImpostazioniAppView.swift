//
//  ImpostazioniAppView.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 03/01/23.
//

import SwiftUI

struct ImpostazioniAppView: View {
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var dataSource: DataSource
    
    @State var selecttion = 1
    
    let adaptiveColumns = [
        GridItem(.adaptive(minimum: 30))
    ]
    
    var body: some View {
        NavigationStack{
            List{
                VStack(spacing: 0){
                    HStack (alignment: .center) {
                        VStack(alignment: .leading) {
                            Text("Easy Manager").font(sizeClass == .compact ? .title3 : .title).bold()

                            Text("Gestisci facilmente il tuo Ristorante, Caffè o Bistrot").fixedSize(horizontal: false, vertical: true).font(.caption).foregroundColor(.secondary)
                            Spacer()
                            ZStack{
                                Rectangle()
                                    .cornerRadius(20)
                                    .frame(height: 30)
                                    .foregroundColor(dataSource.selectedTheme.accentColor)
                                Text("V 0.1.0")
                                    .font(.caption).bold()
                                    .foregroundColor(Color(UIColor.systemBackground))
                                    .padding(3)
                            }
                        }
                        .frame(width: sizeClass == .compact ? 180 : 250)
                        .padding()
                        Spacer()
                    }
                    .frame(height: 100)
                    .padding(.vertical)
                }
                .frame(height: 250)

                
                Section {
                    
                    NavigationLink {
                        TemaAppView()
                    }label: {
                        HStack {
                            ZStack{
                                Rectangle()
                                    .cornerRadius(7)
                                    .frame(width: 30,height: 30)
                                    .foregroundColor(.orange)
                                Image(systemName: "paintbrush.fill")
                                    .foregroundColor(.white)
                            }
                            .padding(5)
                            Text("Colore dominante").font(.headline.bold()).foregroundColor(.primary)
                        }
                    }
                    
                    NavigationLink {
                        AspettoAppView()
                    }label: {
                        HStack {
                            ZStack{
                                Rectangle()
                                    .cornerRadius(7)
                                    .frame(width: 30,height: 30)
                                    .foregroundColor(.purple)
                                Image(systemName: "wand.and.stars")
                                    .foregroundColor(.white)
                            }
                            .padding(5)
                            Text("Aspetto").font(.headline.bold()).foregroundColor(.primary)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .navigationTitle("Impostazioni App")
        }
    }
}
