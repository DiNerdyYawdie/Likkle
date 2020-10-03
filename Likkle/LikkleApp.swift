//
//  LikkleApp.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 10/3/20.
//

import SwiftUI

@main
struct LikkleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
