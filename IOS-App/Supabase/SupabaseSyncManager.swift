import Foundation
import Supabase

final class SupabaseSyncManager {

    static let shared = SupabaseSyncManager()
    private init() {}

    private let client = SupabaseManager.shared.client

    func insertWholeImage(_ image: WholeImage) async {
        guard let caregiverUid = SessionManager.shared.activeCaregiverUid else {
            return
        }

        var scopedImage = image
        scopedImage.caregiverUid = caregiverUid

        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())

            var fileURL: URL?

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

            } else {
            }

        } catch {
            print("Image upload to Supabase Storage failed:", error)
        }

        for attempt in 1...3 {

            do {
                try await client
                    .from("WholeImage")
                    .insert(scopedImage)
                    .execute()

                return

            } catch {

                print("WholeImage insert attempt \(attempt) failed:", error)

                try? await Task.sleep(nanoseconds: 400_000_000)
            }
        }

        print("WholeImage insert failed permanently")
    }

    func deleteWholeImage(wid: UUID) async {

        do {
            try await client
                .from("WholeImage")
                .delete()
                .eq("wid", value: wid)
                .execute()

        } catch {
            print("WholeImage delete failed:", error)
        }
    }

    func updateWholeImageAction(
        wid: UUID,
        action: MemoryActionContent
    ) async {
        do {
            var remoteAction = action

            if case .voice(let localURL) = action {
                let remoteURL = try await uploadAudioFile(localURL: localURL, wid: wid)
                remoteAction = .voice(remoteURL)

            }

            try await client
                .from("WholeImage")
                .update(["action": remoteAction])
                .eq("wid", value: wid)
                .execute()

        } catch {
            print("WholeImage update failed:", error)
        }
    }

    func upsertFaces(_ faces: [Face]) async {
        guard let caregiverUid = SessionManager.shared.activeCaregiverUid else {
            return
        }

        let scopedFaces = faces.map { face -> Face in
            var f = face
            f.caregiverUid = caregiverUid
            return f
        }

        do {

            try await client
                .from("Face")
                .upsert(scopedFaces, onConflict: "fid", ignoreDuplicates: false)
                .execute()
        } catch {
            print("Face sync failed:", error)

            for face in scopedFaces {
                do {
                    try await client
                        .from("Face")
                        .insert(face)
                        .execute()
                } catch {
                    print("Individual face insert failed:", face.fid, error)
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

        } catch {

            print("Face delete failed:", error)
        }
    }

    func insertImageSession(_ session: ImageSession) async {
        guard let caregiverUid = SessionManager.shared.activeCaregiverUid else {
            return
        }

        var scopedSession = session
        scopedSession.caregiverUid = caregiverUid

        do {
            try await client
                .from("ImageSession")
                .insert(scopedSession)
                .execute()
        } catch {
            print("ImageSession insert failed:", error)
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

        } catch {
            print("ImageSession update failed:", error)
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

        } catch {
            print("ImageSession recap update failed:", error)
        }
    }

    func insertPersonSession(_ session: PersonSession) async {
        guard let caregiverUid = SessionManager.shared.activeCaregiverUid else { return }

        var scopedSession = session
        scopedSession.caregiverUid = caregiverUid

        do {
            try await client
                .from("PersonSession")
                .insert(scopedSession)
                .execute()
        } catch {
            print("PersonSession insert failed:", error)
        }
    }

    func insertPersonSessionQuestion(_ question: PersonSessionQuestion) async {
        guard let caregiverUid = SessionManager.shared.activeCaregiverUid else { return }

        var scopedQuestion = question
        scopedQuestion.caregiverUid = caregiverUid

        do {
            try await client
                .from("PersonSessionQuestion")
                .insert(scopedQuestion)
                .execute()
        } catch {
            print("PersonSessionQuestion insert failed:", error)
        }
    }

    func insertImageSessionQuestion(_ question: ImageSessionQuestion) async {
        guard let caregiverUid = SessionManager.shared.activeCaregiverUid else { return }

        var scopedQuestion = question
        scopedQuestion.caregiverUid = caregiverUid

        do {
            try await client
                .from("ImageSessionQuestion")
                .insert(scopedQuestion)
                .execute()
        } catch {
            print("ImageSessionQuestion insert failed:", error)
        }
    }

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
            print("Fetch PersonSessions failed:", error)
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
            print("Fetch PersonSessionQuestions failed:", error)
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
            print("Fetch ImageSessionQuestions failed:", error)
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

        } catch {
            print("PersonSessionQuestion update failed:", error)
        }
    }

    func restoreAllData() async {
        await restoreCaregiverMemories()
        await restoreSessionData()

        let routineTasks = await restoreRoutineTasks()
        await MainActor.run {
            RoutineStore.shared.replaceAll(with: routineTasks)
        }

    }

    func restoreSessionData() async {
        guard let caregiverUid = SessionManager.shared.activeCaregiverUid else { return }

        do {

            let imageSessions: [ImageSession] = try await client
                .from("ImageSession")
                .select()
                .eq("caregiverUid", value: caregiverUid)
                .execute()
                .value

            for session in imageSessions {
                ImageSessionStore.shared.addSession(session)

                let imageQuestions: [ImageSessionQuestion] = try await client
                    .from("ImageSessionQuestion")
                    .select()
                    .eq("isid", value: session.isid)
                    .execute()
                    .value

                for q in imageQuestions {
                    ImageSessionQuestionStore.shared.add(q)
                }

                let personSessions: [PersonSession] = try await client
                    .from("PersonSession")
                    .select()
                    .eq("isid", value: session.isid)
                    .execute()
                    .value

                for personSession in personSessions {
                    PersonSessionStore.shared.add(personSession)

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

            for session in imageSessions {
                if SessionImageStore.shared.fetchImage(by: session.wid) == nil,
                   let image = LocalImageStore.shared.fetchImage(by: session.wid) {
                    _ = image
                    SessionImageStore.shared.saveSessionImage(for: session.wid)
                }
            }

        } catch {
            print("Session data restore failed:", error)
        }
    }

    func restoreCaregiverMemories() async {
        guard let caregiverUid = SessionManager.shared.activeCaregiverUid else {
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
            ).first ?? URL(fileURLWithPath: NSTemporaryDirectory())

            let albumFolder = documentsURL.appendingPathComponent("AlbumImages", isDirectory: true)
            try? FileManager.default.createDirectory(
                at: albumFolder, withIntermediateDirectories: true
            )

            for image in images {

                do {
                    let imageFileURL = albumFolder.appendingPathComponent(image.fileName)
                    if !FileManager.default.fileExists(atPath: imageFileURL.path) {
                        let data = try await client.storage
                            .from("memory-images")
                            .download(path: image.fileName)
                        try data.write(to: imageFileURL)
                    }
                } catch {
                    print("Image download failed:", image.fileName, error)
                }

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
                        }

                        localAction = .voice(localAudioURL)

                    } catch {
                        print("Audio download failed for \(image.wid):", error)
                    }
                }

                let localImage = WholeImage(
                    wid: image.wid,
                    fileName: image.fileName,
                    action: localAction,
                    createdAt: image.createdAt
                )
                LocalImageStore.shared.update(localImage)

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

                    guard !FileManager.default.fileExists(atPath: faceFileURL.path) else {
                        continue
                    }

                    do {
                        let faceImageData = try await client.storage
                            .from("face-images")
                            .download(path: face.fileName)

                        try faceImageData.write(to: faceFileURL)
                    } catch {
                        print("Face image download failed: \(face.fileName)", error)
                    }
                }
            }

        } catch {
            print("Restore failed:", error)
        }
    }

    func uploadFaceImages(_ faces: [Face]) async {
        for face in faces {
            let localURL = FaceStore.shared.faceImageURL(for: face.fileName)

            guard FileManager.default.fileExists(atPath: localURL.path) else {
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

            } catch {
                print("Face image upload failed: \(face.fileName)", error)
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

        return remoteURL
    }

    func insertRoutineTask(_ task: RoutineTask) async {
        guard let caregiverUid = SessionManager.shared.activeCaregiverUid else { return }
        var scopedTask = task
        scopedTask.caregiverUid = caregiverUid

        do {
            try await client
                .from("RoutineTask")
                .upsert(scopedTask, onConflict: "id")
                .execute()
        } catch {
            print("RoutineTask upsert failed:", error)
        }
    }

    func updateRoutineTask(_ task: RoutineTask) async {
        do {
            try await client
                .from("RoutineTask")
                .update(task)
                .eq("id", value: task.id)
                .execute()
        } catch {
            print("RoutineTask update failed:", error)
        }
    }

    func deleteRoutineTask(id: UUID) async {
        do {
            try await client
                .from("RoutineTask")
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            print("RoutineTask delete failed:", error)
        }
    }

    func updateRoutineTaskCompletion(_ task: RoutineTask) async {

        struct CompletionUpdate: Encodable {
            let completedDates: [String]
            let isCompleted: Bool
        }

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone.current

        for d in task.completedDates {
        }

        let dateStrings = task.completedDates.map { df.string(from: $0) }

        do {
            try await client
                .from("RoutineTask")
                .update(CompletionUpdate(
                    completedDates: dateStrings,
                    isCompleted: task.isCompleted
                ))
                .eq("id", value: task.id)
                .execute()
        } catch {
            print("RoutineTask completion sync failed:", error)
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
            return tasks
        } catch {
            print("Routine restore failed:", error)
            return []
        }
    }

    func connectCaregiverToPatient(
        patientEmail: String,
        caregiverUid: UUID,
        caregiverRelation: String
    ) async throws {

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

        try await client
            .from("UserProfile")
            .update([
                "caregiverUid": caregiverUid.uuidString,
                "caregiverRelation": caregiverRelation
            ])
            .eq("email", value: patientEmail)
            .execute()

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

    func sendOTP(email: String) async throws {
        try await client.auth.signInWithOTP(
            email: email
        )
    }

    func verifyOTP(email: String, otp: String) async throws {
        try await client.auth.verifyOTP(
            email: email,
            token: otp,
            type: .email
        )
    }

    func createUserProfile(_ profile: UserProfile) async throws {
        try await client
            .from("UserProfile")
            .insert(profile)
            .execute()
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
        let allFaces = FaceStore.shared.loadAllFaces()

        for face in allFaces {
            let localURL = FaceStore.shared.faceImageURL(for: face.fileName)

            guard FileManager.default.fileExists(atPath: localURL.path) else {
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
            } catch {
                print("Face image upload failed:", face.fileName, error)
            }
        }
    }

    func fetchPatientProfile(caregiverUid: UUID) async throws -> UserProfile? {
        let results: [UserProfile] = try await client
            .from("UserProfile")
            .select()
            .eq("caregiverUid", value: caregiverUid)
            .eq("role", value: "patient")
            .execute()
            .value
        return results.first
    }

}
