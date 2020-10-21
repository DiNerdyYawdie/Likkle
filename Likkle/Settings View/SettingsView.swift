//
//  SettingsView.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 10/3/20.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.viewModel.settingsList) { settingsEntry in
                    NavigationLink(destination: SettingsDetailView(title: settingsEntry.text)) {
                        Text(settingsEntry.text)
                    }
                }
            }.navigationTitle(Text("Settings"))
            .accentColor(Color(UIColor.systemGreen))
            .listStyle(GroupedListStyle())
        }
    }
}


