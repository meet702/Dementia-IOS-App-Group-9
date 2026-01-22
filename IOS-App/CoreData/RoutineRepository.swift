internal import CoreData

final class RoutineRepository {

    private let context = PersistenceController.shared.context
    
    func fetchTasks(for date: Date) -> [RoutineTask] {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)

        let allTasks = fetchAllTasks()

        return allTasks.filter { task in

            if task.isRepeatDaily {
                return true
            }

            if let scheduledDate = task.scheduledDate {
                return calendar.isDate(scheduledDate, inSameDayAs: day)
            }

            return false
        }
    }


    func fetchAllTasks() -> [RoutineTask] {
        let request: NSFetchRequest<RoutineTask> = RoutineTask.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "time", ascending: true)
        ]

        do {
            return try context.fetch(request)
        } catch {
            print("fetchAllTasks failed:", error)
            return []
        }
    }

    // Create
    func createTask(
        title: String,
        subtitle: String?,
        time: Date,
        repeatDaily: Bool,
        scheduledDate: Date?
    ) {
        let task = RoutineTask(context: context)
        task.id = UUID()
        task.title = title
        task.subtitle = subtitle
        task.time = time
        task.isRepeatDaily = repeatDaily
        task.scheduledDate = scheduledDate
        save()
        notifyChange()
    }
    
    // Update
    func updateTask(
        _ task: RoutineTask,
        title: String,
        subtitle: String?,
        time: Date,
        repeatDaily: Bool,
        scheduledDate: Date?
    ) {
        task.title = title
        task.subtitle = subtitle
        task.time = time
        task.isRepeatDaily = repeatDaily
        if let date = scheduledDate {
            task.scheduledDate = Calendar.current.startOfDay(for: date)
        } else {
            task.scheduledDate = nil
        }
        save()
        notifyChange()
    }

    
    func isTaskCompleted(_ task: RoutineTask, on date: Date) -> Bool {
        let day = Calendar.current.startOfDay(for: date)
        let today = Calendar.current.startOfDay(for: Date())

        // All past dates are auto completed
        if day < today {
            return true
        }

        // Check real completion of todays task
        guard let taskId = task.id else { return false }
        return fetchCompletion(taskId: taskId, date: day) != nil
    }

    
    func fetchCompletion(taskId: UUID, date: Date) -> TaskCompletion? {
        let request: NSFetchRequest<TaskCompletion> = TaskCompletion.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "taskId == %@ AND date == %@",
            taskId as CVarArg,
            date as NSDate
        )

        return try? context.fetch(request).first
    }

    // Toggle completion
    func toggleCompletion(task: RoutineTask, date: Date) {
        guard let taskId = task.id else {
            assertionFailure("RoutineTask has no id")
            return
        }

        let day = Calendar.current.startOfDay(for: date)

        if let completion = fetchCompletion(taskId: taskId, date: day) {
            // Uncheck
            context.delete(completion)
        } else {
            // Check
            let completion = TaskCompletion(context: context)
            completion.id = UUID()
            completion.taskId = taskId
            completion.date = day
        }

        try? context.save()
        notifyChange()
    }



    // Delete
    func delete(_ task: RoutineTask) {
        context.delete(task)
        save()
        notifyChange()
    }

    private func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
    
    func makeTime(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        let now = Date()

        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = minute
        components.second = 0

        return calendar.date(from: components)!
    }

    func createBaselineRoutineIfNeeded() {
        let request: NSFetchRequest<RoutineTask> = RoutineTask.fetchRequest()
        if (try? context.count(for: request)) ?? 0 > 0 { return }

        let today = Calendar.current.startOfDay(for: Date())
        let templates: [(String, String?, Int, Int)] = [
            ("Brush teeth", nil, 7, 45),
            ("Have breakfast", nil, 8, 0),
            ("Take meds", "Vitamin B12 – 1 capsule", 8, 45),
            ("Have lunch", nil, 13, 0),
            ("Visit the dentist", nil, 14, 30),
            ("Meet Purv", "At Gandhi Park", 16, 0),
            ("Evening walk", nil, 18, 0),
            ("Have dinner", nil, 19, 45),
            ("Take meds", "Sleep aid – 1 capsule", 20, 45)
        ]

        for t in templates {
            let task = RoutineTask(context: context)
            task.id = UUID()
            task.title = t.0
            task.subtitle = t.1
            task.time = makeTime(hour: t.2, minute: t.3)
            task.isRepeatDaily = true
            task.scheduledDate = today
        }
        save()
    }

    private func notifyChange() {
        NotificationCenter.default.post(
            name: .DataStoreDidUpdateRoutines,
            object: nil
        )
    }
}

extension Notification.Name {
    static let DataStoreDidUpdateRoutines = Notification.Name("DataStoreDidUpdateRoutines")
}
