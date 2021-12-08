
import UIKit

class HelpViewController: UIViewController {
    
    let tableViewData = [
        [Texts.howToOneDevice],
        [Texts.howToTwoDevices],
        [Texts.addSecondGate],
        [Texts.didntRegister],
        [Texts.reactionRun],
        [Texts.flyingStart],
        [Texts.falseStart],
        [Texts.tooManyRegisters]
    ]
    
    let identifier = "identifier"
    
    let sectionTitles: [String] = ["How to run with one gate?",
                                   "How to run with two gates?",
                                   "How do I add a second gate?",
                                   "Why didn't the gate register that I ran past it?",
                                   "What is a “reaction run”?",
                                   "What is “flying start”?",
                                   "What is a false start?",
                                   "Gates are detecting movements it should be detecting"]
    
    var hiddenSections: Set = [0,1,2,3,4,5,6,7]
    
    let dontCollapseLargeTitleWhenScrollView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        return view
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.clipsToBounds = true
        tableView.layer.masksToBounds = true
        return tableView
    }()

    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "FAQ"
        view.backgroundColor = Constants.mainColor
        self.navigationController?.navigationBar.backgroundColor = Constants.mainColor
        
        view.addSubview(dontCollapseLargeTitleWhenScrollView)
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        dontCollapseLargeTitleWhenScrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        dontCollapseLargeTitleWhenScrollView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        dontCollapseLargeTitleWhenScrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        dontCollapseLargeTitleWhenScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
}

extension HelpViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.textLabel?.text = tableViewData[indexPath.section][indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = Constants.mainFont
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.hiddenSections.contains(section) {
            return 0
        }
        
        return self.tableViewData[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.mainButtonSize
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = UIView()
        sectionView.backgroundColor = Constants.mainColor
        sectionView.layer.borderWidth = 1
        sectionView.layer.borderColor = Constants.superLightGrey?.cgColor
        
        let sectionButton = UILabel()
        sectionButton.translatesAutoresizingMaskIntoConstraints = false
        sectionView.addSubview(sectionButton)
        sectionButton.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: Constants.sideMargin).isActive = true
        sectionButton.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        sectionButton.topAnchor.constraint(equalTo: sectionView.topAnchor).isActive = true
        sectionButton.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor).isActive = true
        sectionButton.text = sectionTitles[section]
        sectionButton.textColor = Constants.accentColorDarkest
        sectionButton.numberOfLines = 0
        sectionButton.textAlignment = .left
        sectionButton.backgroundColor = Constants.mainColor
        sectionButton.font = Constants.mainFontSB
        sectionButton.sizeToFit()

        sectionButton.tag = section
        sectionButton.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.hideSection(sender:)))
        sectionButton.addGestureRecognizer(gesture)

        return sectionView
    }
    
    
    @objc private func hideSection(sender: UITapGestureRecognizer) {
        if let section = sender.view?.tag {
            func indexPathsForSection() -> [IndexPath] {
                var indexPaths = [IndexPath]()
                
                for row in 0..<self.tableViewData[section].count {
                    indexPaths.append(IndexPath(row: row,
                                                section: section))
                }
                
                return indexPaths
            }
            
            if self.hiddenSections.contains(section) {
                self.hiddenSections.remove(section)
                self.tableView.insertRows(at: indexPathsForSection(),
                                          with: .fade)
            } else {
                self.hiddenSections.insert(section)
                self.tableView.deleteRows(at: indexPathsForSection(),
                                          with: .fade)
            }
        }
        

    }
    
    
}
