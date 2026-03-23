//
//  ResponseViewController.swift
//  MemoryLaneResponseFeature
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit

final class ResponseViewController: UIViewController {

    // MARK: - Dependencies (NEW MODEL)

    var imageSession: ImageSession?
    private var personSessions: [PersonSession] = []

    // MARK: - Outlets

    @IBOutlet weak var tableView: UITableView!
    
    var patientName: String {
        let fullName = SessionManager.shared.patientName ?? "Patient"
        return fullName.components(separatedBy: " ").first ?? fullName
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let imageSession else {
            assertionFailure("ResponseViewController requires an ImageSession")
            return
        }

        personSessions = PersonSessionStore.shared.personSessions(for: imageSession.isid)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension

        configureHeader(with: imageSession)
        configureNavigationTitle(date: imageSession.startedAt)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderSize()
    }
    
    private func configureHeader(with session: ImageSession) {

        let header = Bundle.main.loadNibNamed(
            "MemoryHeaderView",
            owner: nil,
            options: nil
        )!.first as! MemoryHeaderView

        header.titleLabel.text = "Here's what \(patientName) shared about this moment"

        let reflection = ImageSessionQuestionStore.shared
            .overallReflection(for: session.isid)

        header.descriptionLabel.text = reflection.isEmpty
            ? "This memory was revisited together."
            : reflection

        
        if let image = SessionImageStore.shared.fetchImage(by: session.wid) {
            header.headerImageView.image = image
        } else if let image = LocalImageStore.shared.fetchImage(by: session.wid) {
           
            header.headerImageView.image = image
            
            SessionImageStore.shared.saveSessionImage(for: session.wid)
        } else {
            header.headerImageView.image = UIImage(systemName: "photo")
        }

        installTableHeaderView(header)
    }

    private func configureNavigationTitle(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy, h:mm a"
        formatter.locale = .current
        navigationItem.title = formatter.string(from: date)
    }

    private func openPersonDetail(_ person: PersonSession) {
        let vc = storyboard!.instantiateViewController(
            identifier: "ResponseDetailViewController"
        ) as! ResponseDetailViewController

        vc.personSession = person
        vc.imageID = imageSession!.wid
        vc.modalPresentationStyle = .pageSheet

        present(vc, animated: true)
    }

    private func installTableHeaderView(_ header: UIView) {
        tableView.tableHeaderView = header
        header.translatesAutoresizingMaskIntoConstraints = false
        header.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        updateTableHeaderSize()
    }

    private func updateTableHeaderSize() {
        guard let header = tableView.tableHeaderView else { return }

        let targetSize = CGSize(width: tableView.bounds.width, height: 0)

        let height = header.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        if header.frame.height != height {
            header.frame.size.height = height
            tableView.tableHeaderView = header
        }
    }
}

extension ResponseViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        personSessions.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "person_cell",
            for: indexPath
        ) as! PersonTableViewCell

        let personSession = personSessions[indexPath.row]
        guard let imageID = imageSession?.wid else {
            fatalError("Missing imageID")
        }
        
        cell.configure(personSession: personSession, imageID: imageID)

        cell.onChevronTapped = { [weak self] in
            self?.openPersonDetail(personSession)
        }

        return cell
    }
}


extension ResponseViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {

        let headerView = UIView()
        headerView.backgroundColor = .clear

        let icon = UIImageView()
        icon.image = UIImage(systemName: "person.2.fill")
        icon.tintColor = .black
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "People in this memory"
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(stack)

        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 22),

            stack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])

        return headerView
    }

    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        40
    }
}
