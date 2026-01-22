//
//  ContentView.swift
//  Memora
//
//  Created by Eylül Soylu on 22.01.2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                ProfileView()
            } else{
                LoginView()
            }
        }
        
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
