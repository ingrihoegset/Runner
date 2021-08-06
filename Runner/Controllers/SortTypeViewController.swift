//
//  SortTypeViewController.swift
//  Runner
//
//  Created by Ingrid on 07/08/2021.
//

import UIKit

class SortViewController: UIViewController {
    
    var sortTableViewData = ["Speed"]
    let cellReuseIdentifier = "sortCell"
    var selectedTypes: [String] = []
    
    let mainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        return view
    }()
    
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
     
    let selectSortingButton: UIButton = {
         let button = UIButton()
         button.translatesAutoresizingMaskIntoConstraints = false
         button.backgroundColor = Constants.accentColor
         button.setTitle("Select", for: .normal)
         button.setTitleColor(.white, for: .normal)
         button.addTarget(self, action: #selector(selectSort), for: .touchUpInside)
         button.isUserInteractionEnabled = true
         button.tag = 1
         return button
    }()
    
    let closeSortingButton: UIButton = {
         let button = UIButton()
         button.translatesAutoresizingMaskIntoConstraints = false
         button.backgroundColor = Constants.accentColor
         button.setTitle("Close", for: .normal)
         button.setTitleColor(.white, for: .normal)
         button.addTarget(self, action: #selector(close), for: .touchUpInside)
         button.tag = 1
         return button
     }()
    
    let visualEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear

        view.addSubview(visualEffectView)
        view.addSubview(selectSortingButton)
        view.addSubview(closeSortingButton)
        view.addSubview(mainView)
        mainView.addSubview(sortHeader)
        mainView.addSubview(sortTableView)
        setConstraints()
        
        sortTableView.dataSource = self
        sortTableView.delegate = self
        sortTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        sortTableView.tableFooterView = UIView()

        // Do any additional setup after loading the view.
    }
    
    private func setConstraints() {
        
        visualEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.sideMargin).isActive = true
        mainView.bottomAnchor.constraint(equalTo: selectSortingButton.topAnchor, constant: -Constants.sideMargin).isActive = true
        mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        sortHeader.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        sortHeader.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        sortHeader.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        sortHeader.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        
        sortTableView.topAnchor.constraint(equalTo: sortHeader.bottomAnchor).isActive = true
        sortTableView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        sortTableView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        sortTableView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        
        selectSortingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        selectSortingButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: Constants.sideMargin).isActive = true
        selectSortingButton.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        selectSortingButton.widthAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        selectSortingButton.layer.cornerRadius = Constants.mainButtonSize / 2
        
        closeSortingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        closeSortingButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -Constants.sideMargin).isActive = true
        closeSortingButton.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        closeSortingButton.widthAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        closeSortingButton.layer.cornerRadius = Constants.mainButtonSize / 2
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func selectSort() {
        /*if let delegate = delegate {
            print(selectedTypes)
            delegate.sortByType(data: selectedTypes)
        }
        else {
            print("failed")
        }
        dismiss(animated: true, completion: nil)*/
    }
}

extension SortViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension SortViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = self.sortTableViewData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortTableViewData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.bounds.height * 0.1
    }
    
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedType = sortTableViewData[indexPath.row].type ?? ""
        selectedTypes.append(selectedType)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selectedType = sortTableViewData[indexPath.row].name
        selectedTypes.removeAll{$0 == selectedType}
    }*/
}
