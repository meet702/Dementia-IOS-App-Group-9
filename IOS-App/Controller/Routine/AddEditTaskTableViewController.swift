import UIKit

class AddEditTaskTableViewController: UITableViewController {

    @IBOutlet weak var titleCell: TitleCell!
    @IBOutlet weak var notesCell: NotesCell!
    @IBOutlet weak var dateCell: DatePickerCell!
    @IBOutlet weak var timeCell: TimePickerCell!
    @IBOutlet weak var repeatCell: RepeatCell!

    private var hasChanges = false
    private var originalTitle: String = ""
    private var originalNotes: String = ""
    private var originalDate: Date?
    private var originalTime: Date?
    private var originalRepeatDaily: Bool = false

    var onSave: (() -> Void)?
    var shouldRepeatDaily = false
    var repository: RoutineRepository!

    enum TaskMode {
        case add
        case edit(RoutineTask)
    }

    var mode: TaskMode = .add
    var selectedDate: Date?
    var originalTaskDate: Date?

    private var titleText: String = ""
    private var notesText: String = ""
    private var selectedDateValue: Date = Date()
    private var selectedTimeValue: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if repository == nil {
           repository = RoutineRepository()
       }

        repeatCell.onSwitchChanged = { [weak self] isOn in
            self?.shouldRepeatDaily = isOn
        }

        switch mode {

        case .add:
            navigationItem.title = "Add Task"
            hasChanges = true
            shouldRepeatDaily = false
            selectedDate = Calendar.current.startOfDay(for: selectedDate ?? Date())
            selectedTimeValue = Date()

            dateCell.datePicker.minimumDate = Calendar.current.startOfDay(for: Date())
            dateCell.datePicker.isEnabled = true

        case .edit(let task):
            navigationItem.title = "Edit Task"
            originalTitle = task.title ?? ""
            originalDate = task.scheduledDate
            originalTime = task.time
            originalRepeatDaily = task.isRepeatDaily

            titleText = originalTitle
            hasChanges = false
            
            titleText = task.title ?? ""
            notesText = task.subtitle ?? ""

            
            shouldRepeatDaily = task.isRepeatDaily
            selectedDate = task.scheduledDate ?? selectedDate

            
            selectedTimeValue = task.time ?? Date()
            
            dateCell.datePicker.isEnabled = true
            
            navigationItem.rightBarButtonItem?.isEnabled = true

        }

        titleCell.titleTextView.text = titleText
        notesCell.notesTextView.text = notesText
        dateCell.datePicker.date = selectedDate ?? Date()
        timeCell.timePicker.date = selectedTimeValue
        repeatCell.repeatSwitch.isOn = shouldRepeatDaily

        titleCell.onTextChanged = { [weak self] text in
            guard let self = self else { return }

            self.titleText = text
            self.hasChanges = text != self.originalTitle
            self.updateDoneButtonState()
        }


        notesCell.onTextChanged = { [weak self] text in
            guard let self = self else { return }

            self.notesText = text
            self.hasChanges = text != self.originalNotes
            self.updateDoneButtonState()
            
        }

        dateCell.onDateChanged = { [weak self] date in
            guard let self = self else { return }

            self.selectedDate = date
            self.hasChanges = date != self.originalDate
            self.updateDoneButtonState()
        }

        timeCell.onTimeChanged = { [weak self] time in
            guard let self = self else { return }

            self.selectedTimeValue = time
            self.hasChanges = time != self.originalTime
            self.updateDoneButtonState()
        }
        
        repeatCell.onSwitchChanged = { [weak self] isOn in
            guard let self = self else { return }

            self.shouldRepeatDaily = isOn
            self.hasChanges = isOn != self.originalRepeatDaily
            self.updateDoneButtonState()
        }


        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(saveTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemOrange
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        titleText = titleCell.titleTextView.text ?? ""
        updateDoneButtonState()
    }

    
    private func updateDoneButtonState() {
        let hasTitle = !titleText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty

        let isEnabled = hasChanges && hasTitle
        navigationItem.rightBarButtonItem?.isEnabled = isEnabled
    }

    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        let _ = combine(
            date: selectedDateValue,
            time: selectedTimeValue
        )
        print("SAVING TASK FOR DATE:", selectedDateValue)


        switch mode {

        case .add:
            repository.createTask(
                title: titleText,
                subtitle: notesText.isEmpty ? nil : notesText,
                time: selectedTimeValue,
                repeatDaily: shouldRepeatDaily,
                scheduledDate: shouldRepeatDaily ? nil : selectedDate
            )

        case .edit(let task):
            repository.updateTask(
                task,
                title: titleText,
                subtitle: notesText.isEmpty ? nil : notesText,
                time: selectedTimeValue,
                repeatDaily: shouldRepeatDaily,
                scheduledDate: shouldRepeatDaily ? nil : selectedDate
            )
            
        }
        onSave?()
        dismiss(animated: true)
    }

    private func combine(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let d = calendar.dateComponents([.year, .month, .day], from: date)
        let t = calendar.dateComponents([.hour, .minute], from: time)

        var combined = DateComponents()
        combined.year = d.year
        combined.month = d.month
        combined.day = d.day
        combined.hour = t.hour
        combined.minute = t.minute

        return calendar.date(from: combined) ?? Date()
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 2 }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 2 : 3
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch (indexPath.section, indexPath.row) {
        case (0, 0): return titleCell
        case (0, 1): return notesCell
        case (1, 0): return dateCell
        case (1, 1): return timeCell
        default:     return repeatCell
        }
    }
}
