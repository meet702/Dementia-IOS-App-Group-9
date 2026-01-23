import UIKit

class ResponseDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var identification: UILabel!
    @IBOutlet weak var navTitle: UINavigationItem!

    private var rows: [ResponseRow] = []
    var person: PersonSession?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let person else {
            assertionFailure("ResponseDetailViewController requires a PersonSession")
            return
        }

        configureNavigation(for: person)
        configureTableView()
        configureLayout(for: person)
        buildRows(from: person)
    }

    private func configureNavigation(for person: PersonSession) {
        navTitle.title = person.personName
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

    private func buildRows(from person: PersonSession) {
        rows = person.buildResponseRows()
        tableView.reloadData()
    }

    private func configureLayout(for person: PersonSession) {
        personImage.image = UIImage(named: person.image)
        personImage.layer.cornerRadius = 45
        personImage.clipsToBounds = true

        let identified = person.wasIdentifiedCorrectly ?? false
        identification.text = identified ? "Identified" : "Not Identified"
        identification.layer.cornerRadius = 15
        identification.clipsToBounds = true

        identification.backgroundColor = identified
            ? UIColor(red: 218/255, green: 246/255, blue: 221/255, alpha: 1)
            : UIColor(red: 246/255, green: 218/255, blue: 218/255, alpha: 1)

        identification.textColor = identified
            ? UIColor(red: 39/255, green: 139/255, blue: 64/255, alpha: 1)
            : UIColor(red: 191/255, green: 29/255, blue: 32/255, alpha: 1)
    }

    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension ResponseDetailViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let row = rows[indexPath.row]

        switch row {
        case .text(let question, let answer, let symbol):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "TextDetailsCell",
                for: indexPath
            ) as! TextDetailsTableViewCell

            cell.configure(
                title: question,
                text: answer,
                symbol: symbol
            )
            return cell
        }
    }
}

