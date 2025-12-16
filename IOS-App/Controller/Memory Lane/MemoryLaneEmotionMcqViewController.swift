import UIKit

class MemoryLaneEmotionMcqViewController: UIViewController {

    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var progressView: UIProgressView!

    var personImage: UIImage?
    var personName: String = ""
    var groupImage: UIImage?

    private let emotions = ["Happy", "Calm", "Sad", "Don’t remember"]
    private var selectedIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTable()

        // ✅ Show current progress WITHOUT advancing
        progressView.progress = MemorySessionManager.shared.currentProgress()
    }

    private func setupUI() {
        backgroundView.layer.cornerRadius = 35

        personImageView.image = personImage
        personImageView.layer.cornerRadius = personImageView.frame.width / 2
        personImageView.clipsToBounds = true

        personNameLabel.text = personName
        questionLabel.text =
            "How does thinking of \(personName) make you feel?"

        nextButton.layer.cornerRadius = 26
        updateNextButtonState()
    }

    private func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
    }

    private func updateNextButtonState() {
        nextButton.isEnabled = selectedIndex != nil
        nextButton.alpha = selectedIndex != nil ? 1.0 : 0.4
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let selectedIndex = selectedIndex else { return }

        let selectedEmotion = emotions[selectedIndex]
        MemorySessionManager.shared.setEmotion(selectedEmotion)

        // ✅ ADVANCE PROGRESS ONLY AFTER ANSWERING
        let progress = MemorySessionManager.shared.advanceProgress()
        progressView.setProgress(progress, animated: false)

        goToFinalQuestion()
    }

    private func goToFinalQuestion() {
        let sb = UIStoryboard(name: "MemoryLane", bundle: nil)

        if let finalVC = sb.instantiateViewController(
            withIdentifier: "MemoryLaneFinalQuestion"
        ) as? MemoryLaneFinalQuestionViewController {

            // Final question uses GROUP image
            finalVC.groupImageData = groupImage
            navigationController?.pushViewController(finalVC, animated: false)
        }
    }
}

extension MemoryLaneEmotionMcqViewController:
    UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return emotions.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "OptionCell",
            for: indexPath
        ) as! OptionTableViewCell

        let isSelected = selectedIndex == indexPath.row
        cell.configure(
            title: emotions[indexPath.row],
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
        selectedIndex = sender.tag
        tableView.reloadData()
        updateNextButtonState()
    }
}
