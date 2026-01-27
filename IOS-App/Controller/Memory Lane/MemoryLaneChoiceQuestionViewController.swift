import UIKit

class MemoryLaneChoiceQuestionViewController: UIViewController {

    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var progressView: UIProgressView!

    var personImage: UIImage?
    var personName: String = ""
    var relation: String = ""
    var groupImage: UIImage?
    var personIndex: Int = 0

    var mcqQuestions: [Question] = []
    private var currentMCQIndex: Int = 0

    private var selectedIndexes = Set<Int>()
    private var options: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupTableView()
        loadMCQ()

        progressView.progress = MemorySessionManager.shared.currentProgress()
    }

    private func setupUI() {
        backgroundView.layer.cornerRadius = 35

        personNameLabel.text = personName
        personImageView.image = personImage
        personImageView.layer.cornerRadius = personImageView.frame.width / 2
        personImageView.clipsToBounds = true

        nextButton.layer.cornerRadius = 26
        updateNextButtonState()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
    }

    private func loadMCQ() {
        guard currentMCQIndex < mcqQuestions.count else {
            nextButton.isEnabled = false
            nextButton.alpha = 0.4
            return
        }

        let q = mcqQuestions[currentMCQIndex]
        questionLabel.text = q.question
        options = q.options ?? []

        selectedIndexes.removeAll()
        tableView.reloadData()
        updateNextButtonState()
    }

    private func updateNextButtonState() {
        nextButton.isEnabled = !selectedIndexes.isEmpty
        nextButton.alpha = nextButton.isEnabled ? 1.0 : 0.4
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard currentMCQIndex < mcqQuestions.count else { return }

        let q = mcqQuestions[currentMCQIndex]

        let selectedOptions =
            selectedIndexes
                .filter { $0 < options.count }
                .sorted()
                .map { options[$0] }

        MemorySessionManager.shared.addMCQAnswer(
            question: q.question,
            selected: selectedOptions.joined(separator: ", ")
        )

        let progress = MemorySessionManager.shared.advanceProgress()
        progressView.setProgress(progress, animated: false)

        currentMCQIndex += 1

        if currentMCQIndex < mcqQuestions.count {
            loadMCQ()
        } else {
            goToEmotionScreen()
        }
    }

    private func goToEmotionScreen() {
        let sb = UIStoryboard(name: "MemoryLane", bundle: nil)

        guard let vc =
            sb.instantiateViewController(withIdentifier: "mcqEmotionVC")
                as? MemoryLaneEmotionMcqViewController else { return }

        vc.personImage = personImage
        vc.personName = personName
        vc.groupImage = groupImage

        navigationController?.pushViewController(vc, animated: false)
    }
}

extension MemoryLaneChoiceQuestionViewController:
    UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "OptionCell",
            for: indexPath
        ) as! OptionTableViewCell

        let isSelected = selectedIndexes.contains(indexPath.row)

        cell.configure(
            title: options[indexPath.row],
            selected: isSelected
        )

        cell.selectButton.tag = indexPath.row
        cell.selectButton.addTarget(
            self,
            action: #selector(optionTapped(_:)),
            for: .touchUpInside
        )

        return cell
    }

    @objc func optionTapped(_ sender: UIButton) {
        let row = sender.tag

        if selectedIndexes.contains(row) {
            selectedIndexes.remove(row)
        } else {
            selectedIndexes.insert(row)
        }

        tableView.reloadRows(
            at: [IndexPath(row: row, section: 0)],
            with: .automatic
        )

        updateNextButtonState()
    }
}
