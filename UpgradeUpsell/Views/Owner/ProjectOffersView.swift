import Foundation
import SwiftUI

struct ProjectOffersView: View {
    @EnvironmentObject var authHelper: FireAuthController
    @EnvironmentObject var dbHelper: FirestoreController

    @State private var suggestions: [InvestmentSuggestion] = []
    @State private var isLoading: Bool = false
    @State private var updatedStatuses: [String] = [] // Store updated statuses
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    
    @State private var isStatusUpdated: [Bool] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack{
                Spacer()
                Text("Offers").bold().font(.title).foregroundColor(.brown)
                Spacer()
            }
            List {
                if dbHelper.userProfile == nil {
                    Text("No user login")
                } else if isLoading {
                    ProgressView()
                } else {
                    ForEach(suggestions.indices, id: \.self) { index in
                        Section {
                            HStack {
                                Text("Title:").bold()
                                Spacer()
                                Text("\(suggestions[index].projectTitle)")
                            }
                            HStack {
                                Text("Offer Date:").bold()
                                Spacer()
                                Text("\(dateFormatter.string(from: suggestions[index].date ?? Date()))")
                            }
                            Group {
                                HStack {
                                    NavigationLink(destination: InvestorProfileView(investorID: suggestions[index].investorID).environmentObject(self.authHelper).environmentObject(self.dbHelper)) {
                                        Text("Investor:").bold()
                                        Spacer()
                                        Text(suggestions[index].investorFullName) .foregroundColor(.blue)// Link to Investor Profile
                                    }
                                }
                                
                                HStack {
                                    Text("Offered amount:").bold()
                                    Spacer()
                                    Text(String(format: "%.2f", suggestions[index].amountOffered))
                                }
                                
                                HStack {
                                    Text("Duration:").bold()
                                    Spacer()
                                    Text("\(suggestions[index].durationWeeks) Weeks")
                                }
                            }
                            
                           if !isStatusUpdated[index]  {
                           // if suggestions[index].status == "Pending" {
                                HStack {
                                            Text("Status:").bold()
                                            Spacer()
                                            Picker("Status", selection: $suggestions[index].status) {
                                                Text("Pending").tag("Pending")
                                                Text("Accept").tag("Accept")
                                                Text("Declined").tag("Declined")
                                            }
                                            .pickerStyle(SegmentedPickerStyle())
                                        }
                                    } else {
                                        HStack {
                                            Text("Status:").bold()
                                            Spacer()
                                    
                                            Text(suggestions[index].status)
                                                        .foregroundColor(statusColor(for: suggestions[index].status))
                                        }
                                    }
                            
//                            HStack {
//                                Text("Status:").bold()
//                                Spacer()
//                                if suggestions[index].status == "Pending" {
//                                        Picker("Status", selection: $suggestions[index].status) {
//                                            Text("Pending").tag("Pending")
//                                            Text("Accept").tag("Accept")
//                                            Text("Declined").tag("Declined")
//                                        }
//                                        .pickerStyle(SegmentedPickerStyle())
//                                    } else {
//                                        Text(suggestions[index].status)
//                                    }
//                            }//hstack
                            
                            HStack {
                                Text("\(suggestions[index].description)")
                            }
                            
                        }
                        Divider()
                    }
                    
                }
            } //List

            HStack(alignment: .center) {
                Spacer()
                Button(action: {
                    updateOfferStatuses()
                }) {
                    Text("Save status changes")
                }.buttonStyle(.borderedProminent)
                Spacer()
            }
            .onAppear {
                if let ownerID = dbHelper.userProfile?.id {
                    self.isLoading = true
                    self.dbHelper.getInveSuggByOwnerID(ownerID: ownerID) { (suggestions, error) in
                        self.isLoading = false
                        if let error = error {
                            print("Error getting investment suggestions: \(error)")
                        } else if let suggestions = suggestions {
                            self.suggestions = suggestions
                            self.updatedStatuses = suggestions.map { $0.status }
                           // isStatusUpdated = Array(repeating: false, count: suggestions.count)
                            self.isStatusUpdated = suggestions.map { $0.status == "Pending" ? false : true }
                                    
                        }
                    }
                }
            }
            Spacer()
        }
        .alert(isPresented: $isShowingAlert) {
                    Alert(
                        title: Text("Alert Message"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
        .padding(.vertical, 5)
    }

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    // Function to save updated statuses to the database
    func updateOfferStatuses() {
        for (index, suggestion) in suggestions.enumerated() {
            // Check if the status has been updated
            if suggestion.status != updatedStatuses[index] {
                // Update the status in the database
                dbHelper.updateInvestmentStatus(suggestionID: suggestion.id!, newStatus: suggestion.status) { error in
                    if let error = error {
                        print("Error updating status for offer: \(error)")
                    } else {
                        isStatusUpdated[index] = true
                        if suggestion.status == "Accept" { // Check if the status is "Accept"
                            updatePropertyStatus(propertyID: suggestion.projectID, status: "In Progress")
                                            }
                        else if suggestion.status == "Pending" { // Check if the status is "Accept"
                            updatePropertyStatus(propertyID: suggestion.projectID, status: "Released")
                                            }
                        else if suggestion.status == "Declined" { // Check if the status is "Accept"
                            updatePropertyStatus(propertyID: suggestion.projectID, status: "Released")
                                            }
                        // Insert a notification in Firebase
                        let notification = Notifications(
                            id: UUID().uuidString,
                            timestamp: Date(),
                            userID: suggestion.investorID,
                            event: "Project Status Change",
                            details: "Project titled '\(suggestion.projectTitle)' has been changed to \(suggestion.status).",
                            isRead: false,
                            projectID: suggestion.projectID
                        )

                        dbHelper.insertNotification(notification) { notificationSuccess in
                            if notificationSuccess {
                                print("Notification inserted successfully.")
                            } else {
                                print("Error inserting notification.")
                            }
                        }
                        
                        // Set the alert message
                                               alertMessage = "Status updated successfully."
                                               isShowingAlert = true
                    }
                }
            }
        }
    }
    
    // Function to update the property status to "InProgress"
    func updatePropertyStatus(propertyID: String, status: String) {
        // Update the property status to "InProgress" in the database
        dbHelper.updatePropertyStatus(propertyID: propertyID, newStatus: status) { error in
            if let error = error {
                print("Error updating property status to InProgress: \(error)")
            } else {
                print("Property status updated to InProgress.")
            }
        }
    }
    
    func statusColor(for status: String) -> Color {
        switch status {
        case "Pending":
            return .yellow
        case "Accept":
            return .green
        case "Declined":
            return .red
        default:
            return .black
        }
    }

}
