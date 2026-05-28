import Foundation
import Supabase
import UIKit

final class SessionManager {
    static let shared = SessionManager()
    private init() {}

    var currentUserProfile: UserProfile?

    var caregiverGender: String?
    var patientName: String?
    var patientContact: String?
    var caregiverRelation: String = ""
    var patientDob: Date?

    var caregiverName: String?

    var activeCaregiverUid: UUID? {
        guard let profile = currentUserProfile else { return nil }
        switch profile.role {
        case .caregiver:
            return profile.uid
        case .patient:
            return profile.caregiverUid
        }
    }

    func logout() {
        Task {

            try? await SupabaseManager.shared.client.auth.signOut()

            await MainActor.run {

                self.currentUserProfile = nil
                self.caregiverName = nil
                self.caregiverGender = nil
                self.patientName = nil
                self.patientContact = nil
                self.patientDob = nil
                self.caregiverRelation = ""

                self.clearLocalDataForNewUser()

                guard let windowScene = UIApplication.shared
                    .connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                      let window = windowScene.windows.first(where: \.isKeyWindow) else { return }

                let onboardingVC = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateInitialViewController()!
                window.rootViewController = onboardingVC
                window.makeKeyAndVisible()

                UIView.transition(
                    with: window,
                    duration: 0.35,
                    options: .transitionCrossDissolve,
                    animations: nil
                )
            }
        }
    }

    func clearLocalDataForNewUser() {
        clearDefaults()
        LocalImageStore.shared.clearAll()
        RoutineStore.shared.clearAll()
        FaceStore.shared.clearAll()
        ImageSessionStore.shared.clearAll()
        PersonSessionStore.shared.clearAll()
        PersonSessionQuestionStore.shared.clearAll()
        ImageSessionQuestionStore.shared.clearAll()
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
