//
//  SettingsView.swift
//  UpgradeUpsell
//
//  Created by Golnaz Chehrazi on 2023-10-04.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authHelper: FireAuthController
    @EnvironmentObject var dbHelper: FirestoreController
    @EnvironmentObject var themeManager: ThemeManager
    
    //@Environment(\.presentationMode) var presentationMode
    @State private var pushNotifFromUI = false
       @State private var notificationsEmail = false
       @State private var themeFromUI = "light"
       @State private var langFromUI = "English"//"en-us"
       @State private var fontSizeFromUI = 14
    
    @State private var showingDeleteAlert = false
    @Binding var rootScreen : RootView
    @State private var role: String = "Owner"
    
    var body: some View {
        VStack {
            Text("Settings").bold().font(.title).foregroundColor(.brown)
            VStack {
                Form {
                    Section(header: Text("Preferences")) {
                        //                        Picker("Theme", selection: $themeFromUI) {
                        //                            Text("Light").tag("light")
                        //                            Text("Dark").tag("dark")
                        //                        }
                        
                        Toggle("Dark Mode", isOn: Binding(
                            get: { themeManager.selectedTheme == "dark" },
                            set: { _ in themeManager.toggleTheme() }
                        ))
                        .padding()
                        
                        Picker("Language", selection: $langFromUI) {
                            Text("English")//.tag("en_CA")
                            Text("French")//.tag("fr_CA")
                            // Add more languages here as needed
                        }
                        
                        Stepper("Font Size: \(fontSizeFromUI)", value: $fontSizeFromUI, in: 12...24)
                    }
                    
                    Section(header: Text("Notifications")) {
                        Toggle(isOn: $pushNotifFromUI , label: {
                            Text("Push Notifications")
                        })
                        
                        Toggle(isOn: $notificationsEmail, label: {
                            Text("Email Notifications")
                        })
                    }
                    HStack{
                        Button(action: {
                            let newPref = Prefrences(id: dbHelper.userProfile!.id!, fontSize: fontSizeFromUI, theme: themeFromUI, language: langFromUI, pushNotif: pushNotifFromUI, emailNotif: notificationsEmail)
                            //
                            self.dbHelper.saveUserPrefrences(newPref: newPref) { (prefrences, error) in
                                if let error = error {
                                    // Handle the error
                                    print("Error saving preferences: \(error.localizedDescription)")
                                } else if let preferences = prefrences {
                                    // Successfully saved/update the preferences
                                    print("Preferences saved/updated successfully: \(prefrences)")
                                    //self.presentationMode.wrappedValue.dismiss()
                                    if let loginedUserRole = dbHelper.userProfile?.role{
                                        if loginedUserRole == "Owner"{
                                            self.rootScreen = .Home
                                        }
                                        else if loginedUserRole == "Investor"{
                                            self.rootScreen = .InvestorHome
                                        }
                                        else if loginedUserRole == "Realtor"{
                                            self.rootScreen = .RealtorHome
                                        }
                                    }else
                                    {
                                        self.rootScreen = .Home
                                    }
                                }
                            }
                            
                        }) {
                            Text("Save Preferences")
                        }.buttonStyle(.borderedProminent)
                        Spacer()
                        Button(action:{
                            // self.presentationMode.wrappedValue.dismiss()
                            if(self.role == "Investor"){
                                self.rootScreen = .InvestorHome
                            }else if self.role == "Admin" {
                                self.rootScreen = .Admin
                            }else if self.role ==  "Owner"{
                                self.rootScreen = .Home
                            }  else if self.role == "Admin"{
                                self.rootScreen = .Admin
                                
                            } else if self.role == "Realtor"
                                        
                            {
                                self.rootScreen =  .RealtorHome
                            }
                        }){
                            Text("Back")
                        }.buttonStyle(.borderedProminent)
                    }
                    
                    Section(header: Text("Account")) {
                        Button(action:{
                            
                            showingDeleteAlert = true
                            
                            // TODO: before delete checking other collections has data of this user
                            
                            
                        }){
                            Image(systemName: "multiply.circle").foregroundColor(Color.white)
                            Text("Delete My Account")
                            Spacer()
                        }.padding(5).font(.title2).foregroundColor(Color.white)//
                            .buttonBorderShape(.roundedRectangle(radius: 15)).buttonStyle(.bordered).background(Color.red)
                        
                    }
                }//Form
            }
            //.navigationTitle("Settings")
            .navigationBarItems(leading: Button(action: {
                if(self.role == "Investor"){
                    self.rootScreen = .InvestorHome
                }else if self.role ==  "Owner"{
                    self.rootScreen = .Home
                } else if self.role == "Realtor"
                {
                    self.rootScreen =  .RealtorHome
                    
                } else if self.role ==  "Admin"{
                    self.rootScreen =  .Admin
                }
                
                //self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("< Back")
            })
            .onAppear {
                
                if let role = self.dbHelper.userProfile?.role{
                    self.role = role
                }
                dbHelper.getPreferencesFromFirestore(forUserID: dbHelper.userProfile?.id! ?? ""){ (userPref, error) in
                    //                    guard let userPref = dbHelper.userPrefrences else{
                    //                        return
                    //                    }
                    if let error = error{
                        
                    }else if let userPref = userPref {
                        
                        self.fontSizeFromUI = userPref.fontSize ?? 14
                        self.langFromUI = userPref.language
                        self.notificationsEmail = userPref.emailNotif
                        self.pushNotifFromUI = userPref.pushNotif
                        self.themeFromUI = userPref.theme
                    }
                }
            }
            
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Confirm Delete"),
                message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    // Delete account logic here
                    self.dbHelper.deleteUser(withCompletion: { isSuccessful in
                        if (isSuccessful){
                            self.authHelper.deleteAccountFromAuth(withCompletion: { isSuccessful2 in
                                if (isSuccessful2){
                                    //sign out using Auth
                                    self.authHelper.signOut()
                                    
                                    //self.selectedLink = 1
                                    //dismiss current screen and show login screen
                                    self.rootScreen = .Login
                                }
                            }
                            )}
                    })
                },
                secondaryButton: .cancel()
            )
        }
        Spacer()
    }
}

struct DeleteAccountView: View {
    var body: some View {
        VStack {
            Text("Are you sure you want to delete your account?")
                .font(.headline)
                .padding()
            
            Button(action: {
                // Perform the account deletion
            }) {
                Text("Delete Account")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("Delete Account")
      
    }
}
