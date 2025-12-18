//
//  TestResponseViewController.swift
//  MemoryLaneResponseFeature
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit

class ResponseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var session: ImageSession!
    var people: [PersonSession] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "person_cell", for: indexPath) as! PersonTableViewCell
        let person = people[indexPath.row]
        cell.configure(person: person)
        cell.onChevronTapped = { [weak self] in
            self?.openPersonDetail(person)
        }
        return cell
    }
    
    func openPersonDetail(_ person: PersonSession) {
        let vc = storyboard!.instantiateViewController(identifier: "ResponseDetailViewController") as! ResponseDetailViewController

        vc.person = person

        vc.modalPresentationStyle = .pageSheet

        present(vc, animated: true)
    }


    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        session = ResponseDataStore.shared.currentImageSession
        people = session.personSessions
        
        guard let session1 = ResponseDataStore.shared.currentImageSession else {
            assertionFailure("No session selected")
            return
        }

        self.session = session1
        tableView.delegate = self
        tableView.dataSource = self

        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension

        let header = Bundle.main.loadNibNamed("MemoryHeaderView", owner: nil, options: nil)!.first as! MemoryHeaderView
        
        header.titleLabel.text = "Here's what Arjun said about this picture..."
        header.descriptionLabel.text = session.overallReflection
        header.headerImageView.image = UIImage(named: session.image)
        installTableHeaderView(header)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy • h:mm a"
        formatter.locale = .current
        navigationItem.title = formatter.string(from: session.timestamp)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderSize()
        if let header = tableView.tableHeaderView {
            header.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
            updateTableHeaderSize()
        }
    }
    
    func installTableHeaderView(_ header: UIView) {
        tableView.tableHeaderView = header
        header.translatesAutoresizingMaskIntoConstraints = false
        header.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        updateTableHeaderSize()
    }

    func updateTableHeaderSize() {
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        
        let icon = UIImageView()
        icon.image = UIImage(systemName: "person.2.fill")
        icon.tintColor = .black
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit

        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 22)
        ])
        
        let label = UILabel()
        label.text = "People in this memory"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        
        let hStack = UIStackView(arrangedSubviews: [icon, label])
        hStack.axis = .horizontal
        hStack.spacing = 8
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(hStack)

        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            hStack.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            hStack.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }


}
