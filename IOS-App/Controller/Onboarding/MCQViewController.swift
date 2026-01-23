//
//  MCQViewController.swift
//  onboardingScreen
//
//  Created by SDC-USER on 15/12/25.
//

import UIKit
class MCQViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!

    var questions: [OnboardingQuestions] = []
    var currentIndex = 0
    var startingStep = 2
    var totalSteps: Int = 0

    var headerTitles: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
       
        nextButton.layer.cornerRadius = 27
        tableView.rowHeight = 48
     
        navigationItem.hidesBackButton = true

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        updateUI()
    }

    @objc func backTapped() {
        if currentIndex > 0 {
            currentIndex -= 1
            updateUI()
        }
        else {
            navigationController?.popViewController(animated: true)
        }
    }

    func updateUI() {
        let stepNumber = startingStep + currentIndex

        stepLabel.text = "Step \(stepNumber) of \(totalSteps)"
        progressView.progress = Float(stepNumber) / Float(totalSteps)

        titleLabel.text = headerTitles[currentIndex]
        questionLabel.text = questions[currentIndex].title

        let isLastMCQ = currentIndex == questions.count - 1
        nextButton.setTitle(isLastMCQ ? "Next" : "Next", for: .normal)


        tableView.reloadData()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        if currentIndex < questions.count - 1 {
                currentIndex += 1
                updateUI()
        }
        else {
            performSegue(withIdentifier: "goToHomeScreen", sender: nil)
        }
    }
}

extension MCQViewController {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return questions[currentIndex].options.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "OptionCell",
            for: indexPath
        )
        
        let question = questions[currentIndex]
        let isSelected = question.selectedIndexes.contains(indexPath.row)

        let imageName: String
        if isSelected {
            imageName = "largecircle.fill.circle"
        } else {
            imageName = "circle"
        }

        cell.imageView?.image = UIImage(systemName: imageName)
        cell.imageView?.tintColor = UIColor.systemOrange
        
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.textLabel?.text = questions[currentIndex].options[indexPath.row]
        cell.selectionStyle = .none
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        cell.textLabel?.textColor = .black


        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var question = questions[currentIndex]

        if question.selectionType == .single {
            question.selectedIndexes = [indexPath.row]
        } else {
            if question.selectedIndexes.contains(indexPath.row) {
                question.selectedIndexes.remove(indexPath.row)
            } else {
                question.selectedIndexes.insert(indexPath.row)
            }
        }

        questions[currentIndex] = question
        tableView.reloadData()
    }
}
 
