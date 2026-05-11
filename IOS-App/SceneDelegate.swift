//
//  SceneDelegate.swift
//  IOS-App
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit
import Supabase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UIViewController()
        window?.backgroundColor = UIColor(red: 0.96, green: 0.94, blue: 0.90, alpha: 1)
        window?.makeKeyAndVisible()
        
        clearKeychainIfFirstLaunch()
        
        Task {
            do {
                // Supabase restores session from Keychain automatically
                let authSession = try await SupabaseManager.shared.client.auth.session
                let uid = authSession.user.id
                
                if let profile = try await SupabaseSyncManager.shared.fetchUserProfile(uid: uid) {
                    SessionManager.shared.currentUserProfile = profile
                    SessionManager.shared.populateFromProfile(profile)
                    await SupabaseSyncManager.shared.restoreAllData()

                    // For caregivers: fetch the linked patient's info so Home and Profile screens populate correctly
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
                    // Logged in but no profile yet → resume role selection
                    await MainActor.run {
                        self.showOnboarding()
                    }
                }
            } catch {
                // No valid session → fresh onboarding
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
        let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateInitialViewController()!
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
    
    private func clearKeychainIfFirstLaunch() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        
        if !hasLaunchedBefore {
            // Fresh install — clear any stale Supabase session from Keychain
            Task {
                try? await SupabaseManager.shared.client.auth.signOut()
            }
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

