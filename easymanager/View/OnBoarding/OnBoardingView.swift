//
//  OnBoardingView.swift
//  easymanager
//
//  Created by Samuele Segrini on 01/04/23.
//

import SwiftUI

struct OnBoardingView: View {
    //Environment Object of AuthenticationViewModel to handle data from Firebase 🔥
    @EnvironmentObject var auth : AuthenticationViewModel
    @EnvironmentObject var restaurant : RestaurantViewModel
    
    //Variable that handles the selection of pages
    @State private var selection = 6
    
    //Variable that signals if the partita IVA number is valid (Max. 11 digits)
    @State private var isNumberValid = true
    
    //Variable that handles the show of onboarding every time a user (dipendente) signs in
    @State private var rememberOnBoarding = true
    
    //Variable that handles the show of the sheet that contains the LogInView page
    @State private var showLogIn = false
    
    @State private var showErrorMessage = false
    
    //Variable that handles the show of the sheet that contains the selection of the password
    @State private var showPassowrd = false
    
    //Variable that handles the show of the sheet that contains a form for the adress of a location
    @State private var showAddLocation = false
    
    //Variables for the textfields of the location's form
    @State private var streetAddress = ""
    @State private var locationName = ""
    @State private var city = ""
    @State private var zip = ""
    @State private var phone = ""
    @State private var email = ""
    
    //Variables for the selection of a role (show checked symbol if true)
    @State private var selectedAdmin = false
    @State private var selectedCucina = false
    @State private var selectedPos = false
    @State private var selectedCameriere = false

    var body: some View {
        VStack{
            NavigationStack{
                //TabView for the show of pages
                TabView(selection: $selection){
                //TODO: Implementing other pages of OnBoarding
                    /*WelcomePage()
                        .tag(1)
                        .frame(maxWidth: 500, maxHeight: 800)
                        .padding()
                    InfoPage()
                        .tag(2)
                        .frame(maxWidth: 500, maxHeight: 800)
                        .padding()
                    InfoTitolare()
                        .tag(3)
                        .frame(maxWidth: 500, maxHeight: 800)
                        .padding()*/
                    DipendenteSubView()
                        .tag(6)
                        .frame(maxWidth: 500, maxHeight: 800)
                        .padding()
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.linear, value: selection)
            }
        }
    }
    //MARK: View that shows the login page for a normal user (dipendente)
    @ViewBuilder
    func DipendenteSubView() -> some View {
        VStack(alignment: .center){
            Circle()
                .frame(width: 100)
            
            Text("👋 Salve Dipendente").font(.title).fontWeight(.semibold)
                .minimumScaleFactor(0.6)
                .lineLimit(2)
            
            Spacer()
            
            VStack{
                //If showOnBoarding is checked (true) the onboarding page never shows again
                Toggle("Vuoi che ci ricordiamo di te?", isOn: $rememberOnBoarding)
                    .font(.callout)
                Text("Se scegli l'opzione di non ricordarci di te, ogni volta che aprirai l'app dovrai ripetere il processo appena eseguito\n\nNota bene che questa restizione potrebbe essere modificata dal tuo titolare o dal tuo ruolo nel locale dove lavori")
                    .font(.caption).foregroundColor(.secondary)
                Text("")
                    .font(.caption).foregroundColor(.secondary)
            }
            .padding()
            
            //Triggering login page
            Button {
                showLogIn.toggle()
            } label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 15)
                    Text("Accedi".capitalized).font(.headline).bold()
                        .foregroundColor(.white)
                }
            }
            .frame(height: 60)
            .padding(.horizontal)

            //Back to the initial page of admin account creation (titolare)
            Button {
                selection = 1
            } label: {
                Text("Sei un titolare ?")
                    .font(.subheadline)
            }
        }
        .sheet(isPresented: $showLogIn) {
            NavigationStack{
                LoginView(rememberOnBoarding: rememberOnBoarding)
                    .environmentObject(auth)
                    .frame(maxWidth: 500, maxHeight: 800)
            }
        }
    }
    //MARK: Shows the first page with some information about the app
    @ViewBuilder
    func WelcomePage() -> some View {
        VStack(alignment: .center){
            Text("Benvenuto!").font(.title).fontWeight(.semibold)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            HStack{
                Image(systemName: "laurel.leading")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 30, maxHeight: 75)
                    .foregroundColor(.secondary)
                VStack{
                    Text("Sei pronto a trasformare il TUO ristorante in un'attività da DIESCI? \n ")
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .minimumScaleFactor(0.6)
                        .lineLimit(3)
                    Text("Altro che confermare o ribaltare il risultato")
                        .font(.system(.caption).italic())
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)
                        .lineLimit(2)
                        .padding(.horizontal)
                }
                Image(systemName: "laurel.trailing")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 30, maxHeight: 75)
                    .foregroundColor(.secondary)
            }
            
            //Show some of the features of the app
            //TODO: optimize this code to show information recursively
            ZStack{
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(UIColor.quaternarySystemFill))
                VStack{
                    HStack{
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading){
                            Text("Prima funzione").bold()
                            Text("Prima descrizione")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .hAllign(.leading)
                    .padding(.horizontal)
                    HStack{
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading){
                            Text("Seconda funzione").bold()
                            Text("Seconda descrizione")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .hAllign(.leading)
                    .padding(.horizontal)
                    HStack{
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading){
                            Text("Terza funzione").bold()
                            Text("Terza descrizione")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .hAllign(.leading)
                    .padding(.horizontal)
                    HStack{
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading){
                            Text("Quarta funzione").bold()
                            Text("Quarta descrizione")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .hAllign(.leading)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .padding()
            .frame(maxHeight: 400)
            
            Spacer()

            Text("Easy Manager è un'app indipendente che ti aiuta nella gestione del tuo ristorante a 360 gradi")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            //Goes to the second page to insert restaurant information
            Button {
                selection = 2
            } label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 15)
                    Text("Registra il Ristorante".capitalized).font(.headline).bold()
                        .foregroundColor(.white)
                }
            }
            .frame(height: 60)
            .padding(.horizontal)
            
            //If the user is not an admin (titolare) jump to the user page for login (page 6)
            Button {
                selection = 6
            } label: {
                Text("Sei un dipendente ?")
                    .font(.subheadline)
            }
        }
    }
    //MARK: View that shows the information page for the restaurant, insert initial restaurant data
    @ViewBuilder
    func InfoPage() -> some View {
        VStack(alignment: .leading){
            HStack(alignment: .center){
                Text("👋 Salve Titolare")
                    .font(.title).fontWeight(.semibold)
            }
            .padding(.trailing)
            .padding(.bottom)
            Text("Come possiamo chiamare il tuo Locale ?")
                .font(.title).fontWeight(.semibold)
                .multilineTextAlignment(.leading)
            
            //Insert restaurant name and pratita IVA (italian code for enterprises)
            VStack{
                HStack{
                    Text("Nome Attività : ").bold()
                    TextField("Obbligatorio", text: $restaurant.restaurantName)
                        .keyboardType(.default)
                }
                    .padding(.horizontal)
                    .padding(.top)
                HStack{
                    Text("Partita IVA : ").bold()
                    TextField("Partita Iva (Max. 11 Cifre)", value: $restaurant.restaurantIva, format: .number)
                        .padding()
                        .keyboardType(.decimalPad)
                    
                    //If the number of the partita IVA is invalid (More than 11 digits) display red marks
                        .border(Color.red, width: isNumberValid ? 0 : 2)
                        .background(isNumberValid ? .clear : .red.opacity(0.2))
                        .keyboardType(.decimalPad)
                    
                    //On Change of the number $partitaIva check if it's valid
                        .onChange(of: restaurant.restaurantIva) { newValue in
                            let number = Int(newValue)
                            
                            //Calls function to count digits of number ($partitaIva) and checks if digits are minor or equal of 11
                            isNumberValid = countDigits(number) <= 11
                        }
                }.padding(.horizontal)
                
                //If $partitaIva number is invalid (!isNumberValid) display text to inform the user
                if !isNumberValid{
                    Text("Partita IVA errata").foregroundColor(.red)
                        .padding(.bottom)
                }
            }
            .background(Color(UIColor.quaternarySystemFill))
            .cornerRadius(15)
            .padding(.bottom)
            
            //Locations display header with button to trigger the sheet to add a location
            HStack{
                Text("Aggiungi sedi 🏠")
                    .font(.title).fontWeight(.semibold)
                Spacer()
                
                //Triggers the sheet
                Button {
                    showAddLocation.toggle()
                } label: {
                    Image(systemName: "plus").font(.title2).padding(.trailing)
                }
            }
            .sheet(isPresented: $showAddLocation) {
                NavigationStack{
                    AddLocation()
                }
            }
            
            //If the are no locations inform the user
            if restaurant.restaurantLocations.isEmpty {
                Text("Ancora nessuna sede inserita").font(.subheadline).foregroundColor(.secondary).padding()
            } else {
                
                //If there are locations, display them in a list
                List(restaurant.restaurantLocations, id: \.self){ location in
                    VStack(alignment: .leading){
                        Text(location.locationName).font(.headline)
                        Text("\(location.city), \(location.streetAddress)").font(.caption2).foregroundColor(.secondary)
                    }
                    .padding(.vertical,7)
                }
                .frame(maxHeight: 190)
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
                .background{
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(UIColor.quaternarySystemFill))
                }
                .padding(.bottom)
            }
            Spacer()
            
            //Goes to the third page to insert admin (titolare) information
            Button {
                restaurant.saveRestaurant()
                selection = 3
            } label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 15)
                    Text("Crea il Tuo Account".capitalized).font(.headline).bold()
                        .foregroundColor(.white)
                }
            }
            .frame(height: 60)
            .padding(.horizontal)
            
            //If the data about the restaurant is not all inserted, don't make the button tappable
            .disabled(!isNumberValid || restaurant.restaurantIva == 0 || restaurant.restaurantName == "" || restaurant.restaurantLocations.isEmpty)
            
            //Goes to the initial page of welcome
            Button {
                selection = 1
            } label: {
                HStack{
                    Image(systemName: "chevron.left")
                    Text("Indietro")
                }
                .font(.subheadline)
            }
            .hAllign(.center)
        }
    }
    //MARK: View that displays the form to insert new location data
    @ViewBuilder
    func AddLocation() -> some View {
        VStack {
            Form{
                Section{
                    TextField("Nome Sede", text: $locationName)
                        .keyboardType(.default)
                    TextField("Via delle Stelle, 73", text: $streetAddress)
                        .keyboardType(.default)

                    TextField("Milano", text: $city)
                        .keyboardType(.default)

                    TextField("20122", text: $zip)
                        .keyboardType(.decimalPad)
                }header: {
                    Text("Inserisci le Info di una Sede")
                }
                Section{
                    TextField("+39", text: $phone)
                        .keyboardType(.decimalPad)
                    TextField("nome.cognome@email", text: $email)
                        .keyboardType(.default)
                }header: {
                    Text("Inserisci Contatti")
                }footer: {
                    Text("Per il momento i contatti possono essere omessi, ma si consiglia di inserirli")
                }
            }
            Button {
                restaurant.restaurantLocations.append(Adress(locationName: locationName.capitalized, streetAddress: streetAddress, city: city, zip: zip, phone: phone, email: email))
                showAddLocation.toggle()
            } label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 15)
                    Text("Salva Sede".capitalized).font(.headline).bold()
                        .foregroundColor(.white)
                }
            }
            .frame(height: 60)
            .padding(.horizontal, 30)
            .padding(.bottom)
            .disabled(locationName == "" || streetAddress == "" || city == "" || zip == "")
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Aggiungi Sede")
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing){
                Button {
                    showAddLocation.toggle()
                } label: {
                    Text("Annulla")
                }

            }
        }
    }
    //MARK: View that require the admin to insert information for  his account
    @ViewBuilder
    func InfoTitolare() -> some View {
        VStack(alignment: .leading){
            HStack(alignment: .center){
                Text("Conosciamoci un po' Meglio 🫶")
                    .font(.title).fontWeight(.semibold)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            .padding(.bottom)
            .padding(.trailing)
            VStack{
                HStack{
                    Text("Nome Titolare : ").bold()
                    TextField("Obbligatorio", text: $auth.name)
                        .keyboardType(.default)
                }
                .padding(.horizontal)
                .padding(.top)
                HStack{
                    Text("Cognome Titolare : ").bold()
                    TextField("Obbligatorio", text: $auth.surname)
                        .keyboardType(.default)
                }
                .padding(.horizontal)
                .padding(.top)
                HStack{
                    Text("Email Titolare : ").bold()
                    TextField("Obbligatorio", text: $auth.email)
                        .keyboardType(.emailAddress)
                }
                .padding()
            }
            .background(Color(UIColor.quaternarySystemFill))
            .cornerRadius(15)
            .padding(.bottom)
            
            Text("Quali ruoli avrai come Titolare? 📓")
                .font(.title).fontWeight(.semibold)
                .minimumScaleFactor(0.8)
                .lineLimit(2)
            VStack(alignment: .leading){
                HStack{
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .padding(.trailing, 5)
                    VStack(alignment: .leading){
                        Text("Admin").foregroundColor(.primary)
                        Text("Sempre selezionato, consente di gestire tutte le funzioni dell'app")
                            .multilineTextAlignment(.leading)
                            .lineLimit(2, reservesSpace: true)
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.vertical, 5)
                }
                
                Button {
                    selectedPos.toggle()
                    auth.roles.append("pos")
                } label: {
                    HStack{
                        Image(systemName: selectedPos ? "checkmark.circle.fill" : "circle")
                            .padding(.trailing, 5)
                        VStack(alignment: .leading){
                            Text("Pos").foregroundColor(.primary)
                            Text("Profilo per fare il checkout nel dispositivo centrale e stampare scontrini fiscali").foregroundColor(.secondary)
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.vertical, 5)
                        Spacer()
                    }
                }
                Button {
                    selectedCameriere.toggle()
                    auth.roles.append("cameriere")
                } label: {
                    HStack{
                        Image(systemName: selectedCameriere ? "checkmark.circle.fill" : "circle")
                            .padding(.trailing, 5)
                        VStack(alignment: .leading){
                            Text("Cameriere").foregroundColor(.primary)
                            Text("Profilo per fare ordini ai tavoli e stampare le comande").foregroundColor(.secondary)
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.vertical, 5)
                    }
                }
                Button {
                    selectedCucina.toggle()
                    auth.roles.append("cucina")
                } label: {
                    HStack{
                        Image(systemName: selectedCucina ? "checkmark.circle.fill" : "circle")
                            .padding(.trailing, 5)
                        VStack(alignment: .leading){
                            Text("Cucina").foregroundColor(.primary)
                            Text("Profilo per visualizzare gli ordini in cucina").foregroundColor(.secondary)
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.quaternarySystemFill))
            .cornerRadius(15)
            .padding(.bottom)
            
            Spacer()
            Button {
                showPassowrd.toggle()
            } label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 15)
                    Text("Crea Profilo".capitalized).font(.headline).bold()
                        .foregroundColor(.white)
                }
            }
            .disabled(auth.name == "" || auth.surname == "" || auth.email == "")
            .frame(height: 60)
            .padding(.horizontal)
            
            Button {
                selection = 2
            } label: {
                HStack{
                    Image(systemName: "chevron.left")
                    Text("Indietro")
                }
                .font(.subheadline)
            }
            .hAllign(.center)
        }
        //On Appear of admin page adding admin role to roles list
        .onAppear{
            if auth.roles.isEmpty{
                auth.roles.append("admin")
                auth.name = ""
                auth.surname = ""
                auth.email = ""
            }
        }
        .sheet(isPresented: $showPassowrd) {
            VStack{
                NavigationStack{
                    Text("Ciao \(auth.name) \(auth.surname)").font(.headline)
                    Text("Vogliamo che il tuo Account sia al Sicuro, o no? 🔐")
                        .font(.title).fontWeight(.semibold)
                        .minimumScaleFactor(0.6)
                        .lineLimit(3)
                        .vAllign(.center)
                    VStack{
                        HStack {
                            Image(systemName: "lock")
                            SecureField("Password", text: $auth.password)
                                .submitLabel(.next)
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Image(systemName: "lock")
                            SecureField("Conferma Password", text: $auth.confirmPassword)
                        }
                        Text("\(restaurant.restaurantCurrent.id ?? "")")

                    }
                    .padding()
                    .background(Color(UIColor.quaternarySystemFill))
                    .cornerRadius(15)
                    .padding(.bottom)
                    
                    //Allert the user that the two password are not equal
                    if auth.password != auth.confirmPassword && auth.password != "" && auth.confirmPassword != "" {
                        Text("Le password non combaciano").foregroundColor(.red)
                    }
                    if auth.errorMessage != "" && showErrorMessage {
                        Text(auth.errorMessage ?? "").foregroundColor(.red)
                    }
                    Button {
                        SignUp()
                        showErrorMessage = true
                        if auth.errorMessage == "" {
                            showPassowrd.toggle()
                        }
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 15)
                            Text("Inizia la tua Esperienza con noi ".capitalized).font(.headline).bold()
                                .foregroundColor(.white)
                        }
                    }
                    .disabled(auth.password != auth.confirmPassword || auth.password == "" || auth.confirmPassword == "")
                    .frame(height: 60)
                    .padding(.horizontal)
                }
            }
            .padding()
            .frame(maxWidth: 500, maxHeight: 800)
        }
    }
    func SignUp() {
        Task {
            //auth.restaurantID = restaurant.restaurantCurrent.id ?? ""
            if await auth.signUpWithEmailPassword() == true {
                auth.authenticationState = .authenticated
            }
        }
    }
    
    func countDigits(_ number: Int) -> Int {
        var count = 0
        var num = number
        while num != 0 {
            num /= 10
            count += 1
        }
        return count
    }
}

struct OnBoardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnBoardingView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(RestaurantViewModel())
    }
}
