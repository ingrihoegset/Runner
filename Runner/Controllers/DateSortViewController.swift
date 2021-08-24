//
//  DateSortViewController.swift
//  Runner
//
//  Created by Ingrid on 24/08/2021.
//

import UIKit


protocol SortDateDelegate: AnyObject {
    func sortBySelectedDate(dates: [String])
}

class SortDateViewController: UIViewController {
    
    var hiddenSections = Set<Int>()
    var sortTableViewData = [[""]]
    
    let cellReuseIdentifier = "sortCell"
    var allRunYears = [""]
    var selectedDates: [String] = []
    
    weak var sortDateDelegate: SortDateDelegate?
    
    let sortTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Constants.mainColor
        tableView.allowsMultipleSelection = true
        tableView.layer.masksToBounds = true
        tableView.clipsToBounds = true
        return tableView
    }()
     
    let selectSortingButton: UIButton = {
         let button = UIButton()
         button.translatesAutoresizingMaskIntoConstraints = false
         button.backgroundColor = Constants.accentColorDark
         button.setTitle("Select", for: .normal)
         button.setTitleColor(.white, for: .normal)
         button.addTarget(self, action: #selector(selectDate), for: .touchUpInside)
         button.isUserInteractionEnabled = true
         button.tag = 1
         button.layer.cornerRadius = Constants.smallCornerRadius
         button.titleLabel?.font = Constants.mainFontLargeSB
         return button
    }()
    
    let closeSortingButton: UIButton = {
         let button = UIButton()
         button.translatesAutoresizingMaskIntoConstraints = false
         button.backgroundColor = Constants.accentColorDark
         button.setTitle("Close", for: .normal)
         button.setTitleColor(.white, for: .normal)
         button.addTarget(self, action: #selector(close), for: .touchUpInside)
         button.tag = 2
         button.layer.cornerRadius = Constants.smallCornerRadius
         button.titleLabel?.font = Constants.mainFontLargeSB
         return button
     }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Constants.mainColor
        
        title = "Select Dates"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: Constants.mainFontLargeSB!,
                                                                         NSAttributedString.Key.foregroundColor: Constants.accentColor]
        
        // Makes navigation like rest of panel
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = Constants.mainColor
        
        navigationController?.navigationBar.tintColor = Constants.accentColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(close))

        view.addSubview(selectSortingButton)
        view.addSubview(closeSortingButton)
        view.addSubview(sortTableView)

        sortTableView.dataSource = self
        sortTableView.delegate = self
        sortTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        sortTableView.tableFooterView = UIView()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sortTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        sortTableView.bottomAnchor.constraint(equalTo: selectSortingButton.topAnchor, constant: -Constants.sideMargin).isActive = true
        sortTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        sortTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        selectSortingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        selectSortingButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: Constants.sideMargin / 2).isActive = true
        selectSortingButton.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        selectSortingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        closeSortingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        closeSortingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        closeSortingButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -Constants.sideMargin / 2).isActive = true
        closeSortingButton.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func selectDate() {
        dismiss(animated: true, completion: {
            // Calls delegate function on Statistics VC
            self.sortDateDelegate?.sortBySelectedDate(dates: self.selectedDates)
        })
    }
}

extension SortDateViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.allRunYears.count
    }
}

extension SortDateViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.hiddenSections.contains(section) {
            return 0
        }
        
        return self.sortTableViewData[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = UIButton(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 60))
        sectionHeader.titleLabel?.font = Constants.mainFontLargeSB
        sectionHeader.titleLabel?.textColor = Constants.textColorMain
        sectionHeader.backgroundColor = Constants.accentColorDark
        sectionHeader.tag = section
        sectionHeader.addTarget(self,
                                action: #selector(self.hideSection(sender:)),
                                for: .touchUpInside)
        sectionHeader.setTitle(allRunYears[section], for: .normal)

        return sectionHeader
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60 // my custom height
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return allRunYears[section]
    }


    
    @objc private func hideSection(sender: UIButton) {
        let section = sender.tag
        
        func indexPathsForSection() -> [IndexPath] {
            var indexPaths = [IndexPath]()
            
            for row in 0..<self.sortTableViewData[section].count {
                indexPaths.append(IndexPath(row: row,
                                            section: section))
            }
            
            return indexPaths
        }
        
        if self.hiddenSections.contains(section) {
            self.hiddenSections.remove(section)
            self.sortTableView.insertRows(at: indexPathsForSection(),
                                      with: .fade)
        } else {
            self.hiddenSections.insert(section)
            self.sortTableView.deleteRows(at: indexPathsForSection(),
                                      with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.init(top: 0, left: Constants.sideMargin, bottom: 0, right: 0)
        cell.textLabel?.text = self.sortTableViewData[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedYear = self.tableView(tableView, titleForHeaderInSection: indexPath.section) {
            let selectedDate = sortTableViewData[indexPath.section][indexPath.row]
            selectedDates.append("\(selectedYear)/\(selectedDate)")
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let selectedYear = self.tableView(tableView, titleForHeaderInSection: indexPath.section) {
            let selectedDate = sortTableViewData[indexPath.section][indexPath.row]
            selectedDates.removeAll{$0 == ("\(selectedYear)/\(selectedDate)")}
        }
    }
}
