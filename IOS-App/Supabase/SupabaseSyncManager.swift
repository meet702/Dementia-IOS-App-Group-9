//
//  SupabaseSyncManager.swift
//  IOS-App
//
//  Created by SDC-USER on 06/03/26.
//


import Foundation
import Supabase

final class SupabaseSyncManager {

    static let shared = SupabaseSyncManager()
    private init() {}

    private let client = SupabaseManager.shared.client

    // MARK: - WholeImage

    func insertWholeImage(_ image: WholeImage) async {
        guard let caregiverUid = SessionManager.shared.activeCaregiverUid else {
            print("❌ No caregiverUid — user not logged in")
            return
        }
        print("✅ caregiverUid found:", caregiverUid)
        
        var scopedImage = image
        scopedImage.caregiverUid = caregiverUid

        // 🔼 Upload image file to Supabase Storage if it exists locally
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

            // Search the entire Documents directory for the image file
            var fileURL: URL? = nil

            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(
                at: documentsURL,
                includingPropertiesForKeys: nil
            )

            while let url = enumerator?.nextObject() as? URL {
                if url.lastPathComponent == image.fileName {
                    fileURL = url
                    break
                }
            }

            if let fileURL = fileURL {
                let data = try Data(contentsOf: fileURL)

                try await client.storage
                    .from("memory-images")
                    .upload(
                        path: image.fileName,
                        file: data,
                        options: FileOptions(contentType: "image/jpeg", upsert: true)
                    )

                print("☁️ Image uploaded to Supabase Storage:", image.fileName)

            } else {
                print("⚠️ Local image file not found anywhere in Documents for upload:", image.fileName)
            }

        } catch {
            print("❌ Image upload to Supabase Storage failed:", error)
        }

        for attempt in 1...3 {

            do {
                try await client
                    .from("WholeImage")
                    .insert(scopedImage)
                    .execute()

                print("☁️ WholeImage inserted")
                return

            } catch {

                print("⚠️ WholeImage insert attempt \(attempt) failed:", error)

                try? await Task.sleep(nanoseconds: 400_000_000)
            }
        }

        print("❌ WholeImage insert failed permanently")
    }

    func deleteWholeImage(wid: UUID) async {

        do {
            try await client
                .from("WholeImage")
                .delete()
                .eq("wid", value: wid)
                .execute()

            print("🗑 WholeImage deleted")

        } catch {
            print("❌ WholeImage delete failed:", error)
        }
    }

    func updateWholeImageAction(
        wid: UUID,
        action: MemoryActionContent
    ) async {
        do {
            var remoteAction = action

            // Upload audio to Supabase Storage, but keep local URL on device
            if case .voice(let localURL) = action {
                let remoteURL = try await uploadAudioFile(localURL: localURL, wid: wid)
                remoteAction = .voice(remoteURL)
                // ⚠️ Do NOT update LocalImageStore here — local URL stays as-is
            }

            try await client
                .from("WholeImage")
                .update(["action": remoteAction])
                .eq("wid", value: wid)
                .execute()

            print("☁️ WholeImage action updated (remote URL in Supabase, local URL on device)")

        } catch {
            print("❌ WholeImage update failed:", error)
        }
    }


    // MARK: - Face

    func upsertFaces(_ faces: [Face]) async {
        guard let caregiverUid = SessionManager.shared.activeCaregiverUid else {
            print("❌ upsertFaces — no caregiverUid")
            return
        }

        let scopedFaces = faces.map { face -> Face in
            var f = face
            f.caregiverUid = caregiverUid
            return f
        }

        do {
            // ✅ upsert with ignoreDuplicates — no constraint dependency
            try await client
                .from("Face")
                .upsert(scopedFaces, onConflict: "fid", ignoreDuplicates: false)
                .execute()
            print("☁️ Faces synced: \(scopedFaces.count)")
        } catch {
            print("❌ Face sync failed:", error)
            
            // ✅ Fallback: try inserting one by one to isolate failures
            for face in scopedFaces {
                do {
                    try await client
                        .from("Face")
                        .insert(face)
                        .execute()
                    print("✅ Face inserted individually:", face.fid)
                } catch {
                    print("❌ Individual face insert failed:", face.fid, error)
                }
            }
        }
    }

    func deleteFacesForImage(wid: UUID) async {

        do {

            try await client
                .from("Face")
                .delete()
                .eq("wid", value: wid)
                .execute()

            print("🗑 Faces deleted")

        } catch {

            print("❌ Face delete failed:", error)
        }
    }


    // MARK: - ImageSession

    func insertImageSession(_ session: ImageSession) async {
        guard let caregiverUid = SessionManager.shared.activeCaregiverUid else {
            print("❌ insertImageSession — no caregiverUid")
            return
        }

        var scopedSession = session
        scopedSession.caregiverUid = caregiverUid  // ✅ attach before insert

        do {
            try await client
                .from("ImageSession")
                .insert(scopedSession)
                .execute()
            print("☁️ ImageSession inserted")
        } catch {
            print("❌ ImageSession insert failed:", error)
        }
    }

    func updateImageSessionEnd(
        isid: UUID,
        endedAt: Date
    ) async {
        do {
            try await client
                .from("ImageSession")
                .update([
                    "endedAt": endedAt
                ])
                .eq("isid", value: isid)
                .execute()

            print("☁️ ImageSession endedAt updated")
        } catch {
            print("❌ ImageSession update failed:", error)
        }
    }

    func updateImageSessionRecapCount(
        isid: UUID,
        recapCount: Int
    ) async {
        do {
            try await client
                .from("ImageSession")
                .update([
                    "recapCount": recapCount
                ])
                .eq("isid", value: isid)
                .execute()

            print("☁️ ImageSession recapCount updated")
        } catch {
            print("❌ ImageSession recap update failed:", error)
        }
    }


    func insertPersonSession(_ session: PersonSession) async {
        guard let caregiverUid = SessionManager.shared.activeCaregiverUid else { return }

        var scopedSession = session
        scopedSession.caregiverUid = caregiverUid

        do {
            try await client
                .from("PersonSession")
                .insert(scopedSession)  // ✅ scopedSession not session
                .execute()
            print("☁️ PersonSession inserted")
        } catch {
            print("❌ PersonSession insert failed:", error)
        }
    }

    func insertPersonSessionQuestion(_ question: PersonSessionQuestion) async {
        guard let caregiverUid = SessionManager.shared.activeCaregiverUid else { return }

        var scopedQuestion = question
        scopedQuestion.caregiverUid = caregiverUid

        do {
            try await client
                .from("PersonSessionQuestion")
                .insert(scopedQuestion)  // ✅ scopedQuestion not question
                .execute()
            print("☁️ PersonSessionQuestion inserted")
        } catch {
            print("❌ PersonSessionQuestion insert failed:", error)
        }
    }

    func insertImageSessionQuestion(_ question: ImageSessionQuestion) async {
        guard let caregiverUid = SessionManager.shared.activeCaregiverUid else { return }

        var scopedQuestion = question
        scopedQuestion.caregiverUid = caregiverUid

        do {
            try await client
                .from("ImageSessionQuestion")
                .insert(scopedQuestion)  // ✅ scopedQuestion not question
                .execute()
            print("☁️ ImageSessionQuestion inserted")
        } catch {
            print("❌ ImageSessionQuestion insert failed:", error)
        }
    }

    // MARK: - READ Operations (for Recap / Restore)

    func fetchPersonSessions(isid: UUID) async -> [PersonSession] {
        do {
            let response: [PersonSession] = try await client
                .from("PersonSession")
                .select()
                .eq("isid", value: isid)
                .execute()
                .value

            return response
        } catch {
            print("❌ Fetch PersonSessions failed:", error)
            return []
        }
    }


    func fetchPersonSessionQuestions(psid: UUID) async -> [PersonSessionQuestion] {
        do {
            let response: [PersonSessionQuestion] = try await client
                .from("PersonSessionQuestion")
                .select()
                .eq("psid", value: psid)
                .execute()
                .value

            return response
        } catch {
            print("❌ Fetch PersonSessionQuestions failed:", error)
            return []
        }
    }


    func fetchImageSessionQuestions(isid: UUID) async -> [ImageSessionQuestion] {
        do {
            let response: [ImageSessionQuestion] = try await client
                .from("ImageSessionQuestion")
                .select()
                .eq("isid", value: isid)
                .execute()
                .value

            return response
        } catch {
            print("❌ Fetch ImageSessionQuestions failed:", error)
            return []
        }
    }
    
    func updatePersonSessionQuestion(_ question: PersonSessionQuestion) async {
        do {
            try await client
                .from("PersonSessionQuestion")
                .update(question)
                .eq("psqid", value: question.psqid)
                .execute()

            print("☁️ PersonSessionQuestion updated with text:", question.responseText ?? "nil")
        } catch {
            print("❌ PersonSessionQuestion update failed:", error)
        }
    }
    
    func restoreAllData() async {
        print("🔄 Starting full data restore...")
        await restoreCaregiverMemories()
        await restoreSessionData()

        // ✅ Always replace local with Supabase — remote is source of truth
        let routineTasks = await restoreRoutineTasks()
        await MainActor.run {
            RoutineStore.shared.replaceAll(with: routineTasks)
        }

        print("✅ Full data restore complete")
    }
    

    func restoreSessionData() async {
        guard let caregiverUid = SessionManager.shared.activeCaregiverUid else { return }
        
        do {
            print("☁️ Restoring session data from Supabase...")

            // 1️⃣ Fetch all ImageSessions
            let imageSessions: [ImageSession] = try await client
                .from("ImageSession")
                .select()
                .eq("caregiverUid", value: caregiverUid)
                .execute()
                .value

            for session in imageSessions {
                ImageSessionStore.shared.addSession(session)

                // 2️⃣ Fetch ImageSessionQuestions for each session
                let imageQuestions: [ImageSessionQuestion] = try await client
                    .from("ImageSessionQuestion")
                    .select()
                    .eq("isid", value: session.isid)
                    .execute()
                    .value

                for q in imageQuestions {
                    ImageSessionQuestionStore.shared.add(q)
                }

                // 3️⃣ Fetch PersonSessions for each ImageSession
                let personSessions: [PersonSession] = try await client
                    .from("PersonSession")
                    .select()
                    .eq("isid", value: session.isid)
                    .execute()
                    .value

                for personSession in personSessions {
                    PersonSessionStore.shared.add(personSession)

                    // 4️⃣ Fetch PersonSessionQuestions for each PersonSession
                    let personQuestions: [PersonSessionQuestion] = try await client
                        .from("PersonSessionQuestion")
                        .select()
                        .eq("psid", value: personSession.psid)
                        .execute()
                        .value

                    for q in personQuestions {
                        PersonSessionQuestionStore.shared.add(q)
                    }
                }
            }

            // 5️⃣ Restore session images
            for session in imageSessions {
                if SessionImageStore.shared.fetchImage(by: session.wid) == nil,
                   let image = LocalImageStore.shared.fetchImage(by: session.wid) {
                    _ = image
                    SessionImageStore.shared.saveSessionImage(for: session.wid)
                }
            }

            print("☁️ Session data fully restored: \(imageSessions.count) sessions")

        } catch {
            print("❌ Session data restore failed:", error)
        }
    }
    
    func restoreCaregiverMemories() async {
        guard let caregiverUid = SessionManager.shared.activeCaregiverUid else {
            print("❌ No caregiverUid for restore")
            return
        }
        
        do {
            let images: [WholeImage] = try await client
                .from("WholeImage")
                .select()
                .eq("caregiverUid", value: caregiverUid)
                .execute()
                .value

            let documentsURL = FileManager.default.urls(
                for: .documentDirectory, in: .userDomainMask
            ).first!

            // ✅ Match LocalImageStore's folder exactly
            let albumFolder = documentsURL.appendingPathComponent("AlbumImages", isDirectory: true)
            try? FileManager.default.createDirectory(
                at: albumFolder, withIntermediateDirectories: true
            )

            for image in images {

                // 1️⃣ Restore image file to AlbumImages (where LocalImageStore expects it)
                do {
                    let imageFileURL = albumFolder.appendingPathComponent(image.fileName)
                    if !FileManager.default.fileExists(atPath: imageFileURL.path) {
                        let data = try await client.storage
                            .from("memory-images")
                            .download(path: image.fileName)
                        try data.write(to: imageFileURL)
                        print("📥 Image restored to AlbumImages:", image.fileName)
                    }
                } catch {
                    print("❌ Image download failed:", image.fileName, error)
                }

                // 2️⃣ Restore audio file — save to MemoryLane folder (separate from images)
                var localAction = image.action
                if case .voice(let remoteURL) = image.action, !remoteURL.isFileURL {
                    do {
                        let memoryLaneFolder = documentsURL.appendingPathComponent(
                            "MemoryLane", isDirectory: true
                        )
                        try? FileManager.default.createDirectory(
                            at: memoryLaneFolder, withIntermediateDirectories: true
                        )

                        let fileName = "\(image.wid.uuidString).m4a"
                        let localAudioURL = memoryLaneFolder.appendingPathComponent(fileName)

                        if !FileManager.default.fileExists(atPath: localAudioURL.path) {
                            let audioData = try await client.storage
                                .from("voice-memos")
                                .download(path: fileName)
                            try audioData.write(to: localAudioURL)
                            print("📥 Audio restored:", fileName)
                        }

                        localAction = .voice(localAudioURL)

                    } catch {
                        print("❌ Audio download failed for \(image.wid):", error)
                    }
                }

                // 3️⃣ Save metadata with local audio URL
                let localImage = WholeImage(
                    wid: image.wid,
                    fileName: image.fileName,
                    action: localAction,
                    createdAt: image.createdAt
                )
                LocalImageStore.shared.update(localImage)

                // 4️⃣ Restore faces
                let faces: [Face] = try await client
                    .from("Face")
                    .select()
                    .eq("wid", value: image.wid)
                    .execute()
                    .value
                
                let sortedFaces = faces.sorted { $0.orderIndex < $1.orderIndex }
                FaceStore.shared.saveFaces(sortedFaces)
                
                for face in faces {
                    let faceFileURL = FaceStore.shared.faceImageURL(for: face.fileName)
                    
                    // Skip if already exists locally
                    guard !FileManager.default.fileExists(atPath: faceFileURL.path) else {
                        print("⏭ Face image already exists: \(face.fileName)")
                        continue
                    }
                    
                    do {
                        let faceImageData = try await client.storage
                            .from("face-images")
                            .download(path: face.fileName)
                        
                        try faceImageData.write(to: faceFileURL)
                        print("📥 Face image restored: \(face.fileName)")
                    } catch {
                        print("❌ Face image download failed: \(face.fileName)", error)
                    }
                }
            }

            print("☁️ Caregiver memories fully restored")

        } catch {
            print("❌ Restore failed:", error)
        }
    }
    
    func uploadFaceImages(_ faces: [Face]) async {
        for face in faces {
            let localURL = FaceStore.shared.faceImageURL(for: face.fileName)
            
            guard FileManager.default.fileExists(atPath: localURL.path) else {
                print("⚠️ Face image file not found locally: \(face.fileName)")
                continue
            }
            
            do {
                let data = try Data(contentsOf: localURL)
                
                try await client.storage
                    .from("face-images")
                    .upload(
                        path: face.fileName,
                        file: data,
                        options: FileOptions(contentType: "image/jpeg", upsert: true)
                    )
                
                print("☁️ Face image uploaded: \(face.fileName)")
            } catch {
                print("❌ Face image upload failed: \(face.fileName)", error)
            }
        }
    }
    
    private func uploadAudioFile(localURL: URL, wid: UUID) async throws -> URL {
        let fileName = "\(wid.uuidString).m4a"
        let fileData = try Data(contentsOf: localURL)

        try await client.storage
            .from("voice-memos")
            .upload(
                path: fileName,
                file: fileData,
                options: FileOptions(contentType: "audio/m4a", upsert: true)
            )

        let remoteURL = try client.storage
            .from("voice-memos")
            .getPublicURL(path: fileName)

        print("☁️ Audio uploaded to Supabase Storage:", remoteURL)
        return remoteURL
    }
    
    // MARK: - RoutineTask

    func insertRoutineTask(_ task: RoutineTask) async {
        guard let caregiverUid = SessionManager.shared.activeCaregiverUid else { return }
        var scopedTask = task
        scopedTask.caregiverUid = caregiverUid
        
        do {
            try await client
                .from("RoutineTask")
                .upsert(scopedTask, onConflict: "id")  // ✅ upsert, never duplicate
                .execute()
            print("☁️ RoutineTask upserted:", task.title)
        } catch {
            print("❌ RoutineTask upsert failed:", error)
        }
    }

    func updateRoutineTask(_ task: RoutineTask) async {
        do {
            try await client
                .from("RoutineTask")
                .update(task)
                .eq("id", value: task.id)
                .execute()
            print("☁️ RoutineTask updated:", task.title)
        } catch {
            print("❌ RoutineTask update failed:", error)
        }
    }

    func deleteRoutineTask(id: UUID) async {
        do {
            try await client
                .from("RoutineTask")
                .delete()
                .eq("id", value: id)
                .execute()
            print("🗑 RoutineTask deleted")
        } catch {
            print("❌ RoutineTask delete failed:", error)
        }
    }

    func updateRoutineTaskCompletion(_ task: RoutineTask) async {

        struct CompletionUpdate: Encodable {
            let completedDates: [String]
            let isCompleted: Bool
        }

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone.current  // ✅ IST, not UTC
        
        print("🔍 Raw completedDates being encoded:", task.completedDates)
        for d in task.completedDates {
            print("   date:", d, "IST string:", df.string(from: d))
        }

        let dateStrings = task.completedDates.map { df.string(from: $0) }
        print("📤 Sending to Supabase completedDates:", dateStrings, "for task:", task.title)

        do {
            try await client
                .from("RoutineTask")
                .update(CompletionUpdate(
                    completedDates: dateStrings,
                    isCompleted: task.isCompleted
                ))
                .eq("id", value: task.id)
                .execute()
            print("✅ Supabase confirmed completion update")
        } catch {
            print("❌ RoutineTask completion sync failed:", error)
        }
    }

    func restoreRoutineTasks() async -> [RoutineTask] {
        guard let caregiverUid = SessionManager.shared.activeCaregiverUid else { return [] }
        
        do {
            let tasks: [RoutineTask] = try await client
                .from("RoutineTask")
                .select()
                .eq("caregiverUid", value: caregiverUid)
                .execute()
                .value
            print("☁️ Routine tasks restored from Supabase: \(tasks.count)")
            return tasks
        } catch {
            print("❌ Routine restore failed:", error)
            return []
        }
    }
    
    // MARK: - UserProfile

    func connectCaregiverToPatient(
        patientEmail: String,
        caregiverUid: UUID,
        caregiverRelation: String       // ✅ ADD THIS
    ) async throws {

        // 1️⃣ Find patient by email
        let results: [UserProfile] = try await client
            .from("UserProfile")
            .select()
            .eq("email", value: patientEmail)
            .execute()
            .value

        guard let patient = results.first else {
            throw ConnectionError.patientNotFound
        }

        guard patient.role == .patient else {
            throw ConnectionError.notAPatient
        }

        guard patient.caregiverUid == nil else {
            throw ConnectionError.alreadyConnected
        }

        // 2️⃣ Link caregiver uid AND relation into patient's profile
        try await client
            .from("UserProfile")
            .update([
                "caregiverUid": caregiverUid.uuidString,
                "caregiverRelation": caregiverRelation    // ✅ ADD THIS
            ])
            .eq("email", value: patientEmail)
            .execute()

        print("☁️ Caregiver linked to patient:", patient.name)
    }

    enum ConnectionError: LocalizedError {
        case patientNotFound
        case notAPatient
        case alreadyConnected

        var errorDescription: String? {
            switch self {
            case .patientNotFound:   return "No patient found with this email."
            case .notAPatient:       return "This email belongs to a caregiver account."
            case .alreadyConnected:  return "This patient is already connected to a caregiver."
            }
        }
    }
    
    // MARK: - Auth

    func sendOTP(email: String) async throws {
        try await client.auth.signInWithOTP(
            email: email
        )
        print("☁️ OTP sent to:", email)
    }

    func verifyOTP(email: String, otp: String) async throws {
        try await client.auth.verifyOTP(
            email: email,
            token: otp,
            type: .email
        )
        print("☁️ OTP verified")
    }

    func createUserProfile(_ profile: UserProfile) async throws {
        try await client
            .from("UserProfile")
            .insert(profile)
            .execute()
        print("☁️ UserProfile created:", profile.name)
    }

    func fetchUserProfile(uid: UUID) async throws -> UserProfile? {
        let results: [UserProfile] = try await client
            .from("UserProfile")
            .select()
            .eq("uid", value: uid)
            .execute()
            .value
        return results.first
    }
    
    
    func uploadMissingFaceImages() async {
        let allFaces = FaceStore.shared.loadAllFaces() // load all faces from local JSON
        
        for face in allFaces {
            let localURL = FaceStore.shared.faceImageURL(for: face.fileName)
            
            guard FileManager.default.fileExists(atPath: localURL.path) else {
                print("⚠️ Face image not found locally:", face.fileName)
                continue
            }
            
            do {
                let data = try Data(contentsOf: localURL)
                try await client.storage
                    .from("face-images")
                    .upload(
                        path: face.fileName,
                        file: data,
                        options: FileOptions(contentType: "image/jpeg", upsert: true)
                    )
                print("☁️ Face image uploaded:", face.fileName)
            } catch {
                print("❌ Face image upload failed:", face.fileName, error)
            }
        }
    }
    
    func fetchPatientProfile(caregiverUid: UUID) async throws -> UserProfile? {
        let results: [UserProfile] = try await client
            .from("UserProfile")        // ✅ match your other tables
            .select()
            .eq("caregiverUid", value: caregiverUid)   // ✅ match your column name
            .eq("role", value: "patient")
            .execute()
            .value
        return results.first            // ✅ no .single() — safer, won't throw if not found
    }
    
    
}
