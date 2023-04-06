//
//  TableComponent.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 11/12/22.
//

import SwiftUI

struct TableComponent: View {
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                ForEach(0..<3){index in
                    VStack(spacing: 5) {
                        Rectangle()
                            .frame(width: 50 - 10, height: 50 / 5)
                            .cornerRadius(100 / 5)
                        Rectangle()
                            .frame(width: 50, height: 50 * 2/3)
                            .cornerRadius(50 / 5)
                    }
                }
            }
            Rectangle()
                .frame(width: 250,height: 130)
                .cornerRadius(15)
            
            HStack(spacing: 10) {
                ForEach(0..<3){index in
                    VStack(spacing: 5) {
                        Rectangle()
                            .frame(width: 50, height: 50 * 2/3)
                            .cornerRadius(50 / 5)
                        Rectangle()
                            .frame(width: 50 - 10, height: 50 / 5)
                            .cornerRadius(100 / 5)

                    }
                }
            }
        }
    }
}

struct TableComponent_Previews: PreviewProvider {
    static var previews: some View {
        TableComponent()
    }
}
