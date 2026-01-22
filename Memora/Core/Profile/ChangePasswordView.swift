//
//  ChangePasswordView.swift
//  Memora
//
//  Created by Eylül Soylu on 22.01.2026.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("Current Password", text: $currentPassword)
                }
                
                Section("New Password") {
                    SecureField("New Password", text: $newPassword)
                    
                    ZStack(alignment: .trailing) {
                        SecureField("Confirm New Password", text: $confirmPassword)
                        
                        if !newPassword.isEmpty && !confirmPassword.isEmpty {
                            if newPassword == confirmPassword {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                Section {
                    Text("Password must be at least 6 characters long")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Section {
                    Button {
                        changePassword()
                    } label: {
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Change Password")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(Color.purple)
                    .disabled(!isFormValid || isLoading)
                }
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Password Change", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    var isFormValid: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        newPassword.count >= 6 &&
        newPassword == confirmPassword
    }
    
    private func changePassword() {
        isLoading = true
        
        Task {
            do {
                try await viewModel.changePassword(currentPassword: currentPassword, newPassword: newPassword)
                await MainActor.run {
                    alertMessage = "Password changed successfully!"
                    showAlert = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Failed to change password: \(error.localizedDescription)"
                    showAlert = true
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    ChangePasswordView()
        .environmentObject(AuthViewModel())
}
