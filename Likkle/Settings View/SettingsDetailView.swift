//
//  SettingsDetailView.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 10/3/20.
//

import SwiftUI

struct SettingsDetailView: View {
    
    var title: String
    
    var body: some View {
        VStack {
            TextEditor(text: .constant("Some Info about \(title)"))
                .font(.body)
                .padding()
        }
        .navigationTitle(Text(title))
    }
}
