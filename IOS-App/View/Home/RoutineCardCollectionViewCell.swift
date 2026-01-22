
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
            label.font = .preferredFont(forTextStyle: .callout)
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

    private func makeTransparentRow(for item: RoutineTask) -> UIView {

        let row = UIView()

        let titleLabel = UILabel()
        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.text = item.title ?? ""
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let timeLabel = UILabel()
        timeLabel.font = .preferredFont(forTextStyle: .callout)
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
            subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
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
        let calendar = Calendar.current

        return tasks.sorted {
            guard let d1 = $0.time, let d2 = $1.time else { return false }

            let c1 = calendar.dateComponents([.hour, .minute], from: d1)
            let c2 = calendar.dateComponents([.hour, .minute], from: d2)

            let m1 = (c1.hour ?? 0) * 60 + (c1.minute ?? 0)
            let m2 = (c2.hour ?? 0) * 60 + (c2.minute ?? 0)

            return m1 < m2
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
        label.font = .preferredFont(forTextStyle: .headline)
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
