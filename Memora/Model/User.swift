//
//  User.swift
//  Memora
//
//  Created by Eylül Soylu on 22.01.2026.
//

import Foundation//for autontication

struct User: Identifiable,Codable {
    let id:String
    var fullname: String
    var email: String
    var profileImageUrl: String?
    var createdAt: Date?
    var notificationsEnabled: Bool
    var darkModeEnabled: Bool
    var selectedLanguage: String
    var soundEnabled: Bool
    var notesCount: Int
    var storageUsed: Double // MB cinsinden
    
    var initals: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname){
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
    
    var formattedCreatedDate: String {
        guard let date = createdAt else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    var storagePercentage: Double {
        let maxStorage = 100.0 // MB - free tier limit
        return (storageUsed / maxStorage) * 100
    }
}

extension User {
    static var MOCK_USER = User(
        id: NSUUID().uuidString,
        fullname: "Ted Mosby",
        email: "mosbysdesignisfailed@gmail.com",
        profileImageUrl: nil,
        createdAt: Date(),
        notificationsEnabled: true,
        darkModeEnabled: false,
        selectedLanguage: "en",
        soundEnabled: true,
        notesCount: 42,
        storageUsed: 23.5
    )
}

