//
//  TurniView.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 29/11/22.
//

import SwiftUI

struct TurniView: View {
    @EnvironmentObject var auth : AuthenticationViewModel
    @State private var searchText = ""
    
    var body: some View {
        List {
            Section {
                ForEach(auth.staffList){ staff in
                    HStack {
                        ZStack{
                            Rectangle()
                                .cornerRadius(10)
                                .frame(width: 35,height: 35)
                                .foregroundColor(.green)
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                        }
                        .padding(10)
                        VStack(alignment: .leading) {
                            Text("\(staff.userName) \(staff.userSurname)").font(.headline.bold()).foregroundColor(.primary)
                        }
                        
                    }
                    .foregroundColor(.secondary)
                    .searchable(text: $searchText)
                }
            }header: {
                HStack {
                    Text("Personale").font(.caption)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.accentColor)
                }
            }
        }
        .listStyle(.insetGrouped)
        .tint(.secondary.opacity(0.4))
        .background(.ultraThinMaterial)
        .scrollContentBackground(.hidden)
    }
}
