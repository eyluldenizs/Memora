//
//  MemoraApp.swift
//  Memora
//
//  Created by Eylül Soylu on 22.01.2026.
//

import SwiftUI
import Firebase

@main
struct MemoraApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init () {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
