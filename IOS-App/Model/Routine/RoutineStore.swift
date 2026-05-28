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

        Task {
            await SupabaseSyncManager.shared.updateRoutineTask(updated)
        }
    }

    func delete(_ task: RoutineTask) {
        tasks.removeAll { $0.id == task.id }
        save()

        Task {
            await SupabaseSyncManager.shared.deleteRoutineTask(id: task.id)
        }
    }

    func isTaskCompleted(_ task: RoutineTask, on date: Date) -> Bool {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: Date())
        if day < today { return true }

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone.current
        let dayString = df.string(from: date)

        return task.completedDates.contains {
            df.string(from: $0) == dayString
        }
    }

    func toggleCompletion(task: RoutineTask, date: Date) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone.current
        let dayString = df.string(from: date)

        let utcDf = DateFormatter()
        utcDf.dateFormat = "yyyy-MM-dd"
        utcDf.timeZone = TimeZone(identifier: "UTC") ?? TimeZone.current
        guard let utcDate = utcDf.date(from: dayString) else { return }

        let alreadyCompleted = tasks[index].completedDates.contains {
            df.string(from: $0) == dayString
        }

        if alreadyCompleted {
            tasks[index].completedDates.removeAll {
                df.string(from: $0) == dayString
            }
            tasks[index].isCompleted = false
        } else {
            tasks[index].completedDates.append(utcDate)
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

        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = minute

        return calendar.date(from: components) ?? Date()
    }

    func replaceAll(with tasks: [RoutineTask]) {
        self.tasks = tasks
        save()
        for task in tasks {
            if !task.completedDates.isEmpty {
            }
        }
    }

    func clearAll() {
        tasks = []
        try? FileManager.default.removeItem(at: fileURL)
    }
}

extension Notification.Name {
    static let DataStoreDidUpdateRoutines =
        Notification.Name("DataStoreDidUpdateRoutines")
}
