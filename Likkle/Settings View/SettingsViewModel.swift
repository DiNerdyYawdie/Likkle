//
//  SettingsViewModel.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 10/3/20.
//

import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    
    let settingsList: [SettingsEntry] = [SettingsEntry(text: "General"), SettingsEntry(text: "About"), SettingsEntry(text: "Privacy Policy"), SettingsEntry(text: "Terms & Conditions")]
}

struct SettingsEntry: Identifiable {
    var id = UUID()
    var text: String
}
