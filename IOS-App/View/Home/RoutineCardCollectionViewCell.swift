//import UIKit
//
//final class RoutineCardCollectionViewCell: UICollectionViewCell {
//
//    @IBOutlet weak var cardView: UIView!         // rounded white background
//    @IBOutlet weak var stackView: UIStackView!   // vertical stack inside card
//
//    private let cornerRadius: CGFloat = 34
//    private let dividerInset: CGFloat = 12
//    private let dividerTag = 999
//
//    private lazy var timeFormatter: DateFormatter = {
//        let f = DateFormatter()
//        f.dateStyle = .none
//        f.timeStyle = .short
//        return f
//    }()
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        backgroundColor = .clear
//        contentView.backgroundColor = .clear
//
//        cardView.layer.cornerRadius = cornerRadius
//        cardView.clipsToBounds = true
//        cardView.backgroundColor = .white
//
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOpacity = 0.12
//        layer.shadowOffset = CGSize(width: 0, height: 4)
//        layer.shadowRadius = 8
//        layer.masksToBounds = false
//
//        stackView.axis = .vertical
//        stackView.spacing = 12
//        stackView.alignment = .fill
//        stackView.distribution = .fill
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
//    }
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        stackView.arrangedSubviews.forEach { view in
//            stackView.removeArrangedSubview(view)
//            view.removeFromSuperview()
//        }
//    }
//
//    func configureRoutineCell(tasks: [TaskModel], date: Date = Date()) {
//
//        stackView.arrangedSubviews.forEach {
//            stackView.removeArrangedSubview($0)
//            $0.removeFromSuperview()
//        }
//
//        let sortedTasks = sortTasksByTime(tasks)
//
//        let allTasks = sortedTasks
//
//        let morning = morningTasks(from: allTasks)
//        let afternoon = afternoonTasks(from: allTasks)
//        let evening = eveningTasks(from: allTasks)
//
//        let period = Self.currentPeriod(for: date)
//
//        var periodTasks: [TaskModel] = []
//
//        switch period {
//        case .morning:
//            periodTasks = morning
//        case .afternoon:
//            periodTasks = afternoon
//        case .evening:
//            periodTasks = evening
//        }
//
//        let periodPending = pendingTasks(from: periodTasks)
//        let periodCompleted = completedTasks(from: periodTasks)
//
//        addSection(title: "Upcoming", items: periodPending, placeholder: "No pending tasks")
//        addSection(title: "Completed", items: periodCompleted, placeholder: "No tasks completed yet")
//
//        removeTrailingDividerIfNeeded()
//    }
//
//    private func addSection(title: String, items: [TaskModel], placeholder: String) {
//        addSectionHeader(title: title)
//
//        let container = UIView()
//        container.translatesAutoresizingMaskIntoConstraints = false
//        container.backgroundColor = UIColor(white: 0.95, alpha: 1)
//        container.layer.cornerRadius = 20
//        container.clipsToBounds = true
//        container.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        container.setContentCompressionResistancePriority(.required, for: .vertical)
//
//        let innerStack = UIStackView()
//        innerStack.axis = .vertical
//        innerStack.spacing = 0
//        innerStack.alignment = .fill
//        innerStack.distribution = .fill
//        innerStack.translatesAutoresizingMaskIntoConstraints = false
//        innerStack.isLayoutMarginsRelativeArrangement = true
//        innerStack.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
//        innerStack.setContentHuggingPriority(.required, for: .vertical)
//        innerStack.setContentCompressionResistancePriority(.required, for: .vertical)
//
//        container.addSubview(innerStack)
//        NSLayoutConstraint.activate([
//            innerStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
//            innerStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
//            innerStack.topAnchor.constraint(equalTo: container.topAnchor),
//            innerStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
//        ])
//
//        if items.isEmpty {
//            let placeholderRow = UIView()
//            placeholderRow.translatesAutoresizingMaskIntoConstraints = false
//            placeholderRow.backgroundColor = .clear
//
//            let label = UILabel()
//            label.text = placeholder
//            label.font = UIFont.systemFont(ofSize: 14)
//            label.textColor = UIColor(white: 0.45, alpha: 1)
//            label.translatesAutoresizingMaskIntoConstraints = false
//
//            placeholderRow.addSubview(label)
//            NSLayoutConstraint.activate([
//                label.leadingAnchor.constraint(equalTo: placeholderRow.leadingAnchor, constant: 0),
//                label.trailingAnchor.constraint(lessThanOrEqualTo: placeholderRow.trailingAnchor, constant: 0),
//                label.topAnchor.constraint(equalTo: placeholderRow.topAnchor, constant: 12),
//                label.bottomAnchor.constraint(equalTo: placeholderRow.bottomAnchor, constant: -12),
//                placeholderRow.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
//            ])
//
//            innerStack.addArrangedSubview(placeholderRow)
//        } else {
//            for (index, item) in items.enumerated() {
//                let row = makeTransparentRow(for: item)
//                innerStack.addArrangedSubview(row)
//
//                if index < items.count - 1 {
//                    let div = UIView()
//                    div.translatesAutoresizingMaskIntoConstraints = false
//                    div.backgroundColor = UIColor(white: 0.85, alpha: 1)
//                    innerStack.addArrangedSubview(div)
//                    NSLayoutConstraint.activate([
//                        div.heightAnchor.constraint(equalToConstant: 1),
//                        div.leadingAnchor.constraint(equalTo: innerStack.layoutMarginsGuide.leadingAnchor),
//                        div.trailingAnchor.constraint(equalTo: innerStack.layoutMarginsGuide.trailingAnchor)
//                    ])
//                }
//            }
//        }
//        stackView.addArrangedSubview(container)
//    }
//
//    private func makeTransparentRow(for item: TaskModel) -> UIView {
//        let row = UIView()
//        row.translatesAutoresizingMaskIntoConstraints = false
//        row.backgroundColor = .clear
//
//        let titleLabel = UILabel()
//        titleLabel.font = UIFont.systemFont(ofSize: 15)
//        titleLabel.text = item.title
//        titleLabel.numberOfLines = 1
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        let timeLabel = UILabel()
//        timeLabel.font = UIFont.systemFont(ofSize: 14)
//        timeLabel.text = timeFormatter.string(from: item.time)
//        timeLabel.textAlignment = .right
//        timeLabel.translatesAutoresizingMaskIntoConstraints = false
//        if item.isCompleted {
//            titleLabel.textColor = .gray
//            timeLabel.textColor = .gray
//        } else {
//            titleLabel.textColor = .black
//            timeLabel.textColor = .black
//        }
//        
//        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
//        timeLabel.setContentCompressionResistancePriority(.required, for: .vertical)
//        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        timeLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//
//        row.addSubview(titleLabel)
//        row.addSubview(timeLabel)
//
//        if let sub = item.description, !sub.isEmpty {
//            let subtitleLabel = UILabel()
//            subtitleLabel.font = UIFont.systemFont(ofSize: 12)
//            subtitleLabel.textColor = UIColor(white: 0.55, alpha: 1)
//            subtitleLabel.text = sub
//            subtitleLabel.numberOfLines = 0
//            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
//
//            subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
//            subtitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
//
//            row.addSubview(subtitleLabel)
//
//            NSLayoutConstraint.activate([
//                titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 12),
//                titleLabel.topAnchor.constraint(equalTo: row.topAnchor, constant: 8),
//
//                subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
//                subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -8),
//
//                timeLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -12),
//                timeLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: 6),
//
//                subtitleLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -8),
//
//                row.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
//            ])
//        } else {
//            NSLayoutConstraint.activate([
//                titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 12),
//                titleLabel.topAnchor.constraint(equalTo: row.topAnchor, constant: 8),
//                titleLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -8),
//
//                timeLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -12),
//                timeLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
//
//                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -8),
//
//                row.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
//            ])
//        }
//
//        row.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        row.setContentCompressionResistancePriority(.required, for: .vertical)
//
//        return row
//    }
//
//
//
//
//    private func addSectionHeader(title: String) {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
//        label.text = title
//        label.textColor = .black
//        label.translatesAutoresizingMaskIntoConstraints = false
//
//        let container = UIView()
//        container.translatesAutoresizingMaskIntoConstraints = false
//        container.addSubview(label)
//        label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12).isActive = true
//        label.topAnchor.constraint(equalTo: container.topAnchor, constant: 2).isActive = true
//        label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -2).isActive = true
//        stackView.addArrangedSubview(container)
//    }
//
//    private func addDivider() {
//        let d = UIView()
//        d.translatesAutoresizingMaskIntoConstraints = false
//        d.backgroundColor = UIColor(white: 0.90, alpha: 1)
//        d.tag = dividerTag
//        stackView.addArrangedSubview(d)
//        let scale = traitCollection.displayScale
//        NSLayoutConstraint.activate([
//            d.heightAnchor.constraint(equalToConstant: 1.0 / scale),
//            d.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: dividerInset),
//            d.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -dividerInset)
//        ])
//    }
//
//    private func removeTrailingDividerIfNeeded() {
//        if let last = stackView.arrangedSubviews.last, last.tag == dividerTag {
//            stackView.removeArrangedSubview(last)
//            last.removeFromSuperview()
//        }
//    }
//
//    private enum Period {
//        case morning, afternoon, evening
//    }
//
//    private static func isInMorning(_ date: Date) -> Bool {
//        let hour = Calendar.current.component(.hour, from: date)
//        return hour >= 5 && hour < 12
//    }
//
//    private static func isInAfternoon(_ date: Date) -> Bool {
//        let hour = Calendar.current.component(.hour, from: date)
//        return hour >= 12 && hour < 17
//    }
//
//    private static func isInEvening(_ date: Date) -> Bool {
//        let hour = Calendar.current.component(.hour, from: date)
//        return hour >= 17 && hour <= 23 || hour < 5
//    }
//
//    private static func currentPeriod(for date: Date) -> Period {
//        let hour = Calendar.current.component(.hour, from: date)
//        if hour >= 5 && hour < 12 { return .morning }
//        if hour >= 12 && hour < 17 { return .afternoon }
//        return .evening
//    }
//
//    private func morningTasks(from tasks: [TaskModel]) -> [TaskModel] {
//        var result: [TaskModel] = []
//        for task in tasks {
//            if Self.isInMorning(task.time) {
//                result.append(task)
//            }
//        }
//        return result
//    }
//
//    private func afternoonTasks(from tasks: [TaskModel]) -> [TaskModel] {
//        var result: [TaskModel] = []
//        for task in tasks {
//            if Self.isInAfternoon(task.time) {
//                result.append(task)
//            }
//        }
//        return result
//    }
//
//    private func eveningTasks(from tasks: [TaskModel]) -> [TaskModel] {
//        var result: [TaskModel] = []
//        for task in tasks {
//            if Self.isInEvening(task.time) {
//                result.append(task)
//            }
//        }
//        return result
//    }
//
//    private func pendingTasks(from tasks: [TaskModel]) -> [TaskModel] {
//        var pending: [TaskModel] = []
//
//        for task in tasks {
//            if task.isCompleted == false {
//                pending.append(task)
//            }
//        }
//        return pending
//    }
//
//    private func completedTasks(from tasks: [TaskModel]) -> [TaskModel] {
//        var completed: [TaskModel] = []
//
//        for task in tasks {
//            if task.isCompleted == true {
//                completed.append(task)
//            }
//        }
//        return completed
//    }
//
//    private func sortTasksByTime(_ tasks: [TaskModel]) -> [TaskModel] {
//        var result = tasks
//        let calendar = Calendar.current
//
//        for i in 0..<result.count {
//            for j in 0..<result.count - i - 1 {
//                let t1 = result[j]
//                let t2 = result[j + 1]
//
//                let c1 = calendar.dateComponents([.hour, .minute], from: t1.time)
//                let c2 = calendar.dateComponents([.hour, .minute], from: t2.time)
//
//                let minutes1 = (c1.hour ?? 0) * 60 + (c1.minute ?? 0)
//                let minutes2 = (c2.hour ?? 0) * 60 + (c2.minute ?? 0)
//
//                if minutes1 > minutes2 {
//                    result.swapAt(j, j + 1)
//                }
//                
//                else if minutes1 == minutes2 {
//                    if t1.isCompleted && !t2.isCompleted {
//                        result.swapAt(j, j + 1)
//                    }
//                }
//            }
//        }
//        return result
//    }
//
//
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        setNeedsLayout()
//        layoutIfNeeded()
//
//        let targetSize = CGSize(width: layoutAttributes.bounds.width, height: UIView.layoutFittingCompressedSize.height)
//        let autoLayoutSize = contentView.systemLayoutSizeFitting(
//            targetSize,
//            withHorizontalFittingPriority: .required,
//            verticalFittingPriority: .fittingSizeLevel
//        )
//
//        var newFrame = layoutAttributes.frame
//        newFrame.size.height = ceil(autoLayoutSize.height)
//        layoutAttributes.frame = newFrame
//        return layoutAttributes
//    }
//}


import UIKit

final class RoutineCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var stackView: UIStackView!

    private let cornerRadius: CGFloat = 34
    private let dividerInset: CGFloat = 12
    private let dividerTag = 999
    private var contextDate: Date = Date()
    private let repository = RoutineRepository()

    private lazy var timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.layer.cornerRadius = cornerRadius
        cardView.clipsToBounds = true
        cardView.backgroundColor = .white

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.masksToBounds = false

        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    // MARK: - Public API
    @MainActor
    func configureRoutineCell(tasks: [RoutineTask], date: Date = Date()) {

        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        self.contextDate = Calendar.current.startOfDay(for: date)
        let sortedTasks = sortTasksByTime(tasks)

        let period = Self.currentPeriod(for: date)

        let periodTasks: [RoutineTask] = {
            switch period {
            case .morning:
                return sortedTasks.filter { $0.time.map(Self.isInMorning) ?? false }

            case .afternoon:
                return sortedTasks.filter { $0.time.map(Self.isInAfternoon) ?? false }

            case .evening:
                return sortedTasks.filter { $0.time.map(Self.isInEvening) ?? false }
            }
        }()

        let pending = pendingTasks(from: periodTasks)
        let completed = completedTasks(from: periodTasks)

        addSection(title: "Upcoming",
                   items: pending,
                   placeholder: "No pending tasks")

        addSection(title: "Completed",
                   items: completed,
                   placeholder: "No tasks completed yet")

        removeTrailingDividerIfNeeded()
    }

    // MARK: - Section Builder

    private func addSection(title: String,
                            items: [RoutineTask],
                            placeholder: String) {

        addSectionHeader(title: title)

        let container = UIView()
        container.backgroundColor = UIColor(white: 0.95, alpha: 1)
        container.layer.cornerRadius = 20
        container.clipsToBounds = true

        let innerStack = UIStackView()
        innerStack.axis = .vertical
        innerStack.spacing = 0
        innerStack.translatesAutoresizingMaskIntoConstraints = false
        innerStack.isLayoutMarginsRelativeArrangement = true
        innerStack.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

        container.addSubview(innerStack)

        NSLayoutConstraint.activate([
            innerStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            innerStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            innerStack.topAnchor.constraint(equalTo: container.topAnchor),
            innerStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        if items.isEmpty {
            let label = UILabel()
            label.text = placeholder
            label.font = .systemFont(ofSize: 14)
            label.textColor = UIColor(white: 0.45, alpha: 1)
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false

            let wrapper = UIView()
            wrapper.addSubview(label)

            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
                label.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 12),
                label.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -12)
            ])

            innerStack.addArrangedSubview(wrapper)
        } else {
            for (index, task) in items.enumerated() {
                innerStack.addArrangedSubview(makeTransparentRow(for: task))

                if index < items.count - 1 {
                    let divider = UIView()
                    divider.backgroundColor = UIColor(white: 0.85, alpha: 1)
                    divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
                    innerStack.addArrangedSubview(divider)
                }
            }
        }

        stackView.addArrangedSubview(container)
    }

    // MARK: - Row

    private func makeTransparentRow(for item: RoutineTask) -> UIView {

        let row = UIView()

        let titleLabel = UILabel()
//        titleLabel.font = .systemFont(ofSize: 15)
        titleLabel.font = .preferredFont(forTextStyle: .callout)
        titleLabel.text = item.title ?? ""
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let timeLabel = UILabel()
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textAlignment = .right

        if let time = item.time {
            timeLabel.text = timeFormatter.string(from: time)
        }

        let isCompleted = repository.isTaskCompleted(item, on: contextDate)
        titleLabel.textColor = isCompleted ? .gray : .black
        timeLabel.textColor = isCompleted ? .gray : .black

        row.addSubview(titleLabel)
        row.addSubview(timeLabel)

        if let subtitle = item.subtitle, !subtitle.isEmpty {
            let subtitleLabel = UILabel()
            subtitleLabel.font = .systemFont(ofSize: 12)
            subtitleLabel.textColor = UIColor(white: 0.55, alpha: 1)
            subtitleLabel.text = subtitle
            subtitleLabel.numberOfLines = 0
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

            row.addSubview(subtitleLabel)

            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 12),
                titleLabel.topAnchor.constraint(equalTo: row.topAnchor, constant: 8),

                subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -8),
                subtitleLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -8),

                timeLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -12),
                timeLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 12),
                titleLabel.topAnchor.constraint(equalTo: row.topAnchor, constant: 8),
                titleLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -8),

                timeLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -12),
                timeLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -8)
            ])
        }
        row.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true

        return row
    }

    // MARK: - Helpers (LOGIC UNCHANGED)

    private enum Period { case morning, afternoon, evening }

    private static func currentPeriod(for date: Date) -> Period {
        let hour = Calendar.current.component(.hour, from: date)
        if hour >= 5 && hour < 12 { return .morning }
        if hour >= 12 && hour < 17 { return .afternoon }
        return .evening
    }
    @MainActor
    private func morningTasks(from tasks: [RoutineTask]) -> [RoutineTask] {
        tasks.filter { $0.time.map(Self.isInMorning) ?? false }
    }
    @MainActor
    private func afternoonTasks(from tasks: [RoutineTask]) -> [RoutineTask] {
        tasks.filter { $0.time.map(Self.isInAfternoon) ?? false }
    }
    @MainActor
    private func eveningTasks(from tasks: [RoutineTask]) -> [RoutineTask] {
        tasks.filter { $0.time.map(Self.isInEvening) ?? false }
    }

    private func pendingTasks(from tasks: [RoutineTask]) -> [RoutineTask] {
        tasks.filter { !repository.isTaskCompleted($0, on: contextDate) }
    }

    private func completedTasks(from tasks: [RoutineTask]) -> [RoutineTask] {
        tasks.filter { repository.isTaskCompleted($0, on: contextDate) }
    }

    private func sortTasksByTime(_ tasks: [RoutineTask]) -> [RoutineTask] {
        tasks.sorted {
            guard let t1 = $0.time, let t2 = $1.time else { return false }
            return t1 < t2
        }
    }

    private static func isInMorning(_ date: Date) -> Bool {
        let h = Calendar.current.component(.hour, from: date)
        return h >= 5 && h < 12
    }

    private static func isInAfternoon(_ date: Date) -> Bool {
        let h = Calendar.current.component(.hour, from: date)
        return h >= 12 && h < 17
    }

    private static func isInEvening(_ date: Date) -> Bool {
        let h = Calendar.current.component(.hour, from: date)
        return h >= 17 && h < 24
    }

    private func addSectionHeader(title: String) {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.text = title

        let container = UIView()
        container.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -2)
        ])

        stackView.addArrangedSubview(container)
    }

    private func removeTrailingDividerIfNeeded() {
        if let last = stackView.arrangedSubviews.last, last.tag == dividerTag {
            stackView.removeArrangedSubview(last)
            last.removeFromSuperview()
        }
    }
}
