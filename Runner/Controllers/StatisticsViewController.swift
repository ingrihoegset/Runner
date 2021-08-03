//
//  StatisticsViewController.swift
//  Runner
//
//  Created by Ingrid on 22/07/2021.
//

import UIKit

class StatisticsViewController: UIViewController, StatisticsViewModelDelegate {
    
    private var runs: [RunResults] = [RunResults]()
    
    let statisticsViewModel = StatisticsViewModel()
    
    var sortDistanceClicked = false
    var sortTimeClicked = false
    var sortDateClicked = false
    var sortSpeedClicked = false
    var sortTypeClicked = false
    
    let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.accentColor
        return view
    }()
    
    let sortLabelType: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.mainColor
        button.clipsToBounds = true
        button.layer.cornerRadius = Constants.sorterButtonWidth / 2
        button.setImage(UIImage(systemName: ""), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = Constants.accentColorDark
        return button
    }()
    
    let sortLabelDate: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.mainColor
        button.clipsToBounds = true
        button.layer.cornerRadius = Constants.sorterButtonWidth / 2
        button.setImage(UIImage(systemName: "calendar.circle"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = Constants.accentColorDark
        button.addTarget(self, action: #selector(sortByDate), for: .touchUpInside)
        return button
    }()
    
    let sortLabelDistance: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.mainColor
        button.clipsToBounds = true
        button.layer.cornerRadius = Constants.sorterButtonWidth / 2
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = Constants.accentColorDark
        button.addTarget(self, action: #selector(sortByDistance), for: .touchUpInside)
        return button
    }()
    
    let sortLabelTime: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.mainColor
        button.clipsToBounds = true
        button.layer.cornerRadius = Constants.sorterButtonWidth / 2
        button.setImage(UIImage(systemName: "timer"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = Constants.accentColorDark
        return button
    }()
    
    let sortLabelSpeed: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.mainColor
        button.clipsToBounds = true
        button.layer.cornerRadius = Constants.sorterButtonWidth / 2
        button.setImage(UIImage(systemName: "speedometer"), for: .normal)
        button.addTarget(self, action: #selector(sortBySpeed), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = Constants.accentColorDark
        return button
    }()
    
    let statsHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.accentColorDark
        return view
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
        label.text = "Run type"
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
    
    private let runTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.font = Constants.mainFontSB
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.textColorWhite
        label.text = "Time"
        return label
    }()
    
    private let runDistanceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.font = Constants.mainFontSB
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.textColorWhite
        label.text = "Distance"
        return label
    }()
    
    private let runSpeedLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.font = Constants.mainFontSB
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.textColorWhite
        label.text = "Speed"
        return label
    }()
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Constants.accentColorDark
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        statisticsViewModel.statisticsViewModelDelegate = self
        statisticsViewModel.getCompletedRuns()
        
        title = "My Runs"
        view.backgroundColor = Constants.accentColor
        
        view.addSubview(headerView)
        headerView.addSubview(sortLabelType)
        headerView.addSubview(sortLabelDate)
        headerView.addSubview(sortLabelDistance)
        headerView.addSubview(sortLabelSpeed)
        headerView.addSubview(sortLabelTime)
        view.addSubview(statsHeaderView)
        statsHeaderView.addSubview(runTypeLabel)
        statsHeaderView.addSubview(runLapsLabel)
        statsHeaderView.addSubview(runDistanceLabel)
        statsHeaderView.addSubview(runSpeedLabel)
        statsHeaderView.addSubview(runTimeLabel)
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
        
        sortLabelType.widthAnchor.constraint(equalToConstant: Constants.sorterButtonWidth).isActive = true
        sortLabelType.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: Constants.sideMargin).isActive = true
        sortLabelType.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        sortLabelType.heightAnchor.constraint(equalToConstant: Constants.sorterButtonWidth).isActive = true
        
        sortLabelDate.widthAnchor.constraint(equalToConstant: Constants.sorterButtonWidth).isActive = true
        sortLabelDate.leadingAnchor.constraint(equalTo: sortLabelType.trailingAnchor, constant: Constants.verticalSpacingSmall).isActive = true
        sortLabelDate.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        sortLabelDate.heightAnchor.constraint(equalToConstant: Constants.sorterButtonWidth).isActive = true
        
        sortLabelDistance.widthAnchor.constraint(equalToConstant: Constants.sorterButtonWidth).isActive = true
        sortLabelDistance.leadingAnchor.constraint(equalTo: sortLabelDate.trailingAnchor, constant: Constants.verticalSpacingSmall).isActive = true
        sortLabelDistance.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        sortLabelDistance.heightAnchor.constraint(equalToConstant: Constants.sorterButtonWidth).isActive = true
        
        sortLabelSpeed.widthAnchor.constraint(equalToConstant: Constants.sorterButtonWidth).isActive = true
        sortLabelSpeed.leadingAnchor.constraint(equalTo: sortLabelDistance.trailingAnchor, constant: Constants.verticalSpacingSmall).isActive = true
        sortLabelSpeed.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        sortLabelSpeed.heightAnchor.constraint(equalToConstant: Constants.sorterButtonWidth).isActive = true
        
        sortLabelTime.widthAnchor.constraint(equalToConstant: Constants.sorterButtonWidth).isActive = true
        sortLabelTime.leadingAnchor.constraint(equalTo: sortLabelSpeed.trailingAnchor, constant: Constants.verticalSpacingSmall).isActive = true
        sortLabelTime.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        sortLabelTime.heightAnchor.constraint(equalToConstant: Constants.sorterButtonWidth).isActive = true
        
        // Header for table view
        statsHeaderView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        statsHeaderView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        statsHeaderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        statsHeaderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        runTypeLabel.leadingAnchor.constraint(equalTo: statsHeaderView.leadingAnchor).isActive = true
        runTypeLabel.topAnchor.constraint(equalTo: statsHeaderView.topAnchor).isActive = true
        runTypeLabel.bottomAnchor.constraint(equalTo: statsHeaderView.bottomAnchor).isActive = true
        runTypeLabel.widthAnchor.constraint(equalTo: statsHeaderView.widthAnchor, multiplier: 0.15).isActive = true
        
        runLapsLabel.leadingAnchor.constraint(equalTo: runTypeLabel.trailingAnchor).isActive = true
        runLapsLabel.topAnchor.constraint(equalTo: statsHeaderView.topAnchor).isActive = true
        runLapsLabel.bottomAnchor.constraint(equalTo: statsHeaderView.bottomAnchor).isActive = true
        runLapsLabel.widthAnchor.constraint(equalTo: statsHeaderView.widthAnchor, multiplier: 0.1).isActive = true

        runDistanceLabel.leadingAnchor.constraint(equalTo: runLapsLabel.trailingAnchor).isActive = true
        runDistanceLabel.topAnchor.constraint(equalTo: statsHeaderView.topAnchor).isActive = true
        runDistanceLabel.bottomAnchor.constraint(equalTo: statsHeaderView.bottomAnchor).isActive = true
        runDistanceLabel.widthAnchor.constraint(equalTo: statsHeaderView.widthAnchor, multiplier: 0.25).isActive = true
        
        runSpeedLabel.leadingAnchor.constraint(equalTo: runDistanceLabel.trailingAnchor).isActive = true
        runSpeedLabel.topAnchor.constraint(equalTo: statsHeaderView.topAnchor).isActive = true
        runSpeedLabel.bottomAnchor.constraint(equalTo: statsHeaderView.bottomAnchor).isActive = true
        runSpeedLabel.widthAnchor.constraint(equalTo: statsHeaderView.widthAnchor, multiplier: 0.250).isActive = true
        
        runTimeLabel.leadingAnchor.constraint(equalTo: runSpeedLabel.trailingAnchor).isActive = true
        runTimeLabel.topAnchor.constraint(equalTo: statsHeaderView.topAnchor).isActive = true
        runTimeLabel.bottomAnchor.constraint(equalTo: statsHeaderView.bottomAnchor).isActive = true
        runTimeLabel.trailingAnchor.constraint(equalTo: statsHeaderView.trailingAnchor).isActive = true
        
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
    
    @objc func sortByDistance() {
        if sortDistanceClicked == true {
            sortDistanceClicked = false
            runs.sort {
                $0.distance > $1.distance
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.sortLabelDistance.backgroundColor = Constants.mainColor
                self.sortLabelDistance.tintColor = Constants.accentColorDark
            }
        }
        else {
            sortDistanceClicked = true
            runs.sort {
                $0.distance < $1.distance
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.sortLabelDistance.backgroundColor = Constants.contrastColor
                self.sortLabelDistance.tintColor = Constants.mainColor
            }

        }
    }
    
    @objc func sortBySpeed() {
        if sortSpeedClicked == true {
            sortSpeedClicked = false
            runs.sort {
                $0.averageSpeed > $1.averageSpeed
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.sortLabelSpeed.backgroundColor = Constants.mainColor
                self.sortLabelSpeed.tintColor = Constants.accentColorDark
            }
        }
        else {
            sortSpeedClicked = true
            runs.sort {
                $0.averageSpeed < $1.averageSpeed
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.sortLabelSpeed.backgroundColor = Constants.contrastColor
                self.sortLabelSpeed.tintColor = Constants.mainColor
            }
        }
    }
    
    /* OBS! NOT SORT CORRECTLY! Becuase sorting as string instead of date*/
    @objc func sortByDate() {
        if sortDateClicked == true {
            sortDateClicked = false
            runs.sort {
                $0.date > $1.date
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.sortLabelDate.backgroundColor = Constants.mainColor
                self.sortLabelDate.tintColor = Constants.accentColorDark
            }
        }
        else {
            sortDateClicked = true
            runs.sort {
                $0.date < $1.date
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.sortLabelDate.backgroundColor = Constants.contrastColor
                self.sortLabelDate.tintColor = Constants.mainColor
            }
        }
    }
}

