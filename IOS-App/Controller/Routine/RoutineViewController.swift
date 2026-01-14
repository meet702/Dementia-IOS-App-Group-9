import UIKit
internal import CoreData

final class RoutineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var routineCollectionView: UICollectionView!
    @IBOutlet weak var tasksTableView: UITableView!
    @IBOutlet weak var addTaskButtonOutlet: UIButton!

    // MARK: - State
    var dates: [DateModel] = []
    var selectedDate: Date = Date()

    var morningTasks: [RoutineTask] = []
    var afternoonTasks: [RoutineTask] = []
    var eveningTasks: [RoutineTask] = []

    let repository = RoutineRepository()
    let context = PersistenceController.shared.context

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        repository.createBaselineRoutineIfNeeded()
        registerCells()
        repository.debugPrintAllTasks()

        routineCollectionView.dataSource = self
        routineCollectionView.delegate = self

        tasksTableView.dataSource = self
        tasksTableView.delegate = self
        tasksTableView.sectionHeaderHeight = UITableView.automaticDimension

        routineCollectionView.setCollectionViewLayout(generateLayout(), animated: false)

        dates = generateDates()
        selectedDate = Date()

//        ensureDailyTasks(for: selectedDate)
        splitTasksByTime()

        tasksTableView.reloadData()

        selectDateInCollectionView(selectedDate, animated: false)
    }

    // MARK: - TABLE VIEW
    func numberOfSections(in tableView: UITableView) -> Int { 3 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return morningTasks.count
        case 1: return afternoonTasks.count
        case 2: return eveningTasks.count
        default: return 0
        }
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "task_cell",
            for: indexPath
        ) as! TaskTableViewCell

        let task = getTaskAt(indexPath)
        let isCompleted = repository.isTaskCompleted(task, on: selectedDate)

        cell.configure(task: task, isCompleted: isCompleted)


        let isToday = Calendar.current.isDateInToday(selectedDate)
        cell.checkButton.isEnabled = isToday
        cell.checkButton.alpha = isToday ? 1.0 : 0.6

        cell.onCheckTapped = { [weak self] in
            guard let self = self, isToday else { return }
            self.repository.toggleCompletion(task: task, date: self.selectedDate)
            self.splitTasksByTime()
            tableView.reloadData()
        }

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        switch section {
        case 0: return "Morning"
        case 1: return "Afternoon"
        case 2: return "Evening"
        default: return nil
        }
    }

    // MARK: - SWIPE ACTIONS
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let task = getTaskAt(indexPath)
        let isPast = Calendar.current.compare(
            selectedDate,
            to: Date(),
            toGranularity: .day
        ) == .orderedAscending

        var actions: [UIContextualAction] = []

        let delete = UIContextualAction(style: .destructive, title: "Delete") {
            [weak self] _, _, complete in
            guard let self = self else { return }

            self.context.delete(task)
            try? self.context.save()

            self.splitTasksByTime()
            tableView.reloadData()
            complete(true)
        }

        actions.append(delete)

        if !isPast {
            let edit = UIContextualAction(style: .normal, title: "Edit") {
                [weak self] _, _, complete in
                guard let self = self else { return }

                let vc = self.storyboard?
                    .instantiateViewController(
                        withIdentifier: "AddEditTaskTableViewController"
                    ) as! AddEditTaskTableViewController

                vc.mode = .edit(task)
                vc.selectedDate = self.selectedDate
                vc.repository = self.repository

                vc.onSave = { [weak self] in
                    self?.splitTasksByTime()
                    self?.tasksTableView.reloadData()
                }

                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .pageSheet
                self.present(nav, animated: true)

                complete(true)
            }

            actions.append(edit)
        }

        return UISwipeActionsConfiguration(actions: actions)
    }

    // MARK: - HELPERS
    private func getTaskAt(_ indexPath: IndexPath) -> RoutineTask {
        switch indexPath.section {
        case 0: return morningTasks[indexPath.row]
        case 1: return afternoonTasks[indexPath.row]
        case 2: return eveningTasks[indexPath.row]
        default: fatalError("Invalid section")
        }
    }

    func splitTasksByTime() {
        let calendar = Calendar.current
        let allTasks = repository.fetchAllTasks()

        let visibleTasks = allTasks.filter { task in
            if task.isRepeatDaily {
                return true
            }

            if let date = task.scheduledDate {
                return calendar.isDate(date, inSameDayAs: selectedDate)
            }

            return false
        }

        morningTasks = visibleTasks.filter {
            guard let time = $0.time else { return false }
            let hour = calendar.component(.hour, from: time)
            return hour >= 5 && hour < 12
        }

        afternoonTasks = visibleTasks.filter {
            guard let time = $0.time else { return false }
            let hour = calendar.component(.hour, from: time)
            return hour >= 12 && hour < 17
        }

        eveningTasks = visibleTasks.filter {
            guard let time = $0.time else { return false }
            let hour = calendar.component(.hour, from: time)
            return hour >= 17 || hour < 5
        }
    }

    func autoSelectToday() {
        if let index = dates.firstIndex(where: {
            Calendar.current.isDate($0.date, inSameDayAs: Date())
        }) {
            selectedDate = dates[index].date

            DispatchQueue.main.async {
                let indexPath = IndexPath(item: index, section: 0)
                self.routineCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
    }

    func generateDates() -> [DateModel] {

        let today = Date()

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEEE"   // M T W T F S S

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"       // 12, 13, 14

        return (-10...10).map { offset in
            let date = Calendar.current.date(
                byAdding: .day,
                value: offset,
                to: today
            )!

            return DateModel(
                date: date,
                dayString: dayFormatter.string(from: date),
                dateString: dateFormatter.string(from: date)
            )
        }
    }


    func registerCells() {
        routineCollectionView.register(
            UINib(nibName: "CalendarCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "calendar_cell"
        )
    }

    func generateLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let item = NSCollectionLayoutItem(
                layoutSize: .init(
                    widthDimension: .absolute(48),
                    heightDimension: .absolute(70)
                )
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(
                    widthDimension: .estimated(400),
                    heightDimension: .absolute(100)
                ),
                subitems: [item]
            )

            group.interItemSpacing = .fixed(20)

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = .init(top: 10, leading: 0, bottom: 4, trailing: 0)
            return section
        }
    }

    private func showPastDateAlert() {
        let alert = UIAlertController(
            title: "Past Date",
            message: "You can’t add tasks to past dates.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - ACTIONS
    @IBAction func addTaskButton(_ sender: UIButton) {
        let isPast = Calendar.current.compare(
            selectedDate,
            to: Date(),
            toGranularity: .day
        ) == .orderedAscending

        // ❌ Block adding to past
        guard !isPast else {
            showPastDateAlert()
            return
        }

        let vc = storyboard?
            .instantiateViewController(
                withIdentifier: "AddEditTaskTableViewController"
            ) as! AddEditTaskTableViewController

        vc.selectedDate = selectedDate
        vc.repository = repository
        vc.mode = .add

        vc.onSave = { [weak self] in
            self?.splitTasksByTime()
            self?.tasksTableView.reloadData()
        }

        present(UINavigationController(rootViewController: vc), animated: true)
    }
    func selectDateInCollectionView(_ date: Date, animated: Bool) {
        guard let index = dates.firstIndex(where: {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }) else { return }

        let indexPath = IndexPath(item: index, section: 0)

        DispatchQueue.main.async {
            self.routineCollectionView.scrollToItem(
                at: indexPath,
                at: .centeredHorizontally,
                animated: animated
            )

            self.routineCollectionView.selectItem(
                at: indexPath,
                animated: animated,
                scrollPosition: []
            )
        }
    }

}

// MARK: - CALENDAR
extension RoutineViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        dates.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "calendar_cell",
            for: indexPath
        ) as! CalendarCollectionViewCell

        let model = dates[indexPath.row]
        let isSelected = Calendar.current.isDate(model.date, inSameDayAs: selectedDate)
        let isToday = Calendar.current.isDateInToday(model.date)

        cell.configure(
            with: model,
            isSelected: isSelected,
            isToday: isToday
        )

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        selectedDate = dates[indexPath.item].date

//        ensureDailyTasks(for: selectedDate)
        splitTasksByTime()

        tasksTableView.reloadData()

        // 🔑 Re-apply selection after reload
        selectDateInCollectionView(selectedDate, animated: true)
    }

}

