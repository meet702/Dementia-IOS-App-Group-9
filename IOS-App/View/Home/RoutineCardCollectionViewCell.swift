import UIKit

final class RoutineCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cardView: UIView!         // rounded white background
    @IBOutlet weak var stackView: UIStackView!   // vertical stack inside card

    // appearance constants
    private let cornerRadius: CGFloat = 34
    private let dividerInset: CGFloat = 12
    private let dividerTag = 999

    // time formatter for the right-hand label
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

        // card rounded and clipping
        cardView.layer.cornerRadius = cornerRadius
        cardView.clipsToBounds = true
        cardView.backgroundColor = .white

        // cell shadow (drawn by cell's layer)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.masksToBounds = false

        // stack view default config
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // sync shadow path to rounded card shape for crisp shadow
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // remove arranged subviews to avoid duplicates
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    func configureRoutineCell(tasks: [TaskModel], date: Date = Date()) {

        // clear old UI
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        // STEP 1: sort tasks
        let sortedTasks = sortTasksByTime(tasks)

        // STEP 2: split pending / completed
        let pending = pendingTasks(from: sortedTasks)
        let completed = completedTasks(from: sortedTasks)

        // STEP 3: combine for time-of-day grouping
        var allTasks: [TaskModel] = []
        allTasks.append(contentsOf: pending)
        allTasks.append(contentsOf: completed)

        let morning = morningTasks(from: allTasks)
        let afternoon = afternoonTasks(from: allTasks)
        let evening = eveningTasks(from: allTasks)

        // STEP 4: decide current period
        let period = Self.currentPeriod(for: date)

        var periodTasks: [TaskModel] = []

        switch period {
        case .morning:
            periodTasks = morning
        case .afternoon:
            periodTasks = afternoon
        case .evening:
            periodTasks = evening
        }

        // STEP 5: split again for UI
        let periodPending = pendingTasks(from: periodTasks)
        let periodCompleted = completedTasks(from: periodTasks)

        // STEP 6: build UI
        addSection(title: "Upcoming", items: periodPending, placeholder: "No pending tasks")
        addSection(title: "Completed", items: periodCompleted, placeholder: "No tasks completed yet")

        removeTrailingDividerIfNeeded()
    }


    // MARK: - Section builder

    private func addSection(title: String, items: [TaskModel], placeholder: String) {
        addSectionHeader(title: title)

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(white: 0.95, alpha: 1)
        container.layer.cornerRadius = 20
        container.clipsToBounds = true
        container.setContentHuggingPriority(.defaultHigh, for: .vertical)
        container.setContentCompressionResistancePriority(.required, for: .vertical)

        let innerStack = UIStackView()
        innerStack.axis = .vertical
        innerStack.spacing = 0
        innerStack.alignment = .fill
        innerStack.distribution = .fill
        innerStack.translatesAutoresizingMaskIntoConstraints = false
        innerStack.isLayoutMarginsRelativeArrangement = true
        innerStack.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        innerStack.setContentHuggingPriority(.required, for: .vertical)
        innerStack.setContentCompressionResistancePriority(.required, for: .vertical)

        container.addSubview(innerStack)
        NSLayoutConstraint.activate([
            innerStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            innerStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            innerStack.topAnchor.constraint(equalTo: container.topAnchor),
            innerStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        if items.isEmpty {
            let placeholderRow = UIView()
            placeholderRow.translatesAutoresizingMaskIntoConstraints = false
            placeholderRow.backgroundColor = .clear

            let label = UILabel()
            label.text = placeholder
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = UIColor(white: 0.45, alpha: 1)
            label.translatesAutoresizingMaskIntoConstraints = false

            placeholderRow.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: placeholderRow.leadingAnchor, constant: 0),
                label.trailingAnchor.constraint(lessThanOrEqualTo: placeholderRow.trailingAnchor, constant: 0),
                label.topAnchor.constraint(equalTo: placeholderRow.topAnchor, constant: 12),
                label.bottomAnchor.constraint(equalTo: placeholderRow.bottomAnchor, constant: -12),
                placeholderRow.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
            ])

            innerStack.addArrangedSubview(placeholderRow)
        } else {
            for (index, item) in items.enumerated() {
                let row = makeTransparentRow(for: item)
                innerStack.addArrangedSubview(row)

                if index < items.count - 1 {
                    let div = UIView()
                    div.translatesAutoresizingMaskIntoConstraints = false
                    div.backgroundColor = UIColor(white: 0.85, alpha: 1)
                    innerStack.addArrangedSubview(div)
                    NSLayoutConstraint.activate([
                        div.heightAnchor.constraint(equalToConstant: 1),
                        div.leadingAnchor.constraint(equalTo: innerStack.layoutMarginsGuide.leadingAnchor),
                        div.trailingAnchor.constraint(equalTo: innerStack.layoutMarginsGuide.trailingAnchor)
                    ])
                }
            }
        }
        stackView.addArrangedSubview(container)
    }

    private func makeTransparentRow(for item: TaskModel) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.backgroundColor = .clear

        // Title
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.text = item.title
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Time
        let timeLabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.textColor = .black
        timeLabel.text = timeFormatter.string(from: item.time)
        timeLabel.textAlignment = .right
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        // Make labels resist vertical compression so they keep readable heights
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        timeLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        timeLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        row.addSubview(titleLabel)
        row.addSubview(timeLabel)

        if let sub = item.description, !sub.isEmpty {
            // Subtitle case: allow the row to grow with subtitle, but still enforce a minimum
            let subtitleLabel = UILabel()
            subtitleLabel.font = UIFont.systemFont(ofSize: 12)
            subtitleLabel.textColor = UIColor(white: 0.55, alpha: 1)
            subtitleLabel.text = sub
            subtitleLabel.numberOfLines = 0
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

            // stronger priorities for subtitle block
            subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
            subtitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

            row.addSubview(subtitleLabel)

            NSLayoutConstraint.activate([
                // title at top
                titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 12),
                titleLabel.topAnchor.constraint(equalTo: row.topAnchor, constant: 8),

                // subtitle under title
                subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -8),

                // time aligned to the right, vertically centered roughly with the title/subtitle block
                timeLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -12),
                timeLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: 6),

                // bottom anchor for subtitle (defines row height)
                subtitleLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -8),

                // ensure row is at least a minimum even with subtitle present
                row.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
            ])
        } else {
            // No subtitle: enforce compact fixed minimum height so rows don't shrink as you add more
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 12),
                titleLabel.topAnchor.constraint(equalTo: row.topAnchor, constant: 8),
                titleLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -8),

                timeLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -12),
                timeLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -8),

                // Important: explicit minimum so the stack cannot compress the row smaller than this
                row.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
            ])
        }

        // Make the row resist vertical compression relative to other content
        row.setContentHuggingPriority(.defaultHigh, for: .vertical)
        row.setContentCompressionResistancePriority(.required, for: .vertical)

        return row
    }




    private func addSectionHeader(title: String) {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.text = title
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12).isActive = true
        label.topAnchor.constraint(equalTo: container.topAnchor, constant: 2).isActive = true
        label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -2).isActive = true
        stackView.addArrangedSubview(container)
    }

    private func addDivider() {
        let d = UIView()
        d.translatesAutoresizingMaskIntoConstraints = false
        d.backgroundColor = UIColor(white: 0.90, alpha: 1)
        d.tag = dividerTag
        stackView.addArrangedSubview(d)
        NSLayoutConstraint.activate([
            d.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
            d.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: dividerInset),
            d.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -dividerInset)
        ])
    }

    private func removeTrailingDividerIfNeeded() {
        if let last = stackView.arrangedSubviews.last, last.tag == dividerTag {
            stackView.removeArrangedSubview(last)
            last.removeFromSuperview()
        }
    }

    // MARK: - Time of day helpers

    private enum Period {
        case morning, afternoon, evening
    }

    private static func isInMorning(_ date: Date) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        return hour >= 5 && hour < 12
    }

    private static func isInAfternoon(_ date: Date) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        return hour >= 12 && hour < 18
    }

    private static func isInEvening(_ date: Date) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        return hour >= 18 && hour <= 23 || hour < 5
    }

    private static func currentPeriod(for date: Date) -> Period {
        let hour = Calendar.current.component(.hour, from: date)
        if hour >= 5 && hour < 12 { return .morning }
        if hour >= 12 && hour < 18 { return .afternoon }
        return .evening
    }

    private func morningTasks(from tasks: [TaskModel]) -> [TaskModel] {
        var result: [TaskModel] = []
        for task in tasks {
            if Self.isInMorning(task.time) {
                result.append(task)
            }
        }
        return result
    }

    private func afternoonTasks(from tasks: [TaskModel]) -> [TaskModel] {
        var result: [TaskModel] = []
        for task in tasks {
            if Self.isInAfternoon(task.time) {
                result.append(task)
            }
        }
        return result
    }

    private func eveningTasks(from tasks: [TaskModel]) -> [TaskModel] {
        var result: [TaskModel] = []
        for task in tasks {
            if Self.isInEvening(task.time) {
                result.append(task)
            }
        }
        return result
    }

    private func pendingTasks(from tasks: [TaskModel]) -> [TaskModel] {
        var pending: [TaskModel] = []

        for task in tasks {
            if task.isCompleted == false {
                pending.append(task)
            }
        }
        return pending
    }

    private func completedTasks(from tasks: [TaskModel]) -> [TaskModel] {
        var completed: [TaskModel] = []

        for task in tasks {
            if task.isCompleted == true {
                completed.append(task)
            }
        }
        return completed
    }

    private func sortTasksByTime(_ tasks: [TaskModel]) -> [TaskModel] {
        var result = tasks

        for i in 0..<result.count {
            for j in 0..<result.count - i - 1 {
                if result[j].time > result[j + 1].time {
                    let temp = result[j]
                    result[j] = result[j + 1]
                    result[j + 1] = temp
                }
            }
        }
        return result
    }

    
    // MARK: - auto-sizing for compositional layout

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()

        let targetSize = CGSize(width: layoutAttributes.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let autoLayoutSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        var newFrame = layoutAttributes.frame
        newFrame.size.height = ceil(autoLayoutSize.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}
