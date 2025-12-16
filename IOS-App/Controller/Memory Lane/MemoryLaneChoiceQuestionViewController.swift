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

    // MCQ data
    var mcqQuestions: [Question] = []
    var currentMCQIndex: Int = 0

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
        personImageView.layer.cornerRadius =
            personImageView.frame.width / 2
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

        let q = mcqQuestions[currentMCQIndex]
        let selectedOptions =
            selectedIndexes.sorted().map { options[$0] }

        MemorySessionManager.shared.addMCQAnswer(
            question: q.question,
            selected: selectedOptions.joined(separator: ", ")
        )

        // ✅ ADVANCE PROGRESS ONLY AFTER ANSWERING
        let progress = MemorySessionManager.shared.advanceProgress()
        progressView.setProgress(progress, animated: false)

        if currentMCQIndex < mcqQuestions.count - 1 {
            currentMCQIndex += 1
            loadMCQ()
        } else {
            goToEmotionScreen()
        }
    }

    private func goToEmotionScreen() {
        let sb = UIStoryboard(name: "MemoryLane", bundle: nil)

        if let vc =
            sb.instantiateViewController(
                withIdentifier: "mcqEmotionVC"
            ) as? MemoryLaneEmotionMcqViewController {

            vc.personImage = personImage
            vc.personName = personName
            vc.groupImage = groupImage
            navigationController?.pushViewController(vc, animated: false)
        }
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

        let isSelected =
            selectedIndexes.contains(indexPath.row)

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
