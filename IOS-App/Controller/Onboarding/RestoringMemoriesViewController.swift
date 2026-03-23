//
//  RestoringMemoriesViewController.swift
//  IOS-App
//
//  Created by SDC-USER on 17/03/26.
//


import UIKit

class RestoringMemoriesViewController: UIViewController {

    private let containerView = UIView()
    private let spinner = UIActivityIndicatorView(style: .large)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let progressBar = UIView()
    private var progressBarWidth: NSLayoutConstraint!
    private(set) var currentProgress: Float = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.996, green: 0.973, blue: 0.937, alpha: 1) // #FEF8EF
        setupUI()
    }

    private func setupUI() {
        // Spinner
        spinner.color = UIColor(red: 0.91, green: 0.45, blue: 0.29, alpha: 1)
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false

        // Title
        titleLabel.text = "Restoring your memories"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Subtitle
        subtitleLabel.text = "Bringing back your photos and moments.\nJust a sec…"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Progress track
        let track = UIView()
        track.backgroundColor = UIColor(red: 0.91, green: 0.45, blue: 0.29, alpha: 0.2)
        track.layer.cornerRadius = 2
        track.translatesAutoresizingMaskIntoConstraints = false
        track.clipsToBounds = true

        progressBar.backgroundColor = UIColor(red: 0.91, green: 0.45, blue: 0.29, alpha: 1)
        progressBar.layer.cornerRadius = 2
        progressBar.translatesAutoresizingMaskIntoConstraints = false

        track.addSubview(progressBar)
        progressBarWidth = progressBar.widthAnchor.constraint(equalToConstant: 0)

        [spinner, titleLabel, subtitleLabel, track].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),

            titleLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            track.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            track.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            track.widthAnchor.constraint(equalToConstant: 200),
            track.heightAnchor.constraint(equalToConstant: 4),

            progressBar.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            progressBar.topAnchor.constraint(equalTo: track.topAnchor),
            progressBar.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            progressBarWidth,
        ])
    }

    func setProgress(_ value: Float) {
        currentProgress = value
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.progressBarWidth.constant = 200 * CGFloat(value)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
}
