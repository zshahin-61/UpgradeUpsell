//
//  FirestoreController.swift
//  UpgradeUpsell
//
//  Created by Golnaz Chehrazi on 2023-09-20.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreController: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var userPrefrences: Prefrences?
    @Published var myPropertyList: [RenovateProject] = [RenovateProject]()
    @Published var userProperty: RenovateProject?

    private let db: Firestore
    private static var shared: FirestoreController?
    
    /// COLLECTIONS LIST  /////////////
    private let COLLECTION_UsersProfile = "UsersProfile"
    private let COLLECTION_Prefrences = "Prefrences"
    private let COLLECTION_Notifications = "Notifications"
    private let COLLECTION_RenovateProject = "RenovateProject"
    private let COLLECTION_InvestmentSuggestion = "InvestmentSuggestions"
    private let COLLECTION_RealtorSuggestion = "RealtorSuggestions"
    private let COLLECTION_Investment = "Investment"
    private let COLLECTION_ProfitSharing = "ProfitSharing"
    private let COLLECTION_Financial = "Financial"
    private let COLLECTION_ChatMessages = "ChatMessage"
    /// END COLLECTIONS LIST //////
    
    /// Fields //////
    private let FIELD_UP_userID = "userID"
    private let FIELD_UP_username = "username"
    private let FIELD_UP_fullName = "fullName"
    private let FIELD_UP_role = "role"
    private let FIELD_UP_email = "email"
    private let FIELD_UP_address = "address"
    private let FIELD_UP_contactNumber = "contactNumber"
    private let FIELD_UP_authenticationToken = "authenticationToken"
    private let FIELD_UP_preferences = "preferences"
    private let FIELD_UP_userBio = "userBio"
    private let FIELD_UP_profilePicture = "profilePicture"
    private let FIELD_UP_notifications = "notifications"
    private let FIELD_UP_favoriteProjects = "favoriteProjects"
    //////
    private let FIELD_theme = "theme"
    private let FIELD_fontSize = "fontSize"
    private let FIELD_language = "language"
    private let FIELD_emailNotif = "emailNotif"
    private let FIELD_pushNotif = "pushNotif"
    ///
    
    //////
    private let FIELD_projectID = "projectID"
    private let FIELD_description = "description"
    private let FIELD_location = "location"
    private let FIELD_lng = "lng"
    private let FIELD_lat = "lat"
    private let FIELD_images = "images"
    private let FIELD_ownerID = "ownerID"
    private let FIELD_category = "category"
    private let FIELD_investmentNeeded = "investmentNeeded"
    private let FIELD_InvestmentSuggestions = "InvestmentSuggestions"
    private let FIELD_selctedInvestmentSuggestionID = "selctedInvestmentSuggestionID"
    private let FIELD_status = "status"
    private let FIELD_startDate = "startDate"
    private let FIELD_endDate = "endDate"
    private let FIELD_contactInfo = "contactInfo"
    private let FIELD_createdDate = "createdDate"
    private let FIELD_updatedDate = "updatedDate"
    private let FIELD_RealtorID = "RealtorID"
    private let FIELD_buySuggestions = "buySuggestions"
    private let FIELD_selectedBuySuggestionID = "selectedBuySuggestionID"
    //////
    private let FIELD_investmentSuggestionID = "investmentSuggestionID"
    private let FIELD_investorID = "investorID"
    private let FIELD_amountOffered = "amountOffered"
    private let FIELD_durationWeeks = "durationWeeks"
    //////
    private let FIELD_buySuggestionID = "buySuggestionID"
    private let FIELD_realtorID = "realtorID"
    //////
    private let FIELD_investmentID = "investmentID"
    private let FIELD_amountInvested = "amountInvested"
    private let FIELD_investmentDate = "investmentDate"
    //////
    
    private let FIELD_NOTIFICATIONID = "notifID"
    private let FIELD_TIMESTAMP = "timestamp"
    private let FIELD_USERID = "userID"
    private let FIELD_EVENT = "event"
    private let FIELD_DETAILS = "details"
    private let FIELD_ISREAD = "isRead"
   
    
    //////
    
    private var loggedInUserID: String = ""

    init(db: Firestore) {
        self.db = db
    }
    
    static func getInstance() -> FirestoreController {
        if self.shared == nil {
            self.shared = FirestoreController(db: Firestore.firestore())
        }
        return self.shared!
    }
    
    // MARK: User profile functions
    func getUserProfile(withCompletion completion: @escaping (Bool) -> Void) {
        self.loggedInUserID = UserDefaults.standard.string(forKey: "KEY_ID") ?? ""
        print("\(self.loggedInUserID)")
        
        let document = db.collection(COLLECTION_UsersProfile).document(self.loggedInUserID)
        
        document.addSnapshotListener { (documentSnapshot, error) in
            if let document = documentSnapshot, document.exists {
                do {
                    if let userProfile = try document.data(as: UserProfile?.self) {
                        self.userProfile = userProfile
                        DispatchQueue.main.async {
                            completion(true)
                        }
                    }
                } catch {
                    print("Error decoding user profile data: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        //self.isLoginSuccessful = false
                        completion(false)
                    }
                }
            } else {
                print("Document does not exist")
                DispatchQueue.main.async {
                    //self.isLoginSuccessful = false
                    completion(false)
                }
            }
        }
    }
    
    func getUserProfilebyUserID(userID: String, withCompletion completion: @escaping (UserProfile?, Error?) -> Void) {
        let document = db.collection(COLLECTION_UsersProfile).document(userID)

        document.addSnapshotListener { (documentSnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let document = documentSnapshot else {
                let notFoundError = NSError(domain: "YourAppErrorDomain", code: 404, userInfo: nil)
                completion(nil, notFoundError)
                return
            }

            do {
                let userProfile = try document.data(as: UserProfile.self)
                DispatchQueue.main.async {
                    completion(userProfile, nil)
                }
                
            } catch {
                print("Error decoding user profile data: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }

    func createUserProfile(newUser: UserProfile){
        print(#function, "Inserting profile Info")
        self.loggedInUserID = newUser.id!
        do{
            let docRef = db.collection(COLLECTION_UsersProfile).document(newUser.id!)
            try docRef.setData([FIELD_UP_email: newUser.email,
                             FIELD_UP_fullName: newUser.fullName,
                                FIELD_UP_role : newUser.role,
                              FIELD_UP_userBio: newUser.userBio,
                       FIELD_UP_profilePicture: newUser.profilePicture,
                              FIELD_UP_address: newUser.address,
                        FIELD_UP_contactNumber: newUser.contactNumber
                               ]){ error in
            }
            self.userProfile = newUser
            print(#function, "user \(newUser.fullName) successfully added to database")
        }catch let err as NSError{
            print(#function, "Unable to add user to database : \(err)")
        }//do..catch
        
    }
    
    func updateUserProfile(userToUpdate : UserProfile){
        print(#function, "Updating user profile \(userToUpdate.fullName), ID : \(userToUpdate.id)")
        
        
        //get the email address of currently logged in user
        self.loggedInUserID = UserDefaults.standard.string(forKey: "KEY_ID") ?? ""
        
        if (self.loggedInUserID.isEmpty){
            print(#function, "Logged in user's ID address not available. Can't update User Profile")
        }
        else{
            do{
                try self.db
                    .collection(COLLECTION_UsersProfile)
                    .document(userToUpdate.id!)
                    .updateData([FIELD_UP_fullName : userToUpdate.fullName,
                            FIELD_UP_contactNumber : userToUpdate.contactNumber,
                                  FIELD_UP_address : userToUpdate.address,
                                  FIELD_UP_userBio : userToUpdate.userBio,
                            FIELD_UP_profilePicture: userToUpdate.profilePicture
                                ]){ error in
                        
                        if let err = error {
                            print(#function, "Unable to update user profile in database : \(err)")
                        }else{
                            print(#function, "User profile \(userToUpdate.fullName) successfully updated in database")
                        }
                    }
            }catch let err as NSError{
                print(#function, "Unable to update user profile in database : \(err)")
            }//catch
        }//else
    }
    
    func deleteUser(withCompletion completion: @escaping (Bool) -> Void) {
        //get the email address of currently logged in user
        self.loggedInUserID = UserDefaults.standard.string(forKey: "KEY_ID") ?? ""
        
        if (self.loggedInUserID.isEmpty){
            print(#function, "Logged in user's ID address not available. Can't delete USER")
            DispatchQueue.main.async {
                completion(false)
            }
        }
        else{
            do{
                try self.db
                    .collection(COLLECTION_UsersProfile)
                    .document(self.loggedInUserID)
                    .delete{ error in
                        if let err = error {
                            print(#function, "Unable to delete user from database : \(err)")
                            DispatchQueue.main.async {
                                completion(false)
                            }
                        }else{
                            print(#function, "user \(self.loggedInUserID) successfully deleted from database")
                            DispatchQueue.main.async {
                                completion(true)
                            }
                        }
                    }
            }catch let err as NSError{
                print(#function, "Unable to delete user from database : \(err)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    
    // Prefrences Collection Functions
    func saveUserPrefrences(newPref: Prefrences, completion: @escaping (Prefrences?, Error?) -> Void) {
        print(#function, "Inserting preferences Info")
        
        let docRef = db.collection(COLLECTION_Prefrences).document(newPref.id!)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Document exists, update the existing document
                do {
                    try docRef.updateData([
                        self.FIELD_theme: newPref.theme,
                        self.FIELD_fontSize: newPref.fontSize,
                        self.FIELD_language: newPref.language,
                        self.FIELD_pushNotif: newPref.pushNotif,
                        self.FIELD_emailNotif: newPref.emailNotif
                    ]) { error in
                        if let error = error {
                            print(#function, "Error updating document: \(error)")
                            completion(nil, error)
                        } else {
                            print(#function, "Document updated successfully")
                            completion(newPref, nil)
                        }
                    }
                } catch let err as NSError {
                    print(#function, "Unable to update document: \(err)")
                    completion(nil, err)
                }
            } else {
                // Document doesn't exist, insert a new document
                do {
                    try docRef.setData([
                        self.FIELD_theme: newPref.theme,
                        self.FIELD_fontSize: newPref.fontSize,
                        self.FIELD_language: newPref.language,
                        self.FIELD_pushNotif: newPref.pushNotif,
                        self.FIELD_emailNotif: newPref.emailNotif
                    ]) { error in
                        if let error = error {
                            print(#function, "Error adding document: \(error)")
                            completion(nil, error)
                        } else {
                            print(#function, "Document added successfully")
                            completion(newPref, nil)
                        }
                    }
                } catch let err as NSError {
                    print(#function, "Unable to add document: \(err)")
                    completion(nil, err)
                }
            }
        }
    }
        
    func getPreferencesFromFirestore(forUserID userID: String, completion: @escaping (Prefrences?, Error?) -> Void) {
            // TODO: Retrieve preferences from Firestore for the given userID
            // Example:
             let preferencesRef = db.collection(COLLECTION_Prefrences).document(userID)
             preferencesRef.getDocument { document, error in
                 if let error = error {
                     completion(nil, error)
                 } else if let document = document, document.exists {
                     do {
                         let preferences = try document.data(as: Prefrences.self)
                         completion(preferences, nil)
                     } catch {
                         completion(nil, error)
                     }
                 } else {
                     completion(nil, nil) // Document does not exist
                 }
             }
            
//            // Simulate a completion with default preferences for demonstration purposes (remove in production)
//            let defaultPreferences = Prefrences()
//            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//                completion(defaultPreferences, nil)
//            }
        }
    
    // MARK: renovateProjects Collection Functions
    func addProperty(_ property: RenovateProject, userID: String, completion: @escaping (Bool) -> Void) {
        var propertyToSave = property
        print("userrrrr",COLLECTION_UsersProfile)
        propertyToSave.id = nil // Clear the ID to generate a new one
        
        do {
            let _ = try self.db
//                .collection(COLLECTION_UsersProfile)
//                .document(userID)
                .collection(COLLECTION_RenovateProject)
                .addDocument(from: propertyToSave) { error in
                    if let error = error {
                        print("Error adding property to Firestore: \(error)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
        } catch {
            print("Error adding property to Firestore: \(error)")
            completion(false)
        }
    }

    func updateProperty(_ property: RenovateProject, completion: @escaping (Bool) -> Void) {
        guard let propertyID = property.id else {
            print("Property ID is missing.>>>>>>>>>>>>>>>>>>>")
            completion(false)
            return
        }

        do {
            let documentReference = try self.db
                .collection(COLLECTION_RenovateProject)
                .document(propertyID)

            documentReference.updateData([
                "title": property.title,
                "description": property.description,
                "location": property.location,
                "lng": property.lng,
                "lat": property.lat,
                "images" : property.images,
                "ownerID": property.ownerID,
                "category": property.category,
                "investmentNeeded": property.investmentNeeded,
                "selectedInvestmentSuggestionID": property.selectedInvestmentSuggestionID,
                "status": property.status,
                "startDate": property.startDate,
                "endDate": property.endDate,
                "numberOfBedrooms": property.numberOfBedrooms,
                "numberOfBathrooms": property.numberOfBedrooms,
                "propertyType": property.propertyType,
                "squareFootage": property.squareFootage,
                "isFurnished": property.isFurnished,
                "createdDate": property.createdDate,
                "updatedDate": property.updatedDate,
                "favoriteCount": property.favoriteCount,
                "realtorID": property.realtorID
                
            ]) { error in
                if let error = error {
                    print("Error updating property in Firestore: \(error)")
                    completion(false)
                } else {
                    print("Property updated successfully.")
                    completion(true)
                }
            }
        } catch {
            print("Error updating property in Firestore: \(error)")
            completion(false)
        }
    }
    
    func deleteProperty(_ property: RenovateProject, completion: @escaping (Bool) -> Void) {
        guard let propertyID = property.id else {
            // The property doesn't have an ID, so it can't be deleted.
            completion(false)
            return
        }

        do {
            let documentReference = try self.db
                .collection(COLLECTION_RenovateProject)
                .document(propertyID)

            documentReference.delete { error in
                if let error = error {
                    print("Error deleting property in Firestore: \(error)")
                    completion(false)
                } else {
                    print("Property deleted successfully.")
                    completion(true)
                }
            }
        } catch {
            print("Error deleting property in Firestore: \(error)")
            completion(false)
        }
    }

    
    func updateProjectStatus(_ property: RenovateProject ,completion: @escaping (Bool) -> Void) {

        
        if let projectID = property.id {
            let projectRef = db .collection(COLLECTION_RenovateProject)
                .document(projectID)
            
            projectRef.updateData(["status": "deleted"]) { error in
                if let error = error {
                    print("Error updating project status: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Project status updated successfully.")
                    completion(true)
                }
            }
        } else {
            completion(false)
        }
    }
    
    func getUserProjectsAll(userID: String, completion: @escaping ([RenovateProject]?, Error?) -> Void) {
        self.db.collection(COLLECTION_RenovateProject)
            .whereField("ownerID", isEqualTo: userID)

            .getDocuments { querySnapshot, error in
                if let error = error {
                    completion(nil, error)
                } else {
                    var projects = [RenovateProject]()
                    for document in querySnapshot!.documents {
                        if let project = try? document.data(as: RenovateProject.self) {
                            projects.append(project)
                        }
                    }
                    completion(projects, nil)
                }
            }
    }
    
    func getUserProjectsWithStatus(userID: String, completion: @escaping ([RenovateProject]?, Error?) -> Void) {
        self.db.collection(COLLECTION_RenovateProject)
            .whereField("ownerID", isEqualTo: userID)
            .whereField("status", isNotEqualTo: "deleted")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    completion(nil, error)
                } else {
                    var projects = [RenovateProject]()
                    for document in querySnapshot!.documents {
                        if let project = try? document.data(as: RenovateProject.self) {
                            projects.append(project)
                        }
                    }
                    completion(projects, nil)
                }
            }
    }
    
    func getRenovateProjectByID(_ projectID: String, completion: @escaping (RenovateProject?, Error?) -> Void) {
        db.collection(COLLECTION_RenovateProject).document(projectID).getDocument { document, error in
            if let error = error {
                completion(nil, error)
            } else if let document = document, document.exists {
                do {
                    let project = try document.data(as: RenovateProject.self)
                    completion(project, nil)
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, nil) // Document does not exist
            }
        }
    }
    
    func getRenovateProjectByStatus(status: String, completion: @escaping ([RenovateProject]?, Error?) -> Void) {
        self.db.collection(COLLECTION_RenovateProject)
            .whereField("status", isEqualTo: status)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    completion(nil, error)
                } else {
                    var projects = [RenovateProject]()
                    for document in querySnapshot!.documents {
                        if let project = try? document.data(as: RenovateProject.self) {
                            projects.append(project)
                        }
                    }
                    completion(projects, nil)
                }
            }
    }
    
    // MARK: Notification

    func getNotifications(forUserID userID: String, completion: @escaping ([Notifications]?, Error?) -> Void) {
        self.db.collection("COLLECTION_Notifications")
            .whereField("userID", isEqualTo: userID)
            .order(by: "timestamp", descending: true)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    completion(nil, error)
                } else {
                    var notifications = [Notifications]()
                    for document in querySnapshot!.documents {
                        if let notification = try? document.data(as: Notifications.self) {
                            notifications.append(notification)
                        }
                    }
                    completion(notifications, nil)
                }
            }
    }



    // MARK: functions for Collection investment Sugesstions
    func addInvestmentSuggestion(_ suggestion: InvestmentSuggestion, completion: @escaping (Error?) -> Void) {
        do {
            try db.collection(COLLECTION_InvestmentSuggestion).addDocument(from: suggestion) { error in
                if let error = error {
                    print("Error adding investment suggestion to Firestore: \(error)")
                    completion(error)
                } else {
                    print("Suggestion added successfully")
                    completion(nil) // Signal success by passing nil for the error
                }
            }
        } catch {
            print("Error preparing data for Firestore: \(error)")
            completion(error) // Pass the error to the completion handler
        }
    }
    
    func updateInvestmentSuggestion(_ suggestion: InvestmentSuggestion) {
        do {
            try self.db.collection(COLLECTION_InvestmentSuggestion).document(suggestion.id!).setData(from: suggestion)
        } catch {
            print("Error updating investment suggestion in Firestore: \(error)")
        }
    }
    
    func deleteInvestmentSuggestion(_ suggestion: InvestmentSuggestion) {
        self.db.collection(COLLECTION_InvestmentSuggestion).document(suggestion.id!).delete { error in
            if let error = error {
                print("Error deleting investment suggestion from Firestore: \(error)")
            } else {
                print("Investment suggestion deleted successfully")
            }
        }
    }
    
    func getInvestmentSuggestions(completion: @escaping ([InvestmentSuggestion]?, Error?) -> Void) {
        self.db.collection(COLLECTION_InvestmentSuggestion).getDocuments { querySnapshot, error in
            if let error = error {
                completion(nil, error)
            } else {
                var suggestions = [InvestmentSuggestion]()
                for document in querySnapshot!.documents {
                    if let suggestion = try? document.data(as: InvestmentSuggestion.self) {
                        suggestions.append(suggestion)
                    }
                }
                completion(suggestions, nil)
            }
        }
    }
    
    func getInvestmentSuggestionsbyInvestorID(forInvestorID investorID: String, completion: @escaping ([InvestmentSuggestion]?, Error?) -> Void) {
        self.db.collection(COLLECTION_InvestmentSuggestion)
            .whereField("investorID", isEqualTo: investorID)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    completion(nil, error)
                } else {
                    var suggestions = [InvestmentSuggestion]()
                    for document in querySnapshot!.documents {
                        if let suggestion = try? document.data(as: InvestmentSuggestion.self) {
                            suggestions.append(suggestion)
                        }
                    }
                    completion(suggestions, nil)
                }
            }
    }
    
    func getInvestmentSuggestionsbyProjectID(forProjectID projectID: String, completion: @escaping ([InvestmentSuggestion]?, Error?) -> Void) {
        self.db.collection(COLLECTION_InvestmentSuggestion)
            .whereField("projectID", isEqualTo: projectID)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    completion(nil, error)
                } else {
                    var suggestions = [InvestmentSuggestion]()
                    for document in querySnapshot!.documents {
                        if let suggestion = try? document.data(as: InvestmentSuggestion.self) {
                            suggestions.append(suggestion)
                        }
                    }
                    completion(suggestions, nil)
                }
            }
    }
    
    func getInveSuggByOwnerID(ownerID: String, completion: @escaping ([InvestmentSuggestion]?, Error?) -> Void) {

        // Define a reference to the "InvestmentSuggestions" collection.
        let suggestionsRef = db.collection(COLLECTION_InvestmentSuggestion)

        // Create a query to filter suggestions by the owner's ID.
        let query = suggestionsRef.whereField("ownerID", isEqualTo: ownerID)

        // Perform the query.
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                // Initialize an array to store the retrieved suggestions.
                var suggestions: [InvestmentSuggestion] = []

                // Loop through the documents in the query result.
                for document in querySnapshot!.documents {
                    // Deserialize the document data into an InvestmentSuggestion object.
                    if let suggestion = try? document.data(as: InvestmentSuggestion.self) {
                        suggestions.append(suggestion)
                    }
                }

                // Call the completion handler with the retrieved suggestions.
                completion(suggestions, nil)
            }
        }
    }
    
}

