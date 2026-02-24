import UIKit

final class RoutineCardCaregiver: UICollectionViewCell {

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
        stackView.spacing = 8
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

        // 🔥 ADD ROWS DIRECTLY (no white container)
        if periodTasks.isEmpty {
            let label = UILabel()
            label.text = "No tasks for now"
            label.font = .preferredFont(forTextStyle: .callout)
            label.textColor = .systemGray
            label.textAlignment = .center

            let wrapper = UIView()
            wrapper.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
                label.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 12),
                label.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -12)
            ])

            stackView.addArrangedSubview(wrapper)
        } else {
            for (index, task) in periodTasks.enumerated() {
                stackView.addArrangedSubview(makeTransparentRow(for: task))

                if index < periodTasks.count - 1 {
                    let divider = UIView()
                    divider.backgroundColor = UIColor(white: 0.85, alpha: 1)
                    divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
                    stackView.addArrangedSubview(divider)
                }
            }
        }
    }


    private func makeTransparentRow(for item: RoutineTask) -> UIView {

        let row = UIView()

        // Completion state
        let isCompleted = repository.isTaskCompleted(item, on: contextDate)

        // MARK: - iOS native checkbox
        let checkboxButton = UIButton(type: .system)
        let symbolName = isCompleted ? "checkmark.circle.fill" : "circle"
        checkboxButton.isUserInteractionEnabled = false

        let image = UIImage(
            systemName: symbolName,
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 22,
                weight: .regular
            )
        )

        checkboxButton.setImage(image, for: .normal)
        checkboxButton.tintColor = isCompleted ? .systemOrange : .systemGray3
        checkboxButton.alpha = 0.6
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            checkboxButton.widthAnchor.constraint(equalToConstant: 28),
            checkboxButton.heightAnchor.constraint(equalToConstant: 28)
        ])

        // MARK: - Title
        let titleLabel = UILabel()
        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.text = item.title ?? ""
        titleLabel.textColor = isCompleted ? .systemGray2 : .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // MARK: - Time
        let timeLabel = UILabel()
        timeLabel.font = .preferredFont(forTextStyle: .callout)
        timeLabel.textAlignment = .right
        timeLabel.textColor = isCompleted ? .systemGray2 : .label
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        if let time = item.time {
            timeLabel.text = timeFormatter.string(from: time)
        }

        row.addSubview(checkboxButton)
        row.addSubview(titleLabel)
        row.addSubview(timeLabel)

        // MARK: - Subtitle (optional)
        if let subtitle = item.subtitle, !subtitle.isEmpty {
            let subtitleLabel = UILabel()
            subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
            subtitleLabel.textColor = .systemGray
            subtitleLabel.text = subtitle
            subtitleLabel.numberOfLines = 0
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

            row.addSubview(subtitleLabel)

            NSLayoutConstraint.activate([
                checkboxButton.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 12),
                checkboxButton.centerYAnchor.constraint(equalTo: row.centerYAnchor),

                titleLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 12),
                titleLabel.topAnchor.constraint(equalTo: row.topAnchor, constant: 4),

                subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
                subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -8),
                subtitleLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -4),

                timeLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -12),
                timeLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                checkboxButton.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 12),
                checkboxButton.centerYAnchor.constraint(equalTo: row.centerYAnchor),

                titleLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 12),
                titleLabel.topAnchor.constraint(equalTo: row.topAnchor, constant: 8),
                titleLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -8),

                timeLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -12),
                timeLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -8)
            ])
        }

        row.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true

        return row
    }
    
    private func makeIOSCheckbox(isChecked: Bool) -> UIButton {
        let button = UIButton(type: .system)

        let symbolName = isChecked
            ? "checkmark.circle.fill"
            : "circle"

        let image = UIImage(
            systemName: symbolName,
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 22,
                weight: .regular
            )
        )

        button.setImage(image, for: .normal)
        button.tintColor = isChecked ? .systemOrange : .systemGray3
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 28),
            button.heightAnchor.constraint(equalToConstant: 28)
        ])

        return button
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

    private func removeTrailingDividerIfNeeded() {
        if let last = stackView.arrangedSubviews.last, last.tag == dividerTag {
            stackView.removeArrangedSubview(last)
            last.removeFromSuperview()
        }
    }
}
