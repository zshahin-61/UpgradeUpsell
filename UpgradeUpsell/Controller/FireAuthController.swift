//
//  FireAuthController.swift
//  UpgradeUpsell
//
//  Created by Golnaz Chehrazi on 2023-09-20.
//

import Foundation
import FirebaseAuth

class FireAuthController : ObservableObject{
    
    //using inbuilt User object provided by FirebaseAuth
    @Published var user : User?{
        didSet{
            objectWillChange.send()
        }
    }
    
    @Published var isLoginSuccessful = false
    
    func listenToAuthState(){
        Auth.auth().addStateDidChangeListener{ [weak self] _, user in
            guard let self = self else{
                //no change in user's auth state
                return
            }
            
            //user's auth state has changed ; update the user object
            self.user = user
        }
    }
   
    func signUp(email: String, password: String, withCompletion completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print(#function, "Error while signing up user: \(error)")
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }

            print(#function, "Successfully created user account")

            self.user = authResult?.user
            // Save the email in UserDefaults
            UserDefaults.standard.set(self.user?.email, forKey: "KEY_ID")

            DispatchQueue.main.async {
                completion(true, nil)
            }
        }
    }

    
    
//    func signUp(email: String, password : String, withCompletion completion: @escaping (Bool) -> Void){
//        Auth.auth().createUser(withEmail : email, password: password){ authResult, error in
//            
//            guard let result = authResult else{
//                if let error = error{
//                    print(#function, "Error while signing up user : \(error)")
//                }
//                return
//            }
//            
//            print(#function, "AuthResult : \(result)")
//            
//            switch(authResult){
//            case .none:
//                print(#function, "Unable to create account")
//                DispatchQueue.main.async {
//                    self.isLoginSuccessful = false
//                    completion(self.isLoginSuccessful)
//                }
//            case .some(_):
//                print(#function, "Successfully created user account")
//                
//                self.user = authResult?.user
//                //save the email in the UserDefaults
//                UserDefaults.standard.set(self.user?.email, forKey: "KEY_ID")
//                
//                DispatchQueue.main.async {
//                    self.isLoginSuccessful = true
//                    completion(self.isLoginSuccessful)
//                }
//            }
//            
//        }
//        
//    }
    
//    func signIn(email: String, password : String, withCompletion completion: @escaping (Bool) -> Void){
//
//        Auth.auth().signIn(withEmail: email, password: password){authResult, error in
//            guard let result = authResult else{
//                print(#function, "Error while signing in user : \(error)")
//                return
//            }
//
//            print(#function, "AuthResult : \(result)")
//
//            switch(authResult){
//            case .none:
//                print(#function, "Unable to find user account")
//
//                DispatchQueue.main.async {
//                    self.isLoginSuccessful = false
//                    completion(self.isLoginSuccessful)
//                }
//
//            case .some(_):
//                print(#function, "Login Successful")
//
//                self.user = authResult?.user
//                //save the email in the UserDefaults
//                UserDefaults.standard.set(self.user?.uid, forKey: "KEY_ID")
//
//                print(#function, "user email : \(self.user?.email)")
//                print(#function, "user displayName : \(self.user?.displayName)")
//                print(#function, "user isEmailVerified : \(self.user?.isEmailVerified)")
//                print(#function, "user phoneNumber : \(self.user?.phoneNumber)")
//
//                DispatchQueue.main.async {
//                    self.isLoginSuccessful = true
//                    completion(self.isLoginSuccessful)
//                }
//            }
//        }
//
//    }
    
    func signIn(email: String, password: String, withCompletion completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print(#function, "Error while signing in user: \(error)")
                DispatchQueue.main.async {
                    self.isLoginSuccessful = false
                    completion(false)
                }
            } else if let user = authResult?.user {
                print(#function, "Login Successful")
                // Save the email in UserDefaults
                UserDefaults.standard.set(user.uid, forKey: "KEY_ID")
                
                print(#function, "user email: \(user.email ?? "N/A")")
                print(#function, "user displayName: \(user.displayName ?? "N/A")")
                print(#function, "user isEmailVerified: \(user.isEmailVerified)")
                print(#function, "user phoneNumber: \(user.phoneNumber ?? "N/A")")
                
                DispatchQueue.main.async {
                    self.isLoginSuccessful = true
                    completion(true)
                }
            }
        }
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
        }catch let err as NSError{
            print(#function, "Unable to sign out : \(err)")
        }
    }
    
    func deleteAccountFromAuth(withCompletion completion: @escaping (Bool) -> Void) {
        if let currentUser = Auth.auth().currentUser {
            currentUser.delete { error in
                if let error = error {
                    print("Error deleting user account from Firebase Authentication: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(false)
                    }
                } else {
                    print("User account deleted from Firebase Authentication successfully.")
                    DispatchQueue.main.async {
                        completion(true)
                    }
                }
            }
        }
    }

//    func reauthenticateUser(currentPassword: String, completion: @escaping (Error?) -> Void) {
//        let user = Auth.auth().currentUser
//        guard let user = user, let email = user.email else {
//            // Handle the case where the user is not authenticated or doesn't have an email
//            return
//        }
//
//        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
//
//        user.reauthenticate(with: credential) { result, error in
//            completion(error)
//        }
//    }

    
    func changePassword(newPassword: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            // Handle the case where the user is not authenticated.
            return
        }

        // Call the updatePassword method to change the password.
        user.updatePassword(to: newPassword) { error in
            if let error = error {
                // Handle the error
                completion(error)
            } else {
                // Password updated successfully.
                completion(nil)
            }
        }
    }
    
    func reauthenticateUser(email: String, currentPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            // Handle the case where there is no current user
            completion(.failure(NSError(domain: "Upgrade&Upsell", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])))
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)

        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                // Handle reauthentication error
                completion(.failure(error))
            } else {
                // User has been reauthenticated
                completion(.success(()))
            }
        }
    }
    
    func updateUserEmail(to newEmail: String, completion: @escaping (Error?) -> Void) {
        if let user = Auth.auth().currentUser {
            user.updateEmail(to: newEmail) { error in
                completion(error)
            }
        } else {
            // Handle the case where there is no current user
            let noUserError = NSError(domain: "Upgrade&Upsell", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
            completion(noUserError)
        }
    }
}

