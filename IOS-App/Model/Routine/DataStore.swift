//
//  DataStore.swift
//  TempApp
//
//  Created by SDC-USER on 27/11/25.
//

import Foundation

class DataStore {

    static let shared = DataStore()

    private(set) var dates: [DateModel] = []
    private(set) var routinesByDate: [String: [TaskModel]] = [:]

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private init() {
        generateCalendar()
        loadSampleRoutineData()
    }

    private func generateCalendar() {
        let formatterDay = DateFormatter()
        formatterDay.dateFormat = "EEEEE"

        let formatterDate = DateFormatter()
        formatterDate.dateFormat = "d"

        var tempDates: [DateModel] = []
        let today = Date()

        for diff in (-10...10) {
            let day = Calendar.current.date(byAdding: .day, value: diff, to: today)!
            tempDates.append(
                DateModel(
                    date: day,
                    dayString: formatterDay.string(from: day),
                    dateString: formatterDate.string(from: day)
                )
            )
        }

        self.dates = tempDates
    }

    //sample routine data
    private func loadSampleRoutineData() {

        for (i, dateModel) in dates.enumerated() {
            let key = dateFormatter.string(from: dateModel.date)

            if i == 10 {
                routinesByDate[key] = [
                    TaskModel(title: "Brush teeth", description: nil, time: makeTime(hour: 7, minute: 45), isCompleted: false),
                    TaskModel(title: "Have breakfast", description: nil, time: makeTime(hour: 8, minute: 00), isCompleted: false),
                    TaskModel(title: "Take meds", description: "Vitamin B12 – 1 capsule", time: makeTime(hour: 8, minute: 45), isCompleted: false),
                    
                    TaskModel(title: "Have lunch", description: nil, time: makeTime(hour: 13, minute: 00), isCompleted: false),
                    TaskModel(title: "Visit the dentist", description: nil, time: makeTime(hour: 14, minute: 30), isCompleted: false),
                    TaskModel(title: "Meet Purv", description: "At Gandhi Park", time: makeTime(hour: 16, minute: 00), isCompleted: false),
                    
                    TaskModel(title: "Evening walk", description: nil, time: makeTime(hour: 18, minute: 00), isCompleted: false),
                    TaskModel(title: "Have dinner", description: nil, time: makeTime(hour: 19, minute: 45), isCompleted: false),
                    TaskModel(title: "Take meds", description: "Sleep aid – 1 capsule", time: makeTime(hour: 20, minute: 45), isCompleted: false)
                ]
            } else if i < 10 {
                routinesByDate[key] = [
                    TaskModel(title: "Brush teeth", description: nil, time: makeTime(hour: 7, minute: 45), isCompleted: true),
                    TaskModel(title: "Have breakfast", description: nil, time: makeTime(hour: 8, minute: 00), isCompleted: true),
                    TaskModel(title: "Take meds", description: "Vitamin B12 – 1 capsule", time: makeTime(hour: 8, minute: 45), isCompleted: true),
                    
                    TaskModel(title: "Have lunch", description: nil, time: makeTime(hour: 13, minute: 00), isCompleted: true),
                    
                    TaskModel(title: "Evening walk", description: nil, time: makeTime(hour: 18, minute: 00), isCompleted: true),
                    TaskModel(title: "Have dinner", description: nil, time: makeTime(hour: 19, minute: 45), isCompleted: true),
                    TaskModel(title: "Take meds", description: "Sleep aid – 1 capsule", time: makeTime(hour: 20, minute: 45), isCompleted: true)
                ]
            } else {
                routinesByDate[key] = [
                    TaskModel(title: "Brush teeth", description: nil, time: makeTime(hour: 7, minute: 45), isCompleted: false),
                    TaskModel(title: "Have breakfast", description: nil, time: makeTime(hour: 8, minute: 00), isCompleted: false),
                    TaskModel(title: "Take meds", description: "Vitamin B12 – 1 capsule", time: makeTime(hour: 8, minute: 45), isCompleted: false),
                    
                    TaskModel(title: "Have lunch", description: nil, time: makeTime(hour: 13, minute: 00), isCompleted: false),
                    
                    TaskModel(title: "Evening walk", description: nil, time: makeTime(hour: 18, minute: 00), isCompleted: false),
                    TaskModel(title: "Have dinner", description: nil, time: makeTime(hour: 19, minute: 45), isCompleted: false),
                    TaskModel(title: "Take meds", description: "Sleep aid – 1 capsule", time: makeTime(hour: 20, minute: 45), isCompleted: false)
                ]
            }
        }
    }

    func getDates() -> [DateModel] {
        return dates
    }

    func getRoutines(for date: Date) -> [TaskModel] {
        let key = dateFormatter.string(from: date)
        return routinesByDate[key] ?? []
    }

    
    func updateRoutine(for date: Date, task: TaskModel) {
        let key = dateFormatter.string(from: date)
        guard var tasks = routinesByDate[key] else { return }

        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            tasks.sort { t1, t2 in
                let c1 = Calendar.current.dateComponents([.hour, .minute], from: t1.time)
                let c2 = Calendar.current.dateComponents([.hour, .minute], from: t2.time)

                return (c1.hour ?? 0, c1.minute ?? 0) < (c2.hour ?? 0, c2.minute ?? 0)
            }
            routinesByDate[key] = tasks
            NotificationCenter.default.post(name: .DataStoreDidUpdateRoutines, object: nil, userInfo: ["dateKey": key])
        }

    }

    
    func addRoutine(for date: Date, task: TaskModel) {
        let key = dateFormatter.string(from: date)
        if routinesByDate[key] == nil {
            routinesByDate[key] = []
        }
        routinesByDate[key]!.append(task)
        routinesByDate[key]?.sort { t1, t2 in
            let c1 = Calendar.current.dateComponents([.hour, .minute], from: t1.time)
            let c2 = Calendar.current.dateComponents([.hour, .minute], from: t2.time)
            
            return (c1.hour ?? 0, c1.minute ?? 0) < (c2.hour ?? 0, c2.minute ?? 0)
        }
        NotificationCenter.default.post(name: .DataStoreDidUpdateRoutines, object: nil, userInfo: ["dateKey": key])
    }

    func deleteRoutine(for date: Date, at index: Int) {
        let key = dateFormatter.string(from: date)
        guard routinesByDate[key] != nil else { return }
        routinesByDate[key]!.remove(at: index)
        NotificationCenter.default.post(name: .DataStoreDidUpdateRoutines, object: nil, userInfo: ["dateKey": key])
    }

    
    func makeTime(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }


}

extension Notification.Name {
    static let DataStoreDidUpdateRoutines = Notification.Name("DataStoreDidUpdateRoutines")
}
