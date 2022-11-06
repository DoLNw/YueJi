//
//  YueJiApp.swift
//  YueJi
//
//  Created by Jcwang on 2022/11/6.
//

import SwiftUI

@main
struct YueJiApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
