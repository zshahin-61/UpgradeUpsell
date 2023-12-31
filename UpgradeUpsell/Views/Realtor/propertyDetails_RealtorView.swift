//
//  propertyDetails_RealtorView.swift
//  UpgradeUpsell
//
//  Created by Golnaz Chehrazi on 2023-11-30.
//

import SwiftUI
import MapKit

struct PropertyDetails_RealtorView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dbHelper: FirestoreController

    let project: RenovateProject

    @State private var amountOffered = ""
    @State private var durationWeeks = ""
    @State private var description = ""

    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var propertyLatitude: Double = 0.0
    @State private var propertyLongitude: Double = 0.0

    
   // @State private var shouldDismissView = false
    
    var body: some View {
        VStack{
            Text("Property Details").bold().font(.title).foregroundColor(.brown)
            List {
                //Section(header: Text("Property Information").font(.headline)) {
                Section{
                VStack(alignment: .leading, spacing: 2){
                        Text("Title: ").font(.subheadline)
                        Text("\(project.title)")
                    }.padding(2)
                    VStack(alignment: .leading, spacing: 2){
                        Text("Category: ").font(.subheadline)
                        Text("\(project.category)")
                    }.padding(2)
                    VStack(alignment: .leading, spacing: 2){
                        Text("Released date: ").font(.subheadline)
                        Text("\(formattedDate(from: project.createdDate))")
                    }.padding(2)
                    VStack(alignment: .leading, spacing: 2){
                        HStack{
                            Text("Need to be done between: ").font(.subheadline)
                            Spacer()
                        }
                        HStack{
                            Text(" \(formattedDate(from: project.startDate))")
                            Text("  to  \(formattedDate(from: project.endDate))")
                        }
                    }.padding(2)
                    
                    Section {
                        if let images = project.images{
                            if !images.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(images, id: \.self) { image in
                                            if let uiImage = UIImage(data: image) {
                                                Image(uiImage:  uiImage)
                                                    .resizable()
                                                    //.aspectRatio(contentMode: .fit)
                                                    .frame(width: 200, height: 200) // Set a fixed size
                                            }
                                        }
                                    }
                                }
                            } else {
                                Text("No images available")
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2){
                        HStack{
                            Text("Owner Description:").font(.subheadline)
                            Spacer()
                        }
                        Text("\(project.description)")
                    }.padding(2)
                    
//                    HStack{
//                        Text("Likes: ").bold()
//                        Text("\(project.favoriteCount)")
//                        Spacer()
//                        Text("Status: ").bold()
//                        Text("\(project.status)")
//                    }
                    VStack(alignment: .leading, spacing: 2){
                        Text("Location: ").font(.subheadline)
                        Text("\(project.location)")
                    }.padding(2)
                    
                    MapView(latitude: propertyLatitude, longitude: propertyLongitude)
                        .frame(height: 200)
                    
                }//section
            } .background(Color.gray.opacity(0.1))// Form
            
            .onAppear {
                // Retrieve the latitude and longitude values from your database for the property
                // For example, if you have a property object with lat and lng properties:
                propertyLatitude = project.lat
                propertyLongitude = project.lng
                
                if propertyLatitude == 0.0 && propertyLongitude == 0.0 {
                    let geocoder = CLGeocoder()
                    geocoder.geocodeAddressString(project.location) { placemarks, error in
                        if let placemark = placemarks?.first, let location = placemark.location {
                            propertyLatitude = location.coordinate.latitude
                            propertyLongitude = location.coordinate.longitude
                        }
                    }
                }
            }
            
        }
        
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Result"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
                //{
                    //self.showAlert = false
                    //if shouldDismissView  && !alertMessage.lowercased().contains("error") {
                      //  self.presentationMode.wrappedValue.dismiss()
                   // }
                //}
            )
        }
        //.navigationBarTitle("Add an Offer")
    }

    //insert in notifications
    func insertNotif(_ myOffer : InvestmentSuggestion, _ a : String){
        
        var flName = ""
        if let fullName = dbHelper.userProfile?.fullName{
            flName = fullName
        }
        
        let notification = Notifications(
            id: UUID().uuidString,
            timestamp: Date(),
            userID: myOffer.ownerID,
            event: "Offer \(a)!",
            details: "Offer $\(myOffer.amountOffered) for project titled \(myOffer.projectTitle) has been \(a) By \(flName).",
            isRead: false,
            projectID: myOffer.projectID
        )
        dbHelper.insertNotification(notification) { notificationSuccess in
            if notificationSuccess {
#if DEBUG
                print("Notification inserted successfully.")
                #endif
            } else {
#if DEBUG
                //alertMessage = "Error inserting notification."
                print("Error inserting notification.")
                #endif
            }
        }
    }
    
    // Function to validate the form
        func validateForm() -> Bool {
            var isValid = true
            var validationMessage = ""

            // Validate amountOffered
            if amountOffered.isEmpty || Double(amountOffered) == nil || Double(amountOffered)! <= 0 {
                isValid = false
                validationMessage += "Please enter a valid amount offered.\n"
            }

            // Validate durationWeeks
            if durationWeeks.isEmpty || Int(durationWeeks) == nil || Int(durationWeeks)! <= 0 {
                isValid = false
                validationMessage += "Please enter a valid duration in weeks.\n"
            }

            // Validate description
            if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                isValid = false
                validationMessage += "Please enter a description.\n"
            }
            if(validationMessage != ""){
                
                alertMessage = "Error: " + validationMessage
            }
            return isValid
        }
    
    func formattedDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
}
