//
//  StatisticsViewController.swift
//  Runner
//
//  Created by Ingrid on 22/07/2021.
//

import UIKit
import JGProgressHUD

class StatisticsViewController: UIViewController, StatisticsViewModelDelegate {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var runs: [RunResults] = [RunResults]()
    
    let statisticsViewModel = StatisticsViewModel()
    
    var sortDistanceClicked = false
    var sortTimeClicked = false
    var sortDateClicked = false
    var sortSpeedClicked = false
    var sortTypeClicked = false
    var sortEditClicked = false
    
    let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.accentColor
        return view
    }()
    
    let sortTypeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.mainColor
        button.clipsToBounds = true
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.setTitle("Run Type", for: .normal)
        button.setTitleColor(Constants.textColorMain, for: .normal)
        button.titleLabel?.font = Constants.mainFontSB
        button.addTarget(self, action: #selector(presentSortType), for: .touchUpInside)
        return button
    }()
    
    let sortDateButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.mainColor
        button.clipsToBounds = true
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.setTitle("Date", for: .normal)
        button.setTitleColor(Constants.textColorMain, for: .normal)
        button.addTarget(self, action: #selector(sortByDate), for: .touchUpInside)
        button.titleLabel?.font = Constants.mainFontSB
        return button
    }()
    
    let statsHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.accentColorDark
        return view
    }()
    
    let editButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(editTable), for: .touchUpInside)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.setTitle("Edit", for: .normal)
        button.backgroundColor = Constants.accentColor
        button.titleLabel?.font = Constants.mainFontSB
        button.setTitleColor(Constants.textColorWhite, for: .normal)
        return button
    }()
    
    /// Labels for header of stats tabel view
    private let runTypeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.font = Constants.mainFontSB
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.textColorWhite
        label.text = ""
        return label
    }()
    
    private let runLapsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.font = Constants.mainFontSB
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.textColorWhite
        label.text = ""
        return label
    }()
    
    /// Labels for header of stats tabel view
    private let runTimeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Time", for: .normal)
        button.backgroundColor = Constants.accentColor
        button.titleLabel?.font = Constants.mainFontSB
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(Constants.textColorWhite, for: .normal)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(sortByTime), for: .touchUpInside)
        return button
    }()
    
    /// Labels for header of stats tabel view
    private let runDistanceButton: UIButton = {
        let button = UIButton()
        button.setTitle("Distance", for: .normal)
        button.backgroundColor = Constants.accentColor
        button.titleLabel?.font = Constants.mainFontSB
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(Constants.textColorWhite, for: .normal)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(sortByDistance), for: .touchUpInside)
        return button
    }()
    
    /// Labels for header of stats tabel view
    private let runSpeedButton: UIButton = {
        let button = UIButton()
        button.setTitle("Speed", for: .normal)
        button.backgroundColor = Constants.accentColor
        button.titleLabel?.font = Constants.mainFontSB
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(Constants.textColorWhite, for: .normal)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(sortBySpeed), for: .touchUpInside)
        return button
    }()
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Constants.mainColor
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.show(in: view)
        
        statisticsViewModel.statisticsViewModelDelegate = self
        statisticsViewModel.getCompletedRuns()
        
        title = "My Runs"
        view.backgroundColor = Constants.accentColor
        
        view.addSubview(headerView)
        headerView.addSubview(sortTypeButton)
        headerView.addSubview(sortDateButton)
        view.addSubview(statsHeaderView)
        statsHeaderView.addSubview(editButton)
        statsHeaderView.addSubview(runDistanceButton)
        statsHeaderView.addSubview(runSpeedButton)
        statsHeaderView.addSubview(runTimeButton)
        view.addSubview(tableView)
        
        tableView.register(RunTableViewCell.self, forCellReuseIdentifier: RunTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        // So that cell separation line will go edge to edge
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: Constants.headerSize / 2).isActive = true
        headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        sortTypeButton.trailingAnchor.constraint(equalTo: headerView.centerXAnchor, constant: -Constants.sideMargin / 2).isActive = true
        sortTypeButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: Constants.sideMargin).isActive = true
        sortTypeButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -Constants.verticalSpacing).isActive = true
        sortTypeButton.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        
        sortDateButton.leadingAnchor.constraint(equalTo: headerView.centerXAnchor, constant: Constants.sideMargin / 2).isActive = true
        sortDateButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -Constants.verticalSpacing).isActive = true
        sortDateButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        sortDateButton.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        
        // Header for table view
        statsHeaderView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        statsHeaderView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        statsHeaderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        statsHeaderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true

        let sortButtonWidth = Constants.widthOfDisplay * 0.25 - Constants.sideMargin
        editButton.leadingAnchor.constraint(equalTo: statsHeaderView.leadingAnchor, constant: Constants.sideMargin / 2).isActive = true
        editButton.widthAnchor.constraint(equalToConstant: sortButtonWidth).isActive = true
        editButton.centerYAnchor.constraint(equalTo: statsHeaderView.centerYAnchor).isActive = true
        editButton.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        
        runDistanceButton.leadingAnchor.constraint(equalTo: editButton.trailingAnchor, constant: Constants.sideMargin).isActive = true
        runDistanceButton.widthAnchor.constraint(equalToConstant: sortButtonWidth).isActive = true
        runDistanceButton.centerYAnchor.constraint(equalTo: statsHeaderView.centerYAnchor).isActive = true
        runDistanceButton.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        
        runSpeedButton.leadingAnchor.constraint(equalTo: runDistanceButton.trailingAnchor, constant: Constants.sideMargin).isActive = true
        runSpeedButton.widthAnchor.constraint(equalToConstant: sortButtonWidth).isActive = true
        runSpeedButton.centerYAnchor.constraint(equalTo: statsHeaderView.centerYAnchor).isActive = true
        runSpeedButton.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        
        runTimeButton.leadingAnchor.constraint(equalTo: runSpeedButton.trailingAnchor, constant: Constants.sideMargin).isActive = true
        runTimeButton.widthAnchor.constraint(equalToConstant: sortButtonWidth).isActive = true
        runTimeButton.centerYAnchor.constraint(equalTo: statsHeaderView.centerYAnchor).isActive = true
        runTimeButton.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        
        tableView.topAnchor.constraint(equalTo: statsHeaderView.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    deinit {
        print("DESTROYED STATSPAGE")
    }
    
    func reloadTableView(completedRunsArray: [RunResults]) {
        runs = completedRunsArray
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func stopSpinner() {
        DispatchQueue.main.async {
            self.spinner.dismiss()
        }
    }
    
    private func alertThatRunDeletionFailed() {
        let actionSheet = UIAlertController(title: "Failed to delete run. Try again later.",
                                            message: "",
                                            preferredStyle: .alert)
        
        actionSheet.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.navigationController?.popToRootViewController(animated: true)
        }))
        present(actionSheet, animated: true)
    }
}


extension StatisticsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = runs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: RunTableViewCell.identifier, for: indexPath) as! RunTableViewCell
        // So that cell separator goes edge to edge
        cell.layoutMargins = UIEdgeInsets.zero
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = runs[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // What happens when edit is selected
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            // Begin delete
            let runID = runs[indexPath.row].runID
            tableView.beginUpdates()
            
            self.statisticsViewModel.deleteRun(runID: runID, completion: { [weak self] success in
                if success {
                    self?.runs.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)
                }
                else {
                    self?.alertThatRunDeletionFailed()
                }
            })
            
            tableView.endUpdates()
        }
    }
    
    @objc func editTable(_ sender: UIButton) {
        self.tableView.isEditing = !self.tableView.isEditing
        
        if sortEditClicked == true {
            sortEditClicked = false
            DispatchQueue.main.async {
                self.editButton.backgroundColor = Constants.accentColor
            }
        }
        else {
            sortEditClicked = true
            DispatchQueue.main.async {
                self.editButton.backgroundColor = Constants.contrastColor
            }
        }
        
        
        //let title = (self.statsTableView.isEditing) ? "Done" : "Edit"
        //sender.setTitle(title, for: .normal)
    }
    
    @objc func presentSortType() {
        let vc = SortViewController()
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }
    
    @objc func sortByDistance() {
        if sortDistanceClicked == true {
            sortDistanceClicked = false
            runs.sort {
                $0.distance > $1.distance
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.runDistanceButton.backgroundColor = Constants.accentColor
            }
        }
        else {
            sortDistanceClicked = true
            runs.sort {
                $0.distance < $1.distance
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.runDistanceButton.backgroundColor = Constants.contrastColor
            }

        }
    }
    
    @objc func sortBySpeed() {
        if sortSpeedClicked == true {
            sortSpeedClicked = false
            runs.sort {
                $0.averageSpeed < $1.averageSpeed
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.runSpeedButton.backgroundColor = Constants.accentColor
            }
        }
        else {
            sortSpeedClicked = true
            runs.sort {
                $0.averageSpeed > $1.averageSpeed
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.runSpeedButton.backgroundColor = Constants.contrastColor
            }
        }
    }
    
    @objc func sortByDate() {
        if sortDateClicked == true {
            sortDateClicked = false
            runs.sort {
                $0.date < $1.date
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.sortDateButton.backgroundColor = Constants.mainColor
            }
        }
        else {
            sortDateClicked = true
            runs.sort {
                $0.date > $1.date
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.sortDateButton.backgroundColor = Constants.contrastColor
            }
        }
    }
    
    @objc func sortByTime() {
        if sortTimeClicked == true {
            sortTimeClicked = false
            runs.sort {
                $0.time > $1.time
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.runTimeButton.backgroundColor = Constants.accentColor
            }
        }
        else {
            sortTimeClicked = true
            runs.sort {
                $0.time < $1.time
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.runTimeButton.backgroundColor = Constants.contrastColor
            }
        }
    }
}

