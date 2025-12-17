//
//  AddEditTaskTableViewController.swift
//  TempApp
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

protocol AddEditTaskDelegate: AnyObject {
    func didAddTask(_ task: TaskModel, on date: Date)
    func didUpdateTask(_ task: TaskModel, on date: Date)
    func didCreateRecurringTasks(from task: TaskModel, startingAt startDate: Date)
    func stopRecurringTasks(from task: TaskModel)

}


class AddEditTaskTableViewController: UITableViewController {
    
    @IBOutlet weak var titleCell: TitleCell!
    
    @IBOutlet weak var notesCell: NotesCell!
    
    @IBOutlet weak var dateCell: DatePickerCell!
    
    @IBOutlet weak var timeCell: TimePickerCell!
    
    @IBOutlet weak var repeatCell: RepeatCell!
    
    var shouldRepeatDaily = false
    
    
    enum TaskMode {
        case add
        case edit(TaskModel)
    }

    var mode: TaskMode = .add
    var selectedDate: Date!
    var originalTaskDate: Date!
    var titleText: String = ""
    var notesText: String = ""
    var selectedDateValue: Date = Date()
    var selectedTimeValue: Date = Date()
    
    weak var delegate: AddEditTaskDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        

        repeatCell.onSwitchChanged = { [weak self] isOn in
            self?.shouldRepeatDaily = isOn
        }
        
        switch mode {
        case .add:
            self.navigationItem.title = "Add Task"

        case .edit(let task):
            self.navigationItem.title = "Edit Task"

            titleText = task.title
            notesText = task.description ?? ""
            selectedDateValue = combine(date: originalTaskDate, time: task.time)
            selectedTimeValue = task.time
            shouldRepeatDaily = task.isRecurring
            dateCell.datePicker.isEnabled = false


        }

        titleCell.titleTextView.text = titleText
        notesCell.notesTextView.text = notesText
        dateCell.datePicker.date = selectedDateValue
        timeCell.timePicker.date = selectedTimeValue
        
        repeatCell.repeatSwitch.isOn = shouldRepeatDaily

        titleCell.onTextChanged = { [weak self] text in self?.titleText = text }
        notesCell.onTextChanged = { [weak self] text in self?.notesText = text }
        dateCell.onDateChanged = { [weak self] date in self?.selectedDateValue = date }
        timeCell.onTimeChanged = { [weak self] time in self?.selectedTimeValue = time }

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(saveTapped),
            
        )

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
    }

    
    @objc func cancelTapped() {
        dismiss(animated: true)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        print("Save tapped:", titleText)

        let finalDate = combine(date: selectedDateValue, time: selectedTimeValue)
        let recurrenceID = shouldRepeatDaily ? UUID() : nil

        let newTask = TaskModel(
            title: titleText,
            description: notesText.isEmpty ? nil : notesText,
            time: finalDate,
            isCompleted: false,
            isRecurring: shouldRepeatDaily,
            recurrenceID: recurrenceID
        )

        switch mode {
        case .add:
            delegate?.didAddTask(newTask, on: selectedDateValue)
            
            if shouldRepeatDaily {
                delegate?.didCreateRecurringTasks(from: newTask, startingAt: selectedDateValue)
            }

        case .edit(var oldTask):
            let wasRecurring = oldTask.isRecurring
            let nowRecurring = shouldRepeatDaily
            
            oldTask.title = titleText
            oldTask.description = notesText
            oldTask.time = selectedTimeValue
            oldTask.isRecurring = nowRecurring

            if wasRecurring && !nowRecurring {
                delegate?.stopRecurringTasks(from: oldTask)
            }
            
            delegate?.didUpdateTask(oldTask, on: selectedDateValue)
        }

        dismiss(animated: true)
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

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return 2
            case 1: return 3
            default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {

        case 0:
            if indexPath.row == 0 { return titleCell }
            else { return notesCell }

        case 1:
            if indexPath.row == 0 { return dateCell }
            else if indexPath.row == 1 { return timeCell }
            else { return repeatCell }

        default:
            fatalError("Unexpected section")
        }
    }

}
