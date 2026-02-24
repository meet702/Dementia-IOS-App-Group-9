import UIKit

class CaregiverMCQViewController: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!

    var questions: [OnboardingQuestion] = []
    var headerTitles: [String] = []

    var currentIndex = 0
    var startingStep = 2
    var totalSteps = 0


    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBackButton()
        updateUI()
    }

    private func setupUI() {

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none

        nextButton.layer.cornerRadius = 27
    }

    private func setupBackButton() {

        navigationItem.hidesBackButton = true

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    @objc private func backTapped() {
        if currentIndex > 0 {
            currentIndex -= 1
            updateUI()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    private func updateUI() {

        let stepNumber = startingStep + currentIndex
        progressView.progress = Float(stepNumber) / Float(totalSteps)

        titleLabel.text = headerTitles[currentIndex]
        questionLabel.text = questions[currentIndex].title

        tableView.reloadData()
    }

    @IBAction func nextTapped(_ sender: UIButton) {

        if currentIndex < questions.count - 1 {
            currentIndex += 1
            updateUI()
        } else {
            performSegue(withIdentifier: "showCaregiverFreeText", sender: nil)
        }
    }
}

extension CaregiverMCQViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        questions[currentIndex].options.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)

        let question = questions[currentIndex]
        let isSelected = question.selectedIndexes.contains(indexPath.row)

        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear

        cell.textLabel?.text = question.options[indexPath.row]
        cell.imageView?.image = UIImage(
            systemName: isSelected ? "largecircle.fill.circle" : "circle"
        )
        cell.imageView?.tintColor = .systemOrange

        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var q = questions[currentIndex]

        if q.selectionType == .single {
            q.selectedIndexes = [indexPath.row]
        } else {
            if q.selectedIndexes.contains(indexPath.row) {
                q.selectedIndexes.remove(indexPath.row)
            } else {
                q.selectedIndexes.insert(indexPath.row)
            }
        }

        questions[currentIndex] = q
        tableView.reloadData()
    }
}
