//
//  ViewProjects_Investor.swift
//  UpgradeUpsell
//
//  Created by Golnaz Chehrazi on 2023-10-10.
//

import SwiftUI

struct ProjectsList_InvestorView: View {
    @EnvironmentObject var dbHelper: FirestoreController
    @EnvironmentObject var authHelper: FireAuthController
    @State private var prjList: [RenovateProject] = []
    @State private var filteredProjects: [RenovateProject] = []
    @State private var isLoading: Bool = false
    @State private var searchText = ""
    
    var body: some View {
        VStack{
            Text("List of Properties").bold().font(.title).foregroundColor(.brown)
            SearchBar(text: $searchText, placeholder: "Search by title")
            List(self.filteredProjects) { prj in
                NavigationLink(destination: MakeOffers_InvestorView(project: prj).environmentObject(dbHelper).environmentObject(authHelper)) {
                    ProjectListItemView(project: prj)
                }
            }
        }
        //.navigationTitle("Renovation Projects")
        .onAppear {
            // Fetch investment suggestions when the view appears.
            if let role = dbHelper.userProfile?.role {
                if(role == "Investor"){
                    self.isLoading = true
                    self.dbHelper.listenForRenovateProjects() { (renovateProjects, error) in
                        self.isLoading = false
                        if let error = error {
#if DEBUG
                            print("Error getting investment suggestions: \(error)")
                            #endif
                        } else if let projectList = renovateProjects {
                            self.prjList = projectList
                        }
                    }
                }
            }
        }
        .onChange(of: searchText) { _ in
            filterProjects()
        }
    }
    
    private func loadProjects(){
        if let role = dbHelper.userProfile?.role {
            if(role == "Investor"){
                self.isLoading = true
                self.dbHelper.listenForRenovateProjects() { (renovateProjects, error) in
                    self.isLoading = false
                    if let error = error {
#if DEBUG
                        print("Error getting investment suggestions: \(error)")
                        #endif
                    } else if let projectList = renovateProjects {
                        self.prjList = projectList
                        filterProjects()
                        
                    }
                }
            }
        }
    }
    
    private func filterProjects(){
        if searchText.isEmpty{
            self.filteredProjects = self.prjList
        }
        else{
            self.filteredProjects = self.prjList.filter {
                $0.title.localizedCaseInsensitiveContains(searchText.lowercased())
            }
        }
    }
    
}

struct ProjectListItemView: View {
    let project: RenovateProject

    var body: some View {
        VStack(alignment: .leading) {
            Text(project.category)
            Text(project.title)
                .font(.headline)
            Text(project.location)
                .font(.subheadline)
            //Text("Estimated Fund:$\(project.investmentNeeded)")
        
            // Add any other project details you want to display
        }
    }
}

//struct ProjectDetailView: View {
//    let project: RenovateProject
//
//    var body: some View {
//        VStack {
//            Text(project.title)
//                .font(.title)
//            Text(project.description)
//                .font(.body)
//            // Add more project details and UI components as needed
//        }
//        .navigationTitle(project.title)
//    }
//}

