//
//  CashDesk.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import SwiftUI

struct CashDesk: View {
    var body: some View {
        VStack{
            Text("oh bella")
        }
    }
}

struct CashDesk_Previews: PreviewProvider {
    static var previews: some View {
        CashDesk()
            .environmentObject(AuthenticationViewModel())
    }
}
