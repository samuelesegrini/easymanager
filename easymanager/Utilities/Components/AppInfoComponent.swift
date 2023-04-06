//
//  AppInfoComponent.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 04/01/23.
//

import SwiftUI

struct AppInfoComponent: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        ScrollView(.horizontal,showsIndicators: false){
            HStack{
                VStack(alignment: .center) {
                    Section {
                        HStack {
                            Text("0.1")
                                .font(.system(.title, design: .rounded)).bold()
                                .frame(width: 115)
                            Divider()
                        }
                    } header: {
                        HStack{
                            Spacer()
                            Text("VERSIONE ").font(.caption).textCase(.uppercase)
                            Spacer()
                        }
                        
                    } footer: {
                        HStack{
                            Spacer()
                            Text("").font(.caption).textCase(.uppercase)
                            Spacer()
                        }
                        
                    }
                }
                VStack(alignment: .center) {
                    Section {
                        HStack {
                            Text("4+")
                                .font(.system(.title, design: .rounded)).bold()
                                .frame(width: 115)
                            Divider()
                        }
                    } header: {
                        HStack{
                            Spacer()
                            Text("header").font(.caption).textCase(.uppercase)
                            Spacer()
                        }
                        
                    } footer: {
                        HStack{
                            Spacer()
                            Text("footer").font(.caption).textCase(.uppercase)
                            Spacer()
                        }
                        
                    }
                }
                VStack(alignment: .center) {
                    Section {
                        HStack {
                            Text("N.7")
                                .font(.system(.title, design: .rounded)).bold()
                                .frame(width: 115)
                            Divider()
                        }
                    } header: {
                        HStack{
                            Spacer()
                            Text("header").font(.caption).textCase(.uppercase)
                            Spacer()
                        }
                    } footer: {
                        HStack{
                            Spacer()
                            Text("footer").font(.caption).textCase(.uppercase)
                            Spacer()
                        }
                        
                    }
                }
                VStack(alignment: .center) {
                    Section {
                        HStack {
                            Text(" IT")
                                .font(.system(.title, design: .rounded)).bold()
                                .frame(width: 115)
                            Divider()
                        }
                    } header: {
                        HStack{
                            Spacer()
                            Text("Lingua").font(.caption).textCase(.uppercase)
                            Spacer()
                        }
                        
                    } footer: {
                        HStack{
                            Spacer()
                            Text("+0 ").font(.caption).textCase(.uppercase)
                            Spacer()
                        }
                        
                    }
                }
                Link(destination: URL(string: "https://wape.one")!) {
                    VStack(alignment: .center) {
                        Section {
                            HStack {
                                Image(systemName: "person.crop.square")
                                    .font(.system(.title, design: .rounded)).bold()
                                    .frame(width: 115)
                            }
                        } header: {
                            HStack{
                                Spacer()
                                Text("Fornitore").font(.caption).textCase(.uppercase)
                                Spacer()
                            }
                            Spacer()
                            
                        } footer: {
                            Spacer()
                            HStack{
                                Spacer()
                                Text("Wape One").font(.caption).textCase(.uppercase)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }.foregroundColor(.secondary)
    }
}

struct AppInfoComponent_Previews: PreviewProvider {
    static var previews: some View {
        AppInfoComponent()
    }
}
