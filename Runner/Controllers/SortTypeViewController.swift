//
//  SortTypeViewController.swift
//  Runner
//
//  Created by Ingrid on 07/08/2021.
//

import UIKit

protocol SortTypeDelegate: AnyObject {
    func sortBySelectedType(types: [String])
}

class SortTypeViewController: UIViewController {
    
    var sortTableViewData = [UserRunSelections.runTypes.Sprint.rawValue, UserRunSelections.runTypes.Reaction.rawValue, UserRunSelections.runTypes.FlyingStart.rawValue]
    let cellReuseIdentifier = "sortCell"
    var selectedTypes: [String] = []
    
    weak var sortTypeDelegate: SortTypeDelegate?
    
    let sortHeader: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Constants.accentColor
        label.text = "Select Run Type"
        label.textColor = Constants.textColorWhite
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.font = Constants.mainFontSB
        label.clipsToBounds = true
        return label
    }()
    
    let sortTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Constants.mainColor
        tableView.allowsMultipleSelection = true
        tableView.layer.masksToBounds = true
        tableView.clipsToBounds = true
        return tableView
    }()
     
    let selectSortingButton: BounceButton = {
         let button = BounceButton()
         button.translatesAutoresizingMaskIntoConstraints = false
         button.backgroundColor = Constants.accentColorDark
         button.setTitle("Select", for: .normal)
         button.setTitleColor(.white, for: .normal)
         button.addTarget(self, action: #selector(selectSort), for: .touchUpInside)
         button.isUserInteractionEnabled = true
         button.tag = 1
         button.layer.cornerRadius = Constants.smallCornerRadius
         button.titleLabel?.font = Constants.mainFontLargeSB
         return button
    }()
    
    let closeSortingButton: BounceButton = {
         let button = BounceButton()
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
        
        title = "Select run type"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: Constants.mainFontLargeSB!,
                                                                         NSAttributedString.Key.foregroundColor: Constants.accentColor]
        
        // Makes navigation like rest of panel
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = Constants.accentColorDark
        
        navigationController?.navigationBar.tintColor = Constants.mainColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"),
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
    
    @objc func selectSort() {
        dismiss(animated: true, completion: {
            // Calls delegate function on Statistics VC
            self.sortTypeDelegate?.sortBySelectedType(types: self.selectedTypes)
        })
    }
}

extension SortTypeViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension SortTypeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.init(top: 0, left: Constants.sideMargin, bottom: 0, right: 0)
        cell.textLabel?.text = self.sortTableViewData[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = Constants.mainFont
        cell.textLabel?.textColor = Constants.textColorAccent
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortTableViewData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedType = sortTableViewData[indexPath.row]
        selectedTypes.append(selectedType)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selectedType = sortTableViewData[indexPath.row]
        selectedTypes.removeAll{$0 == selectedType}
    }
}
