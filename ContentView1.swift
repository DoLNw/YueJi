//
//  ContentView.swift
//  Demo (iOS)
//
//  Created by Daniel Saidi on 2022-06-06.
//  Copyright © 2022 Daniel Saidi. All rights reserved.
//

import SwiftUI

struct ContentView1: View {
    var body: some View {
        NavigationView {
            EditorScreen()
                .navigationTitle("RichTextKit")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        MainMenu()
                    }
                }
        }
    }
}

struct ContentView1_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
