//
//  NotificationView.swift
//  UpgradeUpsell
//
//  Created by zahra SHAHIN on 2023-10-16.
//
//

import SwiftUI
import Firebase

struct NotificationView: View {
    @EnvironmentObject var dbHelper: FirestoreController
    @State private var notifications: [Notifications] = []
    @State private var showingDeleteConfirmationAlert = false
    
    var body: some View {
        VStack {
            Text("My Notifications").bold().font(.title).foregroundColor(.brown)
            HStack{
                Spacer()
                Button(action: {
                    //deleteAllNotifications(userID: self.dbHelper.userProfile?.id)
                    showingDeleteConfirmationAlert = true
                }) {
                    Text("Delete All")
                }
                .alert(isPresented: $showingDeleteConfirmationAlert) {
                                    Alert(
                                        title: Text("Delete All Notifications"),
                                        message: Text("Are you sure you want to delete all notifications?"),
                                        primaryButton: .destructive(Text("Delete")) {
                                            deleteAllNotifications(userID: self.dbHelper.userProfile?.id)
                                        },
                                        secondaryButton: .cancel()
                                    )
                                }
            }.padding(.trailing, 20)
            ScrollView{
                ForEach(notifications, id: \.id) { notification in
                    NavigationLink(destination: NotificationDetailView(notification: notification).environmentObject(self.dbHelper)) {
                        HStack {
                            Image(systemName: notification.isRead ? "eye.fill" : "eye.slash.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding(.horizontal, 5)
                                .foregroundColor(.black)
                            Text(notification.event).foregroundColor(.black)//.padding()
                            Spacer()
                        }
                    }
                }
                .onDelete(perform: deleteNotifications)
            }
            .onAppear {
                if let userID = self.dbHelper.userProfile?.id {
                    dbHelper.getNotifications(forUserID: userID) { notifications, error in
                        if let notifications = notifications {
                            self.notifications = notifications
                        } else if let error = error {
                            // Handle the error
#if DEBUG
                            print("Error fetching notifications: \(error.localizedDescription)")
                            #endif
                        }
                    }
                }
            }
           Spacer()
           // .navigationBarTitle("Notifications")
           // .padding()
        } //VStack
    }

    private func deleteNotifications(at offsets: IndexSet) {
        for offset in offsets {
            let notification = notifications[offset]
            dbHelper.deleteNotification(notification) { success in
                if success {
                    notifications.remove(at: offset)
                } else {
#if DEBUG
                    print("Error deleting notification.")
                    #endif
                }
            }
        }
    }

    private func deleteAllNotifications(userID: String?) {
        if let userID = userID {
            dbHelper.deleteAllNotifications(forUserID: userID) { success in
                if success {
                    notifications.removeAll()
                } else {
#if DEBUG
                    print("Error deleting notifications.")
#endif
                }
            }
        } else {
#if DEBUG
            print("User ID is nil. Unable to delete notifications.")
            #endif
        }
    }
}





//import SwiftUI
//import Firebase


//struct NotificationView: View {
//    @EnvironmentObject var dbHelper: FirestoreController
//    @State private var notifications: [Notifications] = []
////    @State private var isDetailViewPresented = false
//
//    var body: some View {
//        VStack {
//                        Text("Notifications").bold().font(.title).foregroundColor(.brown)
//
//            List {
//                ForEach(notifications, id: \.id) { notification in
//                    NavigationLink(    destination: NotificationDetailView( notification: notification),
//                        label: {
//                            HStack {
//                                Image(systemName: notification.isRead ? "eye.fill" : "eye.slash.fill")
//                                    .resizable()
//                                    .frame(width: 30, height: 30)
//                                    .padding(.trailing, 10)
//                                Text(notification.event)
//                            }
//                        }
//                    )
//                }
//                .onDelete(perform: deleteNotifications)
//            }
//            .onAppear {
//                if let userID = self.dbHelper.userProfile?.id {
//                    dbHelper.getNotifications(forUserID: userID) { notifications, error in
//                        if let notifications = notifications {
//                            self.notifications = notifications
//                        } else if let error = error {
//                            // Handle the error
//                            print("Error fetching notifications: \(error.localizedDescription)")
//                        }
//                    }
//                }
//            }
////            .navigationBarTitle("Notifications")
//            .padding()
//        }
//    }
//
//    private func deleteNotifications(at offsets: IndexSet) {
//        for offset in offsets {
//            let notification = notifications[offset]
//            dbHelper.deleteNotification(notification) { success in
//                if success {
////                    print("Notification deleted successfully.")
//                    notifications.remove(at: offset)
//                } else {
//                    print("Error deleting notification.")
//                }
//            }
//        }
//    }
//}

