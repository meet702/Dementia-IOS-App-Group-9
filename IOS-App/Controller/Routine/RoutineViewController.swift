//
//  ViewController.swift
//  TempApp
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class RoutineViewController: UIViewController, UITableViewDataSource, UICollectionViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return morningTasks.count
            case 1: return afternoonTasks.count
            case 2: return eveningTasks.count
            default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "task_cell", for: indexPath) as! TaskTableViewCell
        var task: TaskModel

        switch indexPath.section {
        case 0: task = morningTasks[indexPath.row]
        case 1: task = afternoonTasks[indexPath.row]
        case 2: task = eveningTasks[indexPath.row]
        default: fatalError("Invalid section")
        }

        cell.configure(task: task)

        cell.onCheckTapped = {
            task.isCompleted.toggle()
            DataStore.shared.updateRoutine(for: self.selectedDate, task: task)
            
            self.splitTasksByTime()
            tableView.reloadData()
        }

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         switch section {
         case 0: return "Morning"
         case 1: return "Afternoon"
         case 2: return "Evening"
         default: return nil
         }
     }
    
    

    @IBOutlet weak var routineCollectionView: UICollectionView!
    
    @IBOutlet weak var tasksTableView: UITableView!
    
    @IBOutlet weak var addTaskButtonOutlet: UIButton!
    
        
    var dates: [DateModel] = []
    var selectedDate: Date = Date()
    var morningTasks: [TaskModel] = []
    var afternoonTasks: [TaskModel] = []
    var eveningTasks: [TaskModel] = []

    func splitTasksByTime() {
        let tasks = DataStore.shared.getRoutines(for: selectedDate)
        
        func timeSort(_ t1: TaskModel, _ t2: TaskModel) -> Bool {
            let c1 = Calendar.current.dateComponents([.hour, .minute], from: t1.time)
            let c2 = Calendar.current.dateComponents([.hour, .minute], from: t2.time)

            return (c1.hour ?? 0, c1.minute ?? 0) <
                   (c2.hour ?? 0, c2.minute ?? 0)
        }
        
        morningTasks = tasks.filter { task in
            let hour = Calendar.current.component(.hour, from: task.time)
            return hour >= 5 && hour < 12
        }.sorted(by: timeSort)
        
        afternoonTasks = tasks.filter { task in
            let hour = Calendar.current.component(.hour, from: task.time)
            return hour >= 12 && hour < 17
        }.sorted(by: timeSort)
        
        eveningTasks = tasks.filter { task in
            let hour = Calendar.current.component(.hour, from: task.time)
            return hour >= 17 || hour < 5
        }.sorted(by: timeSort)
    }

    func autoSelectToday() {
        if let index = dates.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: Date()) }) {

            selectedDate = dates[index].date

            DispatchQueue.main.async {
                let indexPath = IndexPath(item: index, section: 0)
                self.routineCollectionView.scrollToItem(
                    at: indexPath,
                    at: .centeredHorizontally,
                    animated: false
                )
                self.routineCollectionView.selectItem(
                    at: indexPath,
                    animated: false,
                    scrollPosition: []
                )
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        
        routineCollectionView.dataSource = self
        routineCollectionView.delegate = self

        tasksTableView.dataSource = self
        tasksTableView.delegate = self

        routineCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        
        dates = DataStore.shared.getDates()
        autoSelectToday()
        splitTasksByTime()
        
    }
    
    func registerCells(){
        routineCollectionView.register(UINib(nibName: "CalendarCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendar_cell")
    }
    
    // generate layout for calendar cells
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { section, env in
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(60),
                heightDimension: .absolute(70)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .estimated(400),
                heightDimension: .absolute(100)
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: 7
            )

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 0, bottom: 30, trailing: 0)

            return section
        }
        return layout
    }
    
    
    @IBAction func addTaskButton(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddEditTaskTableViewController") as! AddEditTaskTableViewController
        vc.selectedDate = selectedDate
        vc.delegate = self
        vc.mode = .add
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        
        present(nav, animated: true)
    }



}

// calendar collection view things
extension RoutineViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dates.count       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = routineCollectionView.dequeueReusableCell(withReuseIdentifier: "calendar_cell", for: indexPath) as! CalendarCollectionViewCell

        let model = dates[indexPath.row]
        let isSelected = Calendar.current.isDate(model.date, inSameDayAs: selectedDate)
        let isToday = Calendar.current.isDate(model.date, inSameDayAs: Date())
        cell.configure(with: model, isSelected: isSelected, isToday: isToday)

        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDate = dates[indexPath.item].date
        splitTasksByTime()
        routineCollectionView.reloadData()
        tasksTableView.reloadData()
    }
    
}


// routine tasks functionalities
extension RoutineViewController: AddEditTaskDelegate, UITableViewDelegate {
    func stopRecurringTasks(from task: TaskModel) {
        guard let recurrenceID = task.recurrenceID else { return }

        for dateModel in dates {
            let date = dateModel.date
            if date >= selectedDate {
                let tasks = DataStore.shared.getRoutines(for: date)
                if let index = tasks.firstIndex(where: { $0.recurrenceID == recurrenceID }) {
                    DataStore.shared.deleteRoutine(for: date, at: index)
                }
            }
        }
        splitTasksByTime()
        tasksTableView.reloadData()
    }
    
    
    func combine(date: Date, time: Date) -> Date {
        let calendar = Calendar.current

        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute

        return calendar.date(from: combined) ?? Date()
    }

    /*
    func didCreateRecurringTasks(from task: TaskModel) {
        guard let recurrenceID = task.recurrenceID else { return }

        _ = Calendar.current

            for dateModel in dates {
                let date = dateModel.date
                
                if date > selectedDate {
                    let combinedTime = combine(date: date, time: task.time)
                    
                    let newTask = TaskModel(
                        title: task.title,
                        description: task.description,
                        time: combinedTime,
                        isCompleted: false,
                        isRecurring: true,
                        recurrenceID: recurrenceID
                    )
                    
                    DataStore.shared.addRoutine(for: date, routine: newTask)
                }
            }

            splitTasksByTime()
            tasksTableView.reloadData()
    }
    */
     
    func didCreateRecurringTasks(from task: TaskModel, startingAt startDate: Date) {
        guard let recurrenceID = task.recurrenceID else { return }
        
        for dateModel in dates {
            let date = dateModel.date
            
            // Only create tasks for startDate and future dates
            if date >= startDate {
                
                // Prevent duplicates
                let tasksOnDay = DataStore.shared.getRoutines(for: date)
                let alreadyExists = tasksOnDay.contains { existing in
                    existing.recurrenceID == recurrenceID
                }
                if alreadyExists { continue }
                
                // Combine correct date + time
                let combinedDate = combine(date: date, time: task.time)
                
                let newTask = TaskModel(
                    title: task.title,
                    description: task.description,
                    time: combinedDate,
                    isCompleted: false,
                    isRecurring: true,
                    recurrenceID: recurrenceID
                )
                
                DataStore.shared.addRoutine(for: date, task: newTask)
            }
        }
        
        splitTasksByTime()
        tasksTableView.reloadData()
    }

    func didAddTask(_ task: TaskModel, on date: Date) {
        DataStore.shared.addRoutine(for: date, task: task)
        selectedDate = date
        splitTasksByTime()
        tasksTableView.reloadData()
        routineCollectionView.reloadData()
    }
    
    
    func didUpdateTask(_ updatedTask: TaskModel, on date: Date) {
        DataStore.shared.updateRoutine(for: date, task: updatedTask)
        if updatedTask.isRecurring, let recurrenceID = updatedTask.recurrenceID {
            _ = Calendar.current
            for dateModel in dates {
                let futureDate = dateModel.date
                if futureDate >= date {
                    let tasks = DataStore.shared.getRoutines(for: futureDate)
                    if let index = tasks.firstIndex(where: { $0.recurrenceID == recurrenceID }) {
                        var taskToUpdate = tasks[index]
                        taskToUpdate.title = updatedTask.title
                        taskToUpdate.description = updatedTask.description
                        taskToUpdate.time = updatedTask.time
                        DataStore.shared.updateRoutine(for: futureDate, task: taskToUpdate)
                    }
                }
            }
        }
        selectedDate = date
        splitTasksByTime()
        tasksTableView.reloadData()
        routineCollectionView.reloadData()
    }

    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let task = getTaskAt(indexPath)
        let isPast = Calendar.current.compare(selectedDate, to: Date(), toGranularity: .day) == .orderedAscending
        var actions: [UIContextualAction] = []
        if !isPast {
            let edit = UIContextualAction(style: .normal, title: "Edit") { _, _, complete in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddEditTaskTableViewController") as! AddEditTaskTableViewController
                
                //vc.selectedDate = self.selectedDate
                
                vc.delegate = self
                vc.mode = .edit(task)
                vc.originalTaskDate = self.selectedDate
                
                
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .pageSheet
                self.present(nav, animated: true)
                
                complete(true)
            }
            actions.append(edit)
        }

        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, complete in
            let allTasks = DataStore.shared.getRoutines(for: self.selectedDate)

            if let index = allTasks.firstIndex(where: { $0.id == task.id }) {
                DataStore.shared.deleteRoutine(for: self.selectedDate, at: index)
            }

            self.splitTasksByTime()
            tableView.reloadData()
            complete(true)
        }
        actions.append(delete)
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    /*
    func getTaskAt(_ indexPath: IndexPath) -> TaskModel {
        switch indexPath.section {
        case 0: return morningTasks[indexPath.row]
        case 1: return afternoonTasks[indexPath.row]
        case 2: return eveningTasks[indexPath.row]
        default: fatalError()
        }
    }
     */
    
    func getTaskAt(_ indexPath: IndexPath) -> TaskModel {
        let allTasks = DataStore.shared.getRoutines(for: selectedDate)

        let task: TaskModel
        switch indexPath.section {
        case 0:
            task = morningTasks[indexPath.row]
        case 1:
            task = afternoonTasks[indexPath.row]
        case 2:
            task = eveningTasks[indexPath.row]
        default:
            fatalError("Invalid section")
        }
        return allTasks.first(where: { $0.id == task.id })!
    }

    
    
}

