import UIKit
import Supabase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UIViewController()
        window?.backgroundColor = UIColor(red: 0.96, green: 0.94, blue: 0.90, alpha: 1)
        window?.makeKeyAndVisible()

        clearKeychainIfFirstLaunch()

        Task {
            do {

                let authSession = try await SupabaseManager.shared.client.auth.session
                let uid = authSession.user.id

                if let profile = try await SupabaseSyncManager.shared.fetchUserProfile(uid: uid) {
                    SessionManager.shared.currentUserProfile = profile
                    SessionManager.shared.populateFromProfile(profile)
                    await SupabaseSyncManager.shared.restoreAllData()

                    if profile.role == .caregiver {
                        if let patientProfile = try? await SupabaseSyncManager.shared.fetchPatientProfile(caregiverUid: profile.uid) {
                            SessionManager.shared.patientName = patientProfile.name
                            SessionManager.shared.patientContact = patientProfile.email
                            SessionManager.shared.saveToDefaults()
                        }
                    }

                    await MainActor.run {
                        self.showHome(for: profile.role)
                    }
                } else {

                    await MainActor.run {
                        self.showOnboarding()
                    }
                }
            } catch {

                await MainActor.run {
                    self.showOnboarding()
                }
            }
        }
    }

    private func showHome(for role: UserProfile.UserRole) {
        let (sbName, vcID) = role == .caregiver
            ? ("Caregiver", "CaregiverHomeNav")
            : ("Home", "PatientHomeNav")

        let vc = UIStoryboard(name: sbName, bundle: nil)
            .instantiateViewController(withIdentifier: vcID)
        vc.modalPresentationStyle = .fullScreen
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }

    private func showOnboarding() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() ?? UIViewController()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }

    private func clearKeychainIfFirstLaunch() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")

        if !hasLaunchedBefore {

            Task {
                try? await SupabaseManager.shared.client.auth.signOut()
            }
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {

    }

    func sceneDidBecomeActive(_ scene: UIScene) {

    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {

    }

}
