//
//  StatisticsViewController.swift
//  Runner
//
//  Created by Ingrid on 22/07/2021.
//

import UIKit

class StatisticsViewController: UIViewController, StatisticsViewModelDelegate {
    
    private var runs = [RunResults]()
    
    let statisticsViewModel = StatisticsViewModel()
    
    let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.accentColor
        return view
    }()
    
    let statsHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.accentColorDark
        return view
    }()
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Constants.mainColor
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        statisticsViewModel.statisticsViewModelDelegate = self
        statisticsViewModel.getCompletedRuns()
        
        title = "My Runs"
        view.backgroundColor = Constants.accentColor
        
        view.addSubview(headerView)
        view.addSubview(statsHeaderView)
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
        headerView.heightAnchor.constraint(equalToConstant: Constants.headerSize/2).isActive = true
        headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        statsHeaderView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        statsHeaderView.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.75).isActive = true
        statsHeaderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        statsHeaderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
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
}

