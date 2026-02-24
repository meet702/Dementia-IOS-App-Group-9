import UIKit

class MCQViewController: UIViewController {

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

    private let bgColor = UIColor(red: 0.99, green: 0.96, blue: 0.91, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        updateUI()
    }

    private func setupUI() {


        tableView.delegate = self
        tableView.dataSource = self

       
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false

        nextButton.layer.cornerRadius = 27

        progressView.trackTintColor = .systemGray5
        progressView.progressTintColor = .systemOrange
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
            performSegue(withIdentifier: "goToHomeScreen", sender: nil)
        }
    }
}

extension MCQViewController: UITableViewDelegate, UITableViewDataSource {

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
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)

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
