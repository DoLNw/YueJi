//
//  YueJiApp.swift
//  YueJi
//
//  Created by Jcwang on 2022/11/6.
//

import SwiftUI
import UIKit

// no changes in your AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
//        TagAttributeTransformer.register()
        
        return true
    }
}

@main
struct YueJiApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var viewModel = ContentViewModel()
    
    // inject into SwiftUI life-cycle via adaptor !!!
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
//        setupPreUserdefaults()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(viewModel)
        }
    }
}
//
//private extension YueJiApp {
//    func setupPreUserdefaults() {
//        if let _ = UserDefaults.standard.array(forKey: StaticProperties.TAGS) {
//
//        } else {
//            let tags = ["全部", "日记", "1", "标s签2", "标签3", "标签4", "标签asdasdas5", "标签6", "标签asdasd7", "标签8", "添加"]
//            UserDefaults.standard.set(tags, forKey: StaticProperties.TAGS)
//        }
//    }
//}
