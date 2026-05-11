//
//  SessionManager.swift
//  IOS-App
//
//  Created by SDC-USER on 16/03/26.
//

import Foundation


// SessionManager.swift
final class SessionManager {
    static let shared = SessionManager()
    private init() {}

    var currentUserProfile: UserProfile?
    
    var caregiverGender: String?
    var patientName: String?
    var patientContact: String?
    var caregiverRelation: String = ""
    
    var caregiverName: String?

    // ✅ The caregiverUid to scope all queries
    // For caregiver: their own uid
    // For patient: their caregiverUid from UserProfile
    var activeCaregiverUid: UUID? {
        guard let profile = currentUserProfile else { return nil }
        switch profile.role {
        case .caregiver:
            return profile.uid
        case .patient:
            return profile.caregiverUid
        }
    }
    
    func clearLocalDataForNewUser() {
        clearDefaults() 
        LocalImageStore.shared.clearAll()
        RoutineStore.shared.clearAll()
        FaceStore.shared.clearAll()        // add clearAll to FaceStore too
        ImageSessionStore.shared.clearAll()
        PersonSessionStore.shared.clearAll()
        PersonSessionQuestionStore.shared.clearAll()
        ImageSessionQuestionStore.shared.clearAll()
        print("🧹 All local stores cleared for new user")
    }
    
    func populateFromProfile(_ profile: UserProfile) {
        switch profile.role {
        case .caregiver:
            caregiverName = profile.name
            caregiverGender = profile.gender
        case .patient:
            patientName = profile.name
            patientContact = profile.email
            saveToDefaults()
        }
    }
    
    // MARK: - Persistence

    func saveToDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(caregiverName, forKey: "caregiverName")
        defaults.set(caregiverGender, forKey: "caregiverGender")
        defaults.set(patientName, forKey: "patientName")
        defaults.set(patientContact, forKey: "patientContact")
    }

    func loadFromDefaults() {
        let defaults = UserDefaults.standard
        caregiverName = defaults.string(forKey: "caregiverName")
        caregiverGender = defaults.string(forKey: "caregiverGender")
        patientName = defaults.string(forKey: "patientName")
        patientContact = defaults.string(forKey: "patientContact")
    }

    func clearDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "caregiverName")
        defaults.removeObject(forKey: "caregiverGender")
        defaults.removeObject(forKey: "patientName")
        defaults.removeObject(forKey: "patientContact")
    }
    
}
