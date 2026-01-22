//
//  EditProfileView.swift
//  Memora
//
//  Created by Eylül Soylu on 22.01.2026.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var fullname: String
    @State private var email: String
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: Image?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    init(user: User) {
        _fullname = State(initialValue: user.fullname)
        _email = State(initialValue: user.email)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack {
                        if let profileImage {
                            profileImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            if let user = viewModel.currentUser {
                                Text(user.initals)
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: 100)
                                    .background(Color(.systemGray3))
                                    .clipShape(Circle())
                            }
                        }
                        
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Text("Change Photo")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                        }
                        .onChange(of: selectedPhoto) { _, newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    profileImage = Image(uiImage: uiImage)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                
                Section("Personal Information") {
                    TextField("Full Name", text: $fullname)
                        .autocapitalization(.words)
                    
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disabled(true) // Email değişikliği için re-authentication gerekli
                        .foregroundColor(.gray)
                }
                
                Section {
                    Button {
                        saveChanges()
                    } label: {
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Spacer()
                            }
                        } else {
                            Text("Save Changes")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(Color.purple)
                    .disabled(isLoading || fullname.isEmpty)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Profile Update", isPresented: $showAlert) {
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
    
    private func saveChanges() {
        isLoading = true
        
        Task {
            do {
                try await viewModel.updateUserProfile(fullname: fullname)
                await MainActor.run {
                    alertMessage = "Profile updated successfully!"
                    showAlert = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Failed to update profile: \(error.localizedDescription)"
                    showAlert = true
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    EditProfileView(user: User.MOCK_USER)
        .environmentObject(AuthViewModel())
}

