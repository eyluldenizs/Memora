//
//  AuthViewModel.swift
//  Memora
//
//  Created by Eylül Soylu on 22.01.2026.
//

//
//  AuthViewModel.swift
//  Notivo
//
//  Created by Eylül Soylu on 19.10.2025.
//
//hanvig all netwrok stuff
//seniidng notification uı
//log in error
import Foundation
import Firebase
import FirebaseAuth

protocol AuthenticationFormProtocol{
    var formIsValid: Bool { get }
    
}

@MainActor
class AuthViewModel:ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task{
            await fetchUser()
        }
    }
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
         await fetchUser()
        }catch{
            print("DEBUG: Failed to log in with error\(error.localizedDescription)")
        }
        }

        
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            print("➡️ createUser çalıştı")
            
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("➡️ Firebase user oluşturuldu: \(result.user.uid)")
            
            self.userSession = result.user
            
            let db = Firestore.firestore()
            
            let data: [String: Any] = [
                "id": result.user.uid,
                "fullname": fullname,
                "email": email,
                "profileImageUrl": NSNull(),
                "createdAt": FieldValue.serverTimestamp(),
                "notificationsEnabled": true,
                "darkModeEnabled": false,
                "selectedLanguage": "en",
                "soundEnabled": true,
                "notesCount": 0,
                "storageUsed": 0.0
            ]
            
            try await db.collection("users").document(result.user.uid).setData(data)
            print("➡️ Firestore'a yazıldı")
            
        } catch {
            print("❌ createUser hata: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOut()  {
        do {
            try Auth.auth().signOut()   //signs out user on backend
            self.userSession = nil //wipes out user session and takes us to login screen
            self.currentUser = nil //wipes out current user data model
        }
        catch {
            print("DEBUG:Failed to sign outwith error: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            print("DEBUG: No user to delete")
            throw NSError(domain: "AuthViewModel", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        
        guard let uid = user.uid as String? else {
            throw NSError(domain: "AuthViewModel", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid user ID"])
        }
        
        do {
            // 1. Firestore'dan kullanıcı verilerini sil
            try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .delete()
            print("DEBUG: Firestore user data deleted")
            
            // 2. Firebase Authentication'dan kullanıcıyı sil
            try await user.delete()
            print("DEBUG: Firebase Auth user deleted")
            
            // 3. Local state'i temizle
            self.userSession = nil
            self.currentUser = nil
            
            print("✅ Account successfully deleted")
            
        } catch {
            print("❌ Failed to delete account: \(error.localizedDescription)")
            throw error
        }
    }
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG: no auth user")
            return
        }
        
        do {
            let snapshot = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument()
            
            guard let data = snapshot.data() else {
                print("DEBUG: No data found for user")
                return
            }
            
            let createdAtTimestamp = data["createdAt"] as? Timestamp
            let createdAtDate = createdAtTimestamp?.dateValue()
            
            let user = User(
                id: uid,
                fullname: data["fullname"] as? String ?? "",
                email: data["email"] as? String ?? "",
                profileImageUrl: data["profileImageUrl"] as? String,
                createdAt: createdAtDate,
                notificationsEnabled: data["notificationsEnabled"] as? Bool ?? true,
                darkModeEnabled: data["darkModeEnabled"] as? Bool ?? false,
                selectedLanguage: data["selectedLanguage"] as? String ?? "en",
                soundEnabled: data["soundEnabled"] as? Bool ?? true,
                notesCount: data["notesCount"] as? Int ?? 0,
                storageUsed: data["storageUsed"] as? Double ?? 0.0
            )
            
            await MainActor.run {
                self.currentUser = user
                print("DEBUG: currentUser SET → \(self.currentUser!)")
            }
            
        } catch {
            print("DEBUG: Failed to fetch user: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Update User Profile
    func updateUserProfile(fullname: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthViewModel", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        
        try await Firestore.firestore()
            .collection("users")
            .document(uid)
            .updateData(["fullname": fullname])
        
        await fetchUser()
    }
    
    // MARK: - Change Password
    func changePassword(currentPassword: String, newPassword: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "AuthViewModel", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        
        guard let email = user.email else {
            throw NSError(domain: "AuthViewModel", code: 400, userInfo: [NSLocalizedDescriptionKey: "No email found"])
        }
        
        // Re-authenticate user
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        
        do {
            try await user.reauthenticate(with: credential)
            try await user.updatePassword(to: newPassword)
            print("✅ Password changed successfully")
        } catch {
            print("❌ Failed to change password: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Update Settings
    func updateDarkMode(enabled: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Task {
            try? await Firestore.firestore()
                .collection("users")
                .document(uid)
                .updateData(["darkModeEnabled": enabled])
            
            await fetchUser()
        }
    }
    
    func updateNotifications(enabled: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Task {
            try? await Firestore.firestore()
                .collection("users")
                .document(uid)
                .updateData(["notificationsEnabled": enabled])
            
            await fetchUser()
        }
    }
    
    func updateSound(enabled: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Task {
            try? await Firestore.firestore()
                .collection("users")
                .document(uid)
                .updateData(["soundEnabled": enabled])
            
            await fetchUser()
        }
    }
    
    func updateLanguage(language: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Task {
            try? await Firestore.firestore()
                .collection("users")
                .document(uid)
                .updateData(["selectedLanguage": language])
            
            await fetchUser()
        }
    }
}


