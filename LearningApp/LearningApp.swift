//
//  LearningApp.swift
//  LearningApp
//
//  Created by Keegan Pangowish on 2021-12-26.
//

import SwiftUI
import Firebase

@main
struct LearningApp: App {
    
    init() {
        FirebaseApp.configure()
        
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(ContentModel())
        }
    }
}
