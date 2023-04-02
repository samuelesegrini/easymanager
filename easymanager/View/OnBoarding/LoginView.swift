//
//  LoginView.swift
//  easymanager
//
//  Created by Samuele Segrini on 01/04/23.
//

import SwiftUI

struct LoginView: View {
    //Dismiss environment variable to dismiss the sheet
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var auth : AuthenticationViewModel
    
    //Needs the showOnBoarding variable to decide if to make the user re-login everyTime
    @State var rememberOnBoarding : Bool
    
    @State private var showErrorMessage = false
    
    var body: some View {
        VStack{
            Spacer()
            VStack{
                HStack {
                    Image(systemName: "at")
                    TextField("Email", text: $auth.email)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .submitLabel(.next)
                }
                .padding(.bottom)
                
                HStack {
                    Image(systemName: "lock")
                    SecureField("Password", text: $auth.password)
                        .submitLabel(.go)
                        .onSubmit {
                            LogIn()
                        }
                }
            }
            .padding()
            .background(Color(UIColor.quaternarySystemFill))
            .cornerRadius(15)
            if rememberOnBoarding {
                Text("Hai scelto di non ripetere il processo di inserimento ogni volta, quindi non ci rivedremo presto qui ...")
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding()
            }
            if auth.errorMessage != "" && showErrorMessage {
                Text(auth.errorMessage ?? "").foregroundColor(.red)
            }
            Button {
                showErrorMessage = true
                if auth.errorMessage == "" {
                    LogIn()
                }
            } label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 15)
                    Text("Accedi".capitalized).font(.headline).bold()
                        .foregroundColor(.white)
                }
            }
            .frame(height: 60)
            .padding(.horizontal)
            Text(auth.user?.email ?? "non so")
        }
        .navigationTitle("Accedi al tuo Account")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("Annulla")
                }

            }
        }
        .padding()
    }
    private func LogIn() {
        Task {
            if await auth.LogInWithEmailPassword() == true {
                auth.authenticationState = .authenticated
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(rememberOnBoarding: true)
            .environmentObject(AuthenticationViewModel())
    }
}
