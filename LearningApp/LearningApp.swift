//
//  LearningApp.swift
//  LearningApp
//
//  Created by Keegan Pangowish on 2021-12-26.
//

import SwiftUI

@main
struct LearningApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(ContentModel())
        }
    }
}
