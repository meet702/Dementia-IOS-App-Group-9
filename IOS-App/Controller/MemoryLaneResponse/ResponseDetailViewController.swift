//
//  ResponseDetailViewController.swift
//  MemoryLaneResponseFeature
//
//  Created by SDC-USER on 12/12/25.
//

import UIKit

class ResponseDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var personImage: UIImageView!
    
    @IBOutlet weak var identification: UILabel!
    
    @IBOutlet weak var navTitle: UINavigationItem!
    
    
    var rows: [ResponseRow] = []
    var person: PersonSession!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let row = rows[indexPath.row]

        switch row {
        case .text(let question, let answer, let symbol):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextDetailsCell", for: indexPath) as! TextDetailsTableViewCell
            cell.configure(title: question, text: answer, symbol: symbol)
            return cell
        }
    }


    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func setupLayout() {
        personImage.image = UIImage(named: person.image)
        personImage.layer.cornerRadius = 45
        identification.text = person.wasIdentifiedCorrectly ?? false ? "Identified" : "Not Identified"
        identification.backgroundColor = person.wasIdentifiedCorrectly ?? false ? UIColor(red: 218/255, green: 246/255, blue: 221/255, alpha: 1) : UIColor(red: 246/255, green: 218/255, blue: 218/255, alpha: 1)
        identification.textColor = person.wasIdentifiedCorrectly ?? false ? UIColor(red: 39/255, green: 139/255, blue: 64/255, alpha: 1) : UIColor(red: 191/255, green: 29/255, blue: 32/255, alpha: 1)
        identification.layer.cornerRadius = 15
        identification.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let person else { return }
        rows = person.buildResponseRows()
        tableView.reloadData()
        
        navTitle.title = person.personName
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        tableView.register(UINib(nibName: "TextDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "TextDetailsCell")
        setupLayout()
    }
    
}
