//
//  StatisticsViewController.swift
//  Runner
//
//  Created by Ingrid on 22/07/2021.
//

import UIKit
import JGProgressHUD

class StatisticsViewController: UIViewController, StatisticsViewModelDelegate {
    
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
        button.setTitle("Run type", for: .normal)
        button.setTitleColor(Constants.textColorWhite, for: .normal)
        button.titleLabel?.font = Constants.mainFontLargeSB
        button.addTarget(self, action: #selector(presentSortType), for: .touchUpInside)
        button.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
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
        button.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
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
        let image = UIImage(systemName: "trash.fill")?.withTintColor(Constants.accentColorDark!)
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
        button.backgroundColor = Constants.mainColor
        button.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
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
        button.backgroundColor = Constants.mainColor
        button.titleLabel?.font = Constants.mainFontSB
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(Constants.accentColorDark, for: .normal)
        button.setTitleColor(Constants.mainColor, for: .selected)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(sortByTime), for: .touchUpInside)
        button.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        return button
    }()
    
    /// Labels for header of stats tabel view
    private let runDistanceButton: BounceButton = {
        let button = BounceButton()
        button.setTitle("m", for: .normal)
        if let metricSystem = UserDefaults.standard.value(forKey: "unit") as? Bool {
            if metricSystem == false {
                button.setTitle("yd", for: .normal)
            }
        }
        button.animationColor = Constants.mainColor
        button.backgroundColor = Constants.mainColor
        button.titleLabel?.font = Constants.mainFontSB
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(Constants.accentColorDark, for: .normal)
        button.setTitleColor(Constants.mainColor, for: .selected)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(sortByDistance), for: .touchUpInside)
        button.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        return button
    }()
    
    /// Labels for header of stats tabel view
    private let runSpeedButton: BounceButton = {
        let button = BounceButton()
        button.setTitle("km/h", for: .normal)
        if let metricSystem = UserDefaults.standard.value(forKey: "unit") as? Bool {
            if metricSystem == false {
                button.setTitle("mph", for: .normal)
            }
        }
        button.backgroundColor = Constants.mainColor
        button.titleLabel?.font = Constants.mainFontSB
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(Constants.accentColorDark, for: .normal)
        button.setTitleColor(Constants.mainColor, for: .selected)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(sortBySpeed), for: .touchUpInside)
        button.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        return button
    }()
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Constants.accentColor
        return tableView
    }()
    
    let noDataView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        let image = UIImage(systemName: "exclamationmark.circle")?.withTintColor(Constants.lightGray!, renderingMode: .alwaysOriginal)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        let label = UITextView()
        label.isScrollEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.text = "No runs to show yet. Complete your first run!"
        label.font = Constants.mainFont
        label.textColor = Constants.lightGray
        label.isUserInteractionEnabled = false
        view.addSubview(imageView)
        view.addSubview(label)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        return view
    }()
    
    /// Views related to onboarding
    let onBoardClickMe: OnBoardingBubble = {
        let bubble = OnBoardingBubble(frame: .zero, title: "Click me!", pointerPlacement: "topMiddle", dismisser: true)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.isHidden = true
        return bubble
    }()
    
    /// Related to loading skeleton for table view
    let gradientLayer1 = CAGradientLayer()
    let gradientLayer2 = CAGradientLayer()
    let gradientLayer3 = CAGradientLayer()
    let gradientLayer4 = CAGradientLayer()
    let gradientLayer5 = CAGradientLayer()
    let gradientLayer6 = CAGradientLayer()
    let gradientLayer7 = CAGradientLayer()
    let gradientLayer8 = CAGradientLayer()
    
    private let skeletonLoadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        return view
    }()
    
    private let fakeRow1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.superLightGrey
        view.layer.cornerRadius = Constants.smallCornerRadius
        return view
    }()
    
    private let fakeRow2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.superLightGrey
        view.layer.cornerRadius = Constants.smallCornerRadius
        return view
    }()
    
    private let fakeRow3: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.superLightGrey
        view.layer.cornerRadius = Constants.smallCornerRadius
        return view
    }()
    
    private let fakeRow4: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.superLightGrey
        view.layer.cornerRadius = Constants.smallCornerRadius
        return view
    }()
    
    private let fakeRow5: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.superLightGrey
        view.layer.cornerRadius = Constants.smallCornerRadius
        return view
    }()
    
    private let fakeRow6: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.superLightGrey
        view.layer.cornerRadius = Constants.smallCornerRadius
        return view
    }()
    
    private let fakeRow7: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.superLightGrey
        view.layer.cornerRadius = Constants.smallCornerRadius
        return view
    }()
    
    private let fakeRow8: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.superLightGrey
        view.layer.cornerRadius = Constants.smallCornerRadius
        return view
    }()
    
    let noConnectionView: NoConnectionView = {
        let view = NoConnectionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statisticsViewModel.statisticsViewModelDelegate = self
        statisticsViewModel.getCompletedRuns()
        onBoardClickMe.onBoardingBubbleDelegate = self
        
        navigationItem.title = "My runs"
        view.backgroundColor = Constants.accentColor
        
        navigationController?.navigationBar.tintColor = Constants.accentColorDark
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(resetTableView))
        
        view.addSubview(headerView)
        headerView.addSubview(sortTypeButton)
        headerView.addSubview(sortDateButton)
        view.addSubview(statsHeaderView)
        statsHeaderView.addSubview(editButton)
        statsHeaderView.addSubview(runDistanceButton)
        statsHeaderView.addSubview(runSpeedButton)
        statsHeaderView.addSubview(runTimeButton)
        view.addSubview(tableView)
        view.addSubview(noDataView)
        view.bringSubviewToFront(statsHeaderView)
        
        tableView.register(RunTableViewCell.self, forCellReuseIdentifier: RunTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        // So that cell separation line will go edge to edge
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        
        // Views related to onboarding
        view.addSubview(onBoardClickMe)
        
        // Related to loading table view
        view.addSubview(skeletonLoadingView)
        skeletonLoadingView.addSubview(fakeRow1)
        skeletonLoadingView.addSubview(fakeRow2)
        skeletonLoadingView.addSubview(fakeRow3)
        skeletonLoadingView.addSubview(fakeRow4)
        skeletonLoadingView.addSubview(fakeRow5)
        skeletonLoadingView.addSubview(fakeRow6)
        skeletonLoadingView.addSubview(fakeRow7)
        skeletonLoadingView.addSubview(fakeRow8)
        setup()
        
        // Related to internet connection
        view.addSubview(noConnectionView)
        NetworkManager.isUnreachable { _ in
            self.showNoConnection()
        }
        NetworkManager.isReachable { _ in
            self.showConnection()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showConnection),
            name: NSNotification.Name(Constants.networkIsReachable),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showNoConnection),
            name: NSNotification.Name(Constants.networkIsNotReachable),
            object: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        if let metricSystem = UserDefaults.standard.value(forKey: "unit") as? Bool {
            if metricSystem == true {
                runSpeedButton.setTitle("km/h", for: .normal)
                runDistanceButton.setTitle("m", for: .normal)
            }
            else {
                runSpeedButton.setTitle("mph", for: .normal)
                runDistanceButton.setTitle("yd", for: .normal)
            }
        }
        else {
            runSpeedButton.setTitle("km/h", for: .normal)
            runDistanceButton.setTitle("m", for: .normal)
        }
        
        // Related to skeleton loading screen
        gradientLayer1.frame = fakeRow1.bounds
        gradientLayer2.frame = fakeRow2.bounds
        gradientLayer3.frame = fakeRow3.bounds
        gradientLayer4.frame = fakeRow4.bounds
        gradientLayer5.frame = fakeRow5.bounds
        gradientLayer6.frame = fakeRow6.bounds
        gradientLayer7.frame = fakeRow7.bounds
        gradientLayer8.frame = fakeRow8.bounds
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
        
        noDataView.topAnchor.constraint(equalTo: statsHeaderView.bottomAnchor).isActive = true
        noDataView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        noDataView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        noDataView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        skeletonLoadingView.topAnchor.constraint(equalTo: statsHeaderView.bottomAnchor).isActive = true
        skeletonLoadingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        skeletonLoadingView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        skeletonLoadingView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        fakeRow1.topAnchor.constraint(equalTo: skeletonLoadingView.topAnchor, constant: 1).isActive = true
        fakeRow1.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize - 2).isActive = true
        fakeRow1.leadingAnchor.constraint(equalTo: skeletonLoadingView.leadingAnchor).isActive = true
        fakeRow1.trailingAnchor.constraint(equalTo: skeletonLoadingView.trailingAnchor).isActive = true
        
        fakeRow2.topAnchor.constraint(equalTo: fakeRow1.bottomAnchor, constant: 2).isActive = true
        fakeRow2.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize - 2).isActive = true
        fakeRow2.leadingAnchor.constraint(equalTo: skeletonLoadingView.leadingAnchor).isActive = true
        fakeRow2.trailingAnchor.constraint(equalTo: skeletonLoadingView.trailingAnchor).isActive = true
        
        fakeRow3.topAnchor.constraint(equalTo: fakeRow2.bottomAnchor, constant: 2).isActive = true
        fakeRow3.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize - 2).isActive = true
        fakeRow3.leadingAnchor.constraint(equalTo: skeletonLoadingView.leadingAnchor).isActive = true
        fakeRow3.trailingAnchor.constraint(equalTo: skeletonLoadingView.trailingAnchor).isActive = true
        
        fakeRow4.topAnchor.constraint(equalTo: fakeRow3.bottomAnchor, constant: 2).isActive = true
        fakeRow4.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize - 2).isActive = true
        fakeRow4.leadingAnchor.constraint(equalTo: skeletonLoadingView.leadingAnchor).isActive = true
        fakeRow4.trailingAnchor.constraint(equalTo: skeletonLoadingView.trailingAnchor).isActive = true
        
        fakeRow5.topAnchor.constraint(equalTo: fakeRow4.bottomAnchor, constant: 2).isActive = true
        fakeRow5.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize - 2).isActive = true
        fakeRow5.leadingAnchor.constraint(equalTo: skeletonLoadingView.leadingAnchor).isActive = true
        fakeRow5.trailingAnchor.constraint(equalTo: skeletonLoadingView.trailingAnchor).isActive = true
        
        fakeRow6.topAnchor.constraint(equalTo: fakeRow5.bottomAnchor, constant: 2).isActive = true
        fakeRow6.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize - 2).isActive = true
        fakeRow6.leadingAnchor.constraint(equalTo: skeletonLoadingView.leadingAnchor).isActive = true
        fakeRow6.trailingAnchor.constraint(equalTo: skeletonLoadingView.trailingAnchor).isActive = true
        
        fakeRow7.topAnchor.constraint(equalTo: fakeRow6.bottomAnchor, constant: 2).isActive = true
        fakeRow7.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize - 2).isActive = true
        fakeRow7.leadingAnchor.constraint(equalTo: skeletonLoadingView.leadingAnchor).isActive = true
        fakeRow7.trailingAnchor.constraint(equalTo: skeletonLoadingView.trailingAnchor).isActive = true
        
        fakeRow8.topAnchor.constraint(equalTo: fakeRow7.bottomAnchor, constant: 2).isActive = true
        fakeRow8.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize - 2).isActive = true
        fakeRow8.leadingAnchor.constraint(equalTo: skeletonLoadingView.leadingAnchor).isActive = true
        fakeRow8.trailingAnchor.constraint(equalTo: skeletonLoadingView.trailingAnchor).isActive = true
        
        // Views related to onboarding
        onBoardClickMe.topAnchor.constraint(equalTo: statsHeaderView.bottomAnchor, constant: Constants.mainButtonSize + 5).isActive = true
        onBoardClickMe.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4).isActive = true
        onBoardClickMe.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        onBoardClickMe.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        // View related to internet connection
        noConnectionView.topAnchor.constraint(equalTo: statsHeaderView.bottomAnchor).isActive = true
        noConnectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        noConnectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        noConnectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    deinit {
        print("DESTROYED \(self)")
    }
    
    @objc func showConnection() {
        UIView.animate(withDuration: 0.3, animations: {
            self.noConnectionView.alpha = 0
        })
    }
    
    @objc func showNoConnection() {
        UIView.animate(withDuration: 0.3, animations: {
            self.noConnectionView.alpha = 1
        })
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
    
    @objc func resetTableView() {
        unselectAllButtons()
        runs = allRuns
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
    
    /// Related to onboarding
    func showOnboardClickMe() {
        DispatchQueue.main.async {
            self.onBoardClickMe.isHidden = false
            self.onBoardClickMe.animateOnboardingBubble()
        }
    }
    
    func hideOnboardClickMe() {
        DispatchQueue.main.async {
            self.onBoardClickMe.isHidden = true
        }
    }
    
    func showNoRunDataView() {
        DispatchQueue.main.async {
            self.noDataView.isHidden = false
        }
    }
    
    func hideNoRunDataView() {
        DispatchQueue.main.async {
            self.noDataView.isHidden = true
        }
    }
    
    func hideSkeletonLoadView() {
        DispatchQueue.main.async {
            self.skeletonLoadingView.isHidden = true
        }
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
        
        destinationController.selectedRun = model
        destinationController.allruns = allRuns
        
        // Tells destination controller which units to display
        destinationController.metricSystemOnOpen = true
        if let metricSystem = UserDefaults.standard.value(forKey: "unit") as? Bool {
            if metricSystem == false {
                destinationController.metricSystemOnOpen = false
            }
        }
        
        // Related to onboarding
        statisticsViewModel.hasOnboardedClickMe()
        
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
            print(indexPath.row)
            tableView.beginUpdates()
            print(self.runs.count)
            
            self.statisticsViewModel.deleteRun(runID: runID, completion: { [weak self] success in
                if success {
                    /* Not needed - updates itself when deleted from database
                    self?.runs.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)*/
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
        
        if editButton.isSelected == true {
            editButton.isSelected = false
            DispatchQueue.main.async {
                self.editButton.backgroundColor = Constants.mainColor
            }
        }
        else {
            editButton.isSelected = true
            DispatchQueue.main.async {
                self.editButton.backgroundColor = Constants.contrastColor
            }
        }
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
        runDistanceButton.isSelected = false
        runTimeButton.isSelected = false
        runSpeedButton.isSelected = false
        sortTypeButton.isSelected = false
        sortDateButton.isSelected = false
        runTimeButton.backgroundColor = Constants.mainColor
        runDistanceButton.backgroundColor = Constants.mainColor
        runSpeedButton.backgroundColor = Constants.mainColor
        sortTypeButton.backgroundColor = Constants.accentColorDark
        sortDateButton.backgroundColor = Constants.accentColorDark
        runTimeButton.animationColor = Constants.mainColor
        runSpeedButton.animationColor = Constants.mainColor
        runDistanceButton.animationColor = Constants.mainColor
    }
    
    @objc func sortByDistance() {
        runTimeButton.isSelected = false
        runSpeedButton.isSelected = false
        runTimeButton.backgroundColor = Constants.mainColor
        runSpeedButton.backgroundColor = Constants.mainColor
        runTimeButton.animationColor = Constants.mainColor
        runSpeedButton.animationColor = Constants.mainColor
        if runDistanceButton.isSelected == true {
            runDistanceButton.isSelected = false
            runDistanceButton.backgroundColor = Constants.mainColor
            runDistanceButton.animationColor = Constants.mainColor
            runs.sort {
                $0.distance > $1.distance
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        else {
            runDistanceButton.isSelected = true
            runDistanceButton.backgroundColor = Constants.contrastColor
            runDistanceButton.animationColor = Constants.contrastColor
            runs.sort {
                $0.distance < $1.distance
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func sortBySpeed() {
        runTimeButton.isSelected = false
        runDistanceButton.isSelected = false
        runTimeButton.backgroundColor = Constants.mainColor
        runDistanceButton.backgroundColor = Constants.mainColor
        runDistanceButton.animationColor = Constants.mainColor
        runTimeButton.animationColor = Constants.mainColor
        if runSpeedButton.isSelected == true {
            runSpeedButton.isSelected = false
            runs.sort {
                $0.averageSpeed < $1.averageSpeed
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.runSpeedButton.backgroundColor = Constants.mainColor
                self.runSpeedButton.animationColor = Constants.mainColor
            }
        }
        else {
            runSpeedButton.isSelected = true
            runs.sort {
                $0.averageSpeed > $1.averageSpeed
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.runSpeedButton.backgroundColor = Constants.contrastColor
                self.runSpeedButton.animationColor = Constants.contrastColor
            }
        }
    }
    
    @objc func sortByTime() {
        runDistanceButton.isSelected = false
        runSpeedButton.isSelected = false
        runDistanceButton.backgroundColor = Constants.mainColor
        runSpeedButton.backgroundColor = Constants.mainColor
        runDistanceButton.animationColor = Constants.mainColor
        runSpeedButton.animationColor = Constants.mainColor
        if runTimeButton.isSelected == true {
            runTimeButton.isSelected = false
            runs.sort {
                $0.time > $1.time
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.runTimeButton.backgroundColor = Constants.mainColor
                self.runTimeButton.animationColor = Constants.mainColor
            }
        }
        else {
            runTimeButton.isSelected = true
            runs.sort {
                $0.time < $1.time
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.runTimeButton.backgroundColor = Constants.contrastColor
                self.runTimeButton.animationColor = Constants.contrastColor
            }
        }
    }
}

extension StatisticsViewController: OnBoardingBubbleDelegate {
    func handleDismissal(sender: UIView) {
        statisticsViewModel.hasOnboardedClickMe()
    }
}


// Functions related to skeleton loading screen
extension StatisticsViewController {
    
    private func setup() {
        
        gradientLayer1.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer1.endPoint = CGPoint(x: 1, y: 0.5)
        fakeRow1.layer.addSublayer(gradientLayer1)
        
        gradientLayer2.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer2.endPoint = CGPoint(x: 1, y: 0.5)
        fakeRow2.layer.addSublayer(gradientLayer2)
        
        gradientLayer3.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer3.endPoint = CGPoint(x: 1, y: 0.5)
        fakeRow3.layer.addSublayer(gradientLayer3)
        
        gradientLayer4.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer4.endPoint = CGPoint(x: 1, y: 0.5)
        fakeRow4.layer.addSublayer(gradientLayer4)
        
        gradientLayer5.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer5.endPoint = CGPoint(x: 1, y: 0.5)
        fakeRow5.layer.addSublayer(gradientLayer5)
        
        gradientLayer6.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer6.endPoint = CGPoint(x: 1, y: 0.5)
        fakeRow6.layer.addSublayer(gradientLayer6)
        
        gradientLayer7.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer7.endPoint = CGPoint(x: 1, y: 0.5)
        fakeRow7.layer.addSublayer(gradientLayer7)
        
        gradientLayer8.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer8.endPoint = CGPoint(x: 1, y: 0.5)
        fakeRow8.layer.addSublayer(gradientLayer8)
        
        let titleGroup = makeAnimationGroup()
        titleGroup.beginTime = 0.0
        gradientLayer1.add(titleGroup, forKey: "backgroundColor")
        gradientLayer2.add(titleGroup, forKey: "backgroundColor")
        gradientLayer3.add(titleGroup, forKey: "backgroundColor")
        gradientLayer4.add(titleGroup, forKey: "backgroundColor")
        gradientLayer5.add(titleGroup, forKey: "backgroundColor")
        gradientLayer6.add(titleGroup, forKey: "backgroundColor")
        gradientLayer7.add(titleGroup, forKey: "backgroundColor")
        gradientLayer8.add(titleGroup, forKey: "backgroundColor")
    }
    
    private func makeAnimationGroup(previousGroup: CAAnimationGroup? = nil) -> CAAnimationGroup {
        let animDuration: CFTimeInterval = 1.0
        let anim1 = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.backgroundColor))
        anim1.fromValue = Constants.superLightGrey?.cgColor
        anim1.toValue = UIColor(red: 250 / 255.0, green: 250 / 255.0, blue: 250 / 255.0, alpha: 1).cgColor
        anim1.duration = animDuration
        anim1.beginTime = 0.0
        
        let anim2 = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.backgroundColor))
        anim2.fromValue = UIColor(red: 250 / 255.0, green: 250 / 255.0, blue: 250 / 255.0, alpha: 1).cgColor
        anim2.toValue = Constants.superLightGrey?.cgColor
        anim2.duration = animDuration
        anim2.beginTime = anim1.beginTime + anim1.duration
        
        let group = CAAnimationGroup()
        group.animations = [anim1, anim2]
        group.repeatCount = .greatestFiniteMagnitude
        group.duration = anim2.beginTime + anim2.duration
        group.isRemovedOnCompletion = false
        
        return group
    }
}


