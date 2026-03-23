
//
//  RoutineStore.swift
//  IOS-App
//
//  Created by SDC-USER on 06/03/26.
//

import Foundation

final class RoutineStore {

    static let shared = RoutineStore()

    private init() {
        load()
    }

    private var tasks: [RoutineTask] = []

    private var fileURL: URL {
        let doc = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        return doc.appendingPathComponent("routine_tasks.json")
    }

    // MARK: Load

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            tasks = []
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            tasks = try JSONDecoder().decode([RoutineTask].self, from: data)
        } catch {
            print("Routine load failed:", error)
            tasks = []
        }
    }

    // MARK: Save

    private func save() {
        do {
            let data = try JSONEncoder().encode(tasks)
            try data.write(to: fileURL)
        } catch {
            print("Routine save failed:", error)
        }

        NotificationCenter.default.post(
            name: .DataStoreDidUpdateRoutines,
            object: nil
        )
    }

    // MARK: Fetch

    func fetchAllTasks() -> [RoutineTask] {
        tasks.sorted { $0.time < $1.time }
    }

    func fetchTasks(for date: Date) -> [RoutineTask] {

        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)

        return tasks.filter { task in
            if task.isRepeatDaily { return true }

            if let scheduledDate = task.scheduledDate {
                return calendar.isDate(scheduledDate, inSameDayAs: day)
            }

            return false
        }
    }

    // MARK: Create

    func createTask(
        title: String,
        subtitle: String?,
        time: Date,
        repeatDaily: Bool,
        scheduledDate: Date?
    ) {

        let task = RoutineTask(
            id: UUID(),
            title: title,
            subtitle: subtitle,
            scheduledDate: scheduledDate,
            time: time,
            isRepeatDaily: repeatDaily,
            completedDates: [],
            isCompleted: false
        )

        tasks.append(task)
        save()
        
        Task {
            await SupabaseSyncManager.shared.insertRoutineTask(task)
        }
    }

    // MARK: Update

    func updateTask(
        _ task: RoutineTask,
        title: String,
        subtitle: String?,
        time: Date,
        repeatDaily: Bool,
        scheduledDate: Date?
    ) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }

        tasks[index].title = title
        tasks[index].subtitle = subtitle
        tasks[index].time = time
        tasks[index].isRepeatDaily = repeatDaily
        tasks[index].scheduledDate = scheduledDate

        let updated = tasks[index]
        save()

        // ✅ Sync to Supabase
        Task {
            await SupabaseSyncManager.shared.updateRoutineTask(updated)
        }
    }

    // MARK: Delete

    func delete(_ task: RoutineTask) {
        tasks.removeAll { $0.id == task.id }
        save()
        
        Task {
            await SupabaseSyncManager.shared.deleteRoutineTask(id: task.id)
        }
    }

    // MARK: Completion

    func isTaskCompleted(_ task: RoutineTask, on date: Date) -> Bool {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: Date())
        if day < today { return true }

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone.current  // IST
        let dayString = df.string(from: date)

        return task.completedDates.contains {
            df.string(from: $0) == dayString
        }
    }

    func toggleCompletion(task: RoutineTask, date: Date) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone.current  // IST for string
        let dayString = df.string(from: date)  // "2026-03-18"

        // ✅ Always store as UTC midnight
        let utcDf = DateFormatter()
        utcDf.dateFormat = "yyyy-MM-dd"
        utcDf.timeZone = TimeZone(identifier: "UTC")!
        let utcDate = utcDf.date(from: dayString)!  // 2026-03-18 00:00:00 +0000

        let alreadyCompleted = tasks[index].completedDates.contains {
            df.string(from: $0) == dayString
        }

        if alreadyCompleted {
            tasks[index].completedDates.removeAll {
                df.string(from: $0) == dayString
            }
            tasks[index].isCompleted = false
        } else {
            tasks[index].completedDates.append(utcDate)  // ✅ UTC midnight
            tasks[index].isCompleted = true
        }

        let updated = tasks[index]
        save()

        Task {
            await SupabaseSyncManager.shared.updateRoutineTaskCompletion(updated)
        }
    }

    private func makeTime(hour: Int, minute: Int) -> Date {

        let calendar = Calendar.current
        let now = Date()

        var components = calendar.dateComponents([.year,.month,.day], from: now)
        components.hour = hour
        components.minute = minute

        return calendar.date(from: components)!
    }
    
    // MARK: - Restore (called from SupabaseSyncManager after reinstall)
    func replaceAll(with tasks: [RoutineTask]) {
        self.tasks = tasks
        save()
        for task in tasks {
            if !task.completedDates.isEmpty {
                print("📦 Restored task \(task.title) with completedDates: \(task.completedDates)")
            }
        }
    }
    
    func clearAll() {
        tasks = []
        try? FileManager.default.removeItem(at: fileURL)
        print("🧹 RoutineStore cleared")
    }
}

extension Notification.Name {
    static let DataStoreDidUpdateRoutines =
        Notification.Name("DataStoreDidUpdateRoutines")
}
