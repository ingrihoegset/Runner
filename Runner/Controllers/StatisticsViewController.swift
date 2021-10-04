//
//  StatisticsViewController.swift
//  Runner
//
//  Created by Ingrid on 22/07/2021.
//

import UIKit
import JGProgressHUD

class StatisticsViewController: UIViewController, StatisticsViewModelDelegate {
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.style = .large
        spinner.color = Constants.accentColorDark
        return spinner
    }()
    
    public static let dateFormatterMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter
    }()
    
    public static let dateFormatterYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    private var runs: [RunResults] = [RunResults]()
    private var allRuns: [RunResults] = [RunResults]()
    private var allRunYears: [String] = [""]
    
    let statisticsViewModel = StatisticsViewModel()
    
    var sortDistanceClicked = false
    var sortTimeClicked = false
    var sortDateClicked = false
    var sortSpeedClicked = false
    var sortTypeClicked = false
    var sortEditClicked = false
    var selectedTypes: [String] = []
    
    let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        return view
    }()
    
    let sortTypeButton: BounceButton = {
        let button = BounceButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.animationColor = Constants.accentColorDark
        button.backgroundColor = Constants.accentColorDark
        button.clipsToBounds = true
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.setTitle("Run Type", for: .normal)
        button.setTitleColor(Constants.textColorWhite, for: .normal)
        button.titleLabel?.font = Constants.mainFontLargeSB
        button.addTarget(self, action: #selector(presentSortType), for: .touchUpInside)
        return button
    }()
    
    let sortDateButton: BounceButton = {
        let button = BounceButton()
        button.animationColor = Constants.accentColorDark
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.accentColorDark
        button.clipsToBounds = true
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.setTitle("Date", for: .normal)
        button.setTitleColor(Constants.textColorWhite, for: .normal)
        button.addTarget(self, action: #selector(presentDateType), for: .touchUpInside)
        button.titleLabel?.font = Constants.mainFontLargeSB
        return button
    }()
    
    let statsHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.accentColor
        return view
    }()
    
    let editButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(editTable), for: .touchUpInside)
        button.layer.cornerRadius = Constants.smallCornerRadius
        let image = UIImage(systemName: "trash.fill")?.withTintColor(Constants.accentColor!)
        let imageview = UIImageView()
        button.addSubview(imageview)
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.topAnchor.constraint(equalTo: button.topAnchor).isActive = true
        imageview.bottomAnchor.constraint(equalTo: button.bottomAnchor).isActive = true
        imageview.leadingAnchor.constraint(equalTo: button.leadingAnchor).isActive = true
        imageview.trailingAnchor.constraint(equalTo: button.trailingAnchor).isActive = true
        button.imageView?.image = image
        imageview.contentMode = .scaleAspectFit
        imageview.image = image?.imageWithInsets(insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        button.backgroundColor = Constants.accentColorDark
        return button
    }()
    
    /// Labels for header of stats tabel view
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
    private let runTimeButton: BounceButton = {
        let button = BounceButton()
        button.setTitle("Time", for: .normal)
        button.backgroundColor = Constants.accentColorDark
        button.titleLabel?.font = Constants.mainFontSB
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(Constants.textColorWhite, for: .normal)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(sortByTime), for: .touchUpInside)
        return button
    }()
    
    /// Labels for header of stats tabel view
    private let runDistanceButton: BounceButton = {
        let button = BounceButton()
        button.setTitle("m", for: .normal)
        button.backgroundColor = Constants.accentColorDark
        button.titleLabel?.font = Constants.mainFontSB
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(Constants.textColorWhite, for: .normal)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(sortByDistance), for: .touchUpInside)
        return button
    }()
    
    /// Labels for header of stats tabel view
    private let runSpeedButton: BounceButton = {
        let button = BounceButton()
        button.setTitle("km/h", for: .normal)
        button.backgroundColor = Constants.accentColorDark
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
        tableView.backgroundColor = Constants.accentColor
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        statisticsViewModel.statisticsViewModelDelegate = self
        statisticsViewModel.listenForCompletedRuns()
        
        navigationItem.title = "My Runs"
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
        
        spinner.startAnimating()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: Constants.headerSize).isActive = true
        headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        sortTypeButton.trailingAnchor.constraint(equalTo: headerView.centerXAnchor, constant: -Constants.sideMargin / 2).isActive = true
        sortTypeButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: Constants.sideMargin).isActive = true
        sortTypeButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -Constants.sideMargin / 2).isActive = true
        sortTypeButton.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        
        sortDateButton.leadingAnchor.constraint(equalTo: headerView.centerXAnchor, constant: Constants.sideMargin / 2).isActive = true
        sortDateButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -Constants.sideMargin / 2).isActive = true
        sortDateButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        sortDateButton.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        
        // Header for table view
        statsHeaderView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        statsHeaderView.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight + Constants.sideMargin).isActive = true
        statsHeaderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        statsHeaderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true

        let sortButtonWidth = (Constants.widthOfDisplay - 5 * Constants.sideMargin) * 0.25
        editButton.leadingAnchor.constraint(equalTo: statsHeaderView.leadingAnchor, constant: Constants.sideMargin).isActive = true
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
        allRuns = completedRunsArray
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func loadYears(years: [String]) {
        allRunYears = years
    }
    
    func reloadTableView(sortedTypeRunsArray: [RunResults]) {
        runs = sortedTypeRunsArray
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

extension StatisticsViewController: SortTypeDelegate {
    func sortBySelectedType(types: [String]) {
        if !types.isEmpty {
            var sortedRuns = [RunResults]()
            for run in allRuns {
                if types.contains(run.type) {
                    sortedRuns.append(run)
                }
            }
            DispatchQueue.main.async {
                self.reloadTableView(sortedTypeRunsArray: sortedRuns)
            }
        }
        else {
            DispatchQueue.main.async {
                self.reloadTableView(sortedTypeRunsArray: self.allRuns)
            }
        }
    }
}

extension StatisticsViewController: SortDateDelegate {
    func sortBySelectedDate(dates: [String]) {
        // If dates is not empty, the user selected at least one month.
        if !dates.isEmpty {
            var sortedRuns = [RunResults]()
            // Find month and year for each run. If this combination is in selected dates ("yyyy/month") the run is appended to sortedruns.
            for run in allRuns {

                let monthString = StatisticsViewController.dateFormatterMonth.string(from: run.date)
                let yearString = StatisticsViewController.dateFormatterYear.string(from: run.date)

                if dates.contains("\(yearString)/\(monthString)") {
                    sortedRuns.append(run)
                }
            }
            DispatchQueue.main.async {
                self.reloadTableView(sortedTypeRunsArray: sortedRuns)
            }
        }
        // If dates is empty the user push "select" without selecting anything. Simply reload everything.
        else {
            DispatchQueue.main.async {
                self.reloadTableView(sortedTypeRunsArray: self.allRuns)
            }
        }

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
        
        let destinationController = ResultDetailsViewController()
        destinationController.type = model.type
        destinationController.distance = model.distance
        destinationController.averageSpeed = String(model.averageSpeed)
        destinationController.date = FirstGateViewModel.dateFormatterShort.string(from: model.date)
        destinationController.distance = model.distance
        destinationController.time = String(model.time)

        navigationController?.pushViewController(destinationController, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.mainButtonSize
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 15, 0)
        cell.layer.transform = rotationTransform
        UIView.animate(withDuration: 0.25) {
            cell.alpha = 1
            cell.layer.transform = CATransform3DIdentity
        }
    }
    
    @objc func editTable(_ sender: UIButton) {
        self.tableView.isEditing = !self.tableView.isEditing
        
        if sortEditClicked == true {
            sortEditClicked = false
            DispatchQueue.main.async {
                self.editButton.backgroundColor = Constants.accentColorDark
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
        let vc = SortTypeViewController()
        vc.sortTypeDelegate = self
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: {
            self.unselectAllButtons()
        })
    }
    
    @objc func presentDateType() {
        let vc = SortDateViewController()
        vc.sortDateDelegate = self
        // Generate month data for the number of years of data
        var sortTableViewData = [[String]]()
        for _ in allRunYears {
            sortTableViewData.append(["January","February","March","April","May","June","July","August","September","October","November","December"])
        }
        // Make sure years are sorted so that newest runs are first
        allRunYears.sort {
            $0 > $1
        }
        // Assign tableview data
        vc.allRunYears = allRunYears
        vc.sortTableViewData = sortTableViewData
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: {
            self.unselectAllButtons()
        })
    }
    
    private func unselectAllButtons() {
        sortDistanceClicked = false
        sortTimeClicked = false
        sortDateClicked = false
        sortSpeedClicked = false
        sortEditClicked = false
        sortTypeClicked = false
        runTimeButton.backgroundColor = Constants.accentColorDark
        runDistanceButton.backgroundColor = Constants.accentColorDark
        runSpeedButton.backgroundColor = Constants.accentColorDark
        editButton.backgroundColor = Constants.accentColorDark
        sortTypeButton.backgroundColor = Constants.accentColorDark
        sortDateButton.backgroundColor = Constants.accentColorDark
    }
    
    @objc func sortByDistance() {
        sortTimeClicked = false
        runTimeButton.backgroundColor = Constants.accentColorDark
        sortSpeedClicked = false
        runSpeedButton.backgroundColor = Constants.accentColorDark
        if sortDistanceClicked == true {
            sortDistanceClicked = false
            runs.sort {
                $0.distance > $1.distance
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.runDistanceButton.backgroundColor = Constants.accentColorDark
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
        sortTimeClicked = false
        runTimeButton.backgroundColor = Constants.accentColorDark
        sortDistanceClicked = false
        runDistanceButton.backgroundColor = Constants.accentColorDark
        if sortSpeedClicked == true {
            sortSpeedClicked = false
            runs.sort {
                $0.averageSpeed < $1.averageSpeed
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.runSpeedButton.backgroundColor = Constants.accentColorDark
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
                self.sortDateButton.backgroundColor = Constants.accentColorDark
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
        sortDistanceClicked = false
        runDistanceButton.backgroundColor = Constants.accentColorDark
        sortSpeedClicked = false
        runSpeedButton.backgroundColor = Constants.accentColorDark
        if sortTimeClicked == true {
            sortTimeClicked = false
            runs.sort {
                $0.time > $1.time
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.runTimeButton.backgroundColor = Constants.accentColorDark
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

