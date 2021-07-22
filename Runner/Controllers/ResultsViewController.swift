//
//  ResultsViewController.swift
//  Runner
//
//  Created by Ingrid on 18/07/2021.
//

import UIKit

class ResultsViewController: UIViewController {
    
    var times: Double = 0.0
    
    let resultsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Constants.whiteColor
        label.textColor = .blue
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        view.addSubview(resultsLabel)
        resultsLabel.text = String("Seconds: \(times)")

        // Do any additional setup after loading the view.
    }
    
    
    deinit {
        print("DESTROYED RESULT PAGE")
    }
    
    override func viewDidLayoutSubviews() {
        resultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        resultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        resultsLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        resultsLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
    }
    

}
