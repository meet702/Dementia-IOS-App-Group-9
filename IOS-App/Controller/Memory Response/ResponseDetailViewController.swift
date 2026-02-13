import UIKit

final class ResponseDetailViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var identification: UILabel!
    @IBOutlet weak var navTitle: UINavigationItem!

    // MARK: - Data (NEW MODEL)

    var personSession: PersonSession!

    private var responses: [PersonSessionQuestion] = []
    var imageID: UUID!


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(personSession != nil, "ResponseDetailViewController requires PersonSession")

        configureNavigation()
        configureLayout()
        configureTableView()
        loadResponses()
    }

    // MARK: - Navigation

    private func configureNavigation() {

        if let person = PersonStore.shared.person(by: personSession.personID),
           let name = person.name,
           !name.isEmpty {
            navTitle.title = name
        } else {
            navTitle.title = "Someone in this memory"
        }
    }

    // MARK: - Layout

    private func configureLayout() {

        // Face image (if available)
        if let face = FaceStore.shared.face(
            for: personSession.personID,
            in: imageID
        ),
        let url = face.faceImageURL {

            personImage.image = UIImage(contentsOfFile: url.path)
        } else {
            personImage.image = UIImage(systemName: "person.crop.circle")
        }


        personImage.layer.cornerRadius = 45
        personImage.clipsToBounds = true

        // Identification / engagement badge (neutral wording)
        let hasResponses = !responses.isEmpty

        identification.text = hasResponses ? "Engaged" : "No response"
        identification.layer.cornerRadius = 15
        identification.clipsToBounds = true

        identification.backgroundColor = hasResponses
            ? UIColor(red: 218/255, green: 246/255, blue: 221/255, alpha: 1)
            : UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)

        identification.textColor = hasResponses
            ? UIColor(red: 39/255, green: 139/255, blue: 64/255, alpha: 1)
            : UIColor.darkGray
    }

    // MARK: - Table

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        tableView.register(
            UINib(nibName: "TextDetailsTableViewCell", bundle: nil),
            forCellReuseIdentifier: "TextDetailsCell"
        )
    }

    private func loadResponses() {

        responses = PersonSessionQuestionStore.shared
            .questions(for: personSession.psid)

        tableView.reloadData()
    }

    // MARK: - Actions

    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension ResponseDetailViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        responses.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let response = responses[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TextDetailsCell",
            for: indexPath
        ) as! TextDetailsTableViewCell

        let questionText = AppDataStore.shared
            .mcqQuestions
            .first { $0.qid == response.questionID }?
            .prompt
        ?? AppDataStore.shared
            .textQuestions
            .first { $0.qid == response.questionID }?
            .prompt
        ?? "Reflection"

        let answerText =
            response.responseText ??
            response.selectedOption ??
            "—"

        cell.configure(
            title: questionText,
            text: answerText,
            symbol: "quote.bubble"
        )

        return cell
    }
}
