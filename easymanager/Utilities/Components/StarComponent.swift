//
//  StarComponent.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 03/03/23.
//

import SwiftUI

struct StarComponent: View {
    var body: some View {

        Image(systemName: "star.fill")
            .foregroundColor(.yellow)
            .shadow(color: .yellow, radius: 5)
            .padding(5)

    }
}
