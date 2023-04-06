//
//  TimeLineComponent.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 27/02/23.
//

import SwiftUI

struct TimeLineComponent: View {
    var body: some View {
        ScrollView(.horizontal , showsIndicators: false) {
            HStack {
                ForEach(0..<50){ item in
                    Divider()
                        .padding(20)
                }
            }
        }
    }
}

struct TimeLineComponent_Previews: PreviewProvider {
    static var previews: some View {
        TimeLineComponent()
    }
}
