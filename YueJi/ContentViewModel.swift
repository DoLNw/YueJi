//
//  ContentViewModel.swift
//  YueJi
//
//  Created by Jcwang on 2022/11/30.
//

import SwiftUI

//extension ContentView {
//    @MainActor class ViewModel: ObservableObject {
//    }
//}

@MainActor class ContentViewModel: ObservableObject {
    @Published private(set) var backgroundImageData: Data?
    
    let savePath = FileManager.documentsDirectory.appendingPathExtension(StaticProperties.FILEMANAGER_BACKGROUNDIMAGE)
    
    init() {
        do {
            self.backgroundImageData = try Data(contentsOf: savePath)
        } catch {
            self.backgroundImageData = nil
        }
    }
    
    func setBackgroundImage(data: Data?) {
        self.backgroundImageData = data
        
        do {
            if let _ = self.backgroundImageData {
                try self.backgroundImageData?.write(to: savePath, options: [.atomic, .completeFileProtection])
            } else {
                try FileManager.default.removeItem(at: savePath)
            }
            
        } catch {
            print("opeartion failed.")
        }
    }
}


extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

