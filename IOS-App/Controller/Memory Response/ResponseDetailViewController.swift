import UIKit

final class ResponseDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var navTitle: UINavigationItem!

    var personSession: PersonSession!

    private var responses: [PersonSessionQuestion] = []
    var imageID: UUID!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard personSession != nil else {
            fatalError("ResponseDetailViewController requires PersonSession")
        }

        guard imageID != nil else {
            fatalError("ResponseDetailViewController requires imageID")
        }

        configureNavigation()
        configureLayout()
        configureTableView()
        loadResponses()
    }

    private func configureNavigation() {

        let faces = FaceStore.shared.loadFaces(for: imageID)
        let face = faces.first(where: { $0.fid == personSession.fid })
        let name = face?.personName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if !name.isEmpty {
            navTitle.title = name
        } else {
            navTitle.title = "Someone in this memory"
        }
    }

    private func configureLayout() {

        let faces = FaceStore.shared.loadFaces(for: imageID)

        if let face = faces.first(where: { $0.fid == personSession.fid }),
           let image = FaceStore.shared.faceImage(for: face) {

            personImage.image = image

        } else {
            personImage.image = UIImage(systemName: "person.crop.circle.fill")
        }

        personImage.layer.cornerRadius = 54
        personImage.clipsToBounds = true
    }

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

        if responses.isEmpty {
            tableView.setEmptyMessage("No responses were recorded.")
        } else {
            tableView.restore()
        }

        tableView.reloadData()
    }

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

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "TextDetailsCell",
            for: indexPath
        ) as? TextDetailsTableViewCell else {
            return UITableViewCell()
        }

        let questionText = questionPrompt(for: response.qid)

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

    private func questionPrompt(for id: UUID) -> String {

        let allQuestions =
            AppDataStore.shared.mcqQuestions +
            AppDataStore.shared.textQuestions

        return allQuestions
            .first(where: { $0.qid == id })?
            .prompt
            ?? "Reflection"
    }
}

extension UITableView {

    func setEmptyMessage(_ message: String) {
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.textColor = .systemGray
        label.numberOfLines = 0
        backgroundView = label
        separatorStyle = .none
    }

    func restore() {
        backgroundView = nil
        separatorStyle = .singleLine
    }
}
