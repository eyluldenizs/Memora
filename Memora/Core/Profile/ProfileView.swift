//
//  ProfileView.swift
//  Memora
//
//  Created by Eylül Soylu on 22.01.2026.
//


import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showDeleteAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showEditProfile = false
    @State private var showChangePassword = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationStack {
            if let user = viewModel.currentUser {
                List {
                    // MARK: - Profile Header
                    Section {
                        HStack {
                            Text(user.initals)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 72, height: 72)
                                .background(Color(.systemGray3))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(user.fullname)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.top, 5)
                                
                                Text(user.email)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                
                                if let createdAt = user.createdAt {
                                    Text("Member since \(user.formattedCreatedDate)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        Button {
                            showEditProfile = true
                        } label: {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Profile")
                            }
                            .foregroundColor(.purple)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // MARK: - Statistics
                    Section("Statistics") {
                        HStack {
                            SettingRowView(imageName: "note.text", title: "Total Notes", tintColor: .blue)
                            Spacer()
                            Text("\(user.notesCount)")
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                SettingRowView(imageName: "internaldrive", title: "Storage Used", tintColor: .orange)
                                Spacer()
                                Text("\(String(format: "%.1f", user.storageUsed)) MB / 100 MB")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            ProgressView(value: user.storagePercentage, total: 100)
                                .tint(user.storagePercentage > 80 ? .red : .purple)
                        }
                    }
                    
                    // MARK: - Preferences
                    Section("Preferences") {
                        Toggle(isOn: Binding(
                            get: { user.darkModeEnabled },
                            set: { newValue in
                                isDarkMode = newValue
                                viewModel.updateDarkMode(enabled: newValue)
                            }
                        )) {
                            SettingRowView(imageName: "moon.fill", title: "Dark Mode", tintColor: .indigo)
                        }
                        
                        Toggle(isOn: Binding(
                            get: { user.notificationsEnabled },
                            set: { viewModel.updateNotifications(enabled: $0) }
                        )) {
                            SettingRowView(imageName: "bell.fill", title: "Notifications", tintColor: .red)
                        }
                        
                        Toggle(isOn: Binding(
                            get: { user.soundEnabled },
                            set: { viewModel.updateSound(enabled: $0) }
                        )) {
                            SettingRowView(imageName: "speaker.wave.2.fill", title: "Sound", tintColor: .green)
                        }
                        
                        Picker(selection: Binding(
                            get: { user.selectedLanguage },
                            set: { viewModel.updateLanguage(language: $0) }
                        )) {
                            Text("English").tag("en")
                            Text("Türkçe").tag("tr")
                            Text("Español").tag("es")
                            Text("Français").tag("fr")
                            Text("Chinese").tag("zh")
                        } label: {
                            SettingRowView(imageName: "globe", title: "Language", tintColor: .cyan)
                        }
                    }
                
                    // MARK: - Privacy
                    Section("Privacy & Security") {
                        NavigationLink {
                            ChangePasswordView()
                                .environmentObject(viewModel)
                        } label: {
                            SettingRowView(imageName: "lock.fill", title: "Change Password", tintColor: .purple)
                        }
                        
                        Toggle(isOn: .constant(true)) {
                            SettingRowView(imageName: "eye.slash.fill", title: "Private Profile", tintColor: .gray)
                        }
                    }
                    
                    // MARK: - Activity
                    Section("Activity") {
                        NavigationLink {
                            Text("Activity History - Coming Soon")
                        } label: {
                            SettingRowView(imageName: "clock.fill", title: "Activity History", tintColor: .orange)
                        }
                    }
                    
                    // MARK: - General
                    Section("General") {
                        HStack {
                            SettingRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
                            Spacer()
                            Text("1.0.0")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // MARK: - Account
                    Section("Account") {
                        Button {
                            viewModel.signOut()
                        } label: {
                            SettingRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .purple)
                        }

                        Button {
                            showDeleteAlert = true
                        } label: {
                            SettingRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
                        }
                    }
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.large)
                .sheet(isPresented: $showEditProfile) {
                    EditProfileView(user: user)
                        .environmentObject(viewModel)
                }
                .sheet(isPresented: $showChangePassword) {
                    ChangePasswordView()
                        .environmentObject(viewModel)
                }
                .alert("Delete Account", isPresented: $showDeleteAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        Task {
                            do {
                                try await viewModel.deleteAccount()
                            } catch {
                                errorMessage = error.localizedDescription
                                showErrorAlert = true
                            }
                        }
                    }
                } message: {
                    Text("Are you sure you want to delete your account? This action cannot be undone.")
                }
                .alert("Error", isPresented: $showErrorAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
