//
//  ContentView.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 10/3/20.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection,
                content:  {
                    SearchHomeView(viewModel: SearchHomeViewModel())
                        .tabItem {
                            VStack {
                                Image(systemName: "magnifyingglass")
                                
                                Text("Search")
                            }
                        }
                        .tag(0)
                        .environment(\.managedObjectContext, viewContext)
                    
                    ProfileView(viewModel: ProfileViewModel())
                        .tabItem {
                            VStack {
                                Image(systemName: "person.circle.fill")
                                
                                Text("Profile")
                            }
                            .tag(1)
                            .environment(\.managedObjectContext, viewContext)
                        }
                    
                    SettingsView(viewModel: SettingsViewModel())
                        .tabItem {
                            VStack {
                                Image(systemName: "gear")
                                Text("Settings")
                            }
                        }
                        .tag(2)
                })
            .accentColor(Color(UIColor.systemGreen))
    }
}
