//
//  IconAppView.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 24/12/22.
//

import SwiftUI

struct IconAppView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
        
    var body: some View {
        NavigationStack{
            Form {
                Section{
                    HStack{
                        Spacer()
                        Rectangle()
                            .cornerRadius(20)
                            .frame(width: 120,height: 120)
                        Rectangle()
                            .cornerRadius(20)
                            .frame(width: 120,height: 120)
                        Spacer()
                    }
                    .padding(.vertical)
                }
                Section{
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))]){
                        ForEach(0..<10, id: \.self){ theme in
                            Rectangle()
                                .cornerRadius(20)
                                .frame(width: 90,height: 90)
                        }
                    }
                    .padding(.vertical)
                }header: {
                    HStack{
                        Text("altre opzioni...")
                    }
                }
                Section {
                    Button {
                        
                    } label: {
                        Text("Riporta alle condizioni Iniziali").bold().padding(.vertical,10)
                    }
                }footer:{
                    Text("L'icona predefinita verrà impostata a tema chiaro")
                }
            }
        }
        .navigationTitle("Icona App")
    }
}
