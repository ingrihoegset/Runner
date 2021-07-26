//
//  RunTableViewCell.swift
//  Runner
//
//  Created by Ingrid on 23/07/2021.
//

import UIKit

class RunTableViewCell: UITableViewCell {
    
    static let identifier = "RunTableViewCell"
    
    private let runTypeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let runLapsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.font = Constants.mainFont
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let runTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.font = Constants.mainFont
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let runDistanceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.font = Constants.mainFont
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let runSpeedLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.font = Constants.mainFont
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let runDateLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.font = Constants.mainFontSmall
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(runTypeImageView)
        contentView.addSubview(runLapsLabel)
        contentView.addSubview(runTimeLabel)
        contentView.addSubview(runDistanceLabel)
        contentView.addSubview(runSpeedLabel)
        contentView.addSubview(runDateLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        runTypeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        runTypeImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        runTypeImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        runTypeImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.15).isActive = true
        
        runLapsLabel.leadingAnchor.constraint(equalTo: runTypeImageView.trailingAnchor).isActive = true
        runLapsLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        runLapsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        runLapsLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.1).isActive = true

        runDistanceLabel.leadingAnchor.constraint(equalTo: runLapsLabel.trailingAnchor).isActive = true
        runDistanceLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        runDistanceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        runDistanceLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25).isActive = true
        
        runSpeedLabel.leadingAnchor.constraint(equalTo: runDistanceLabel.trailingAnchor).isActive = true
        runSpeedLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        runSpeedLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        runSpeedLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.250).isActive = true
        
        runTimeLabel.leadingAnchor.constraint(equalTo: runSpeedLabel.trailingAnchor).isActive = true
        runTimeLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        runTimeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        runTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        runDateLabel.leadingAnchor.constraint(equalTo: runTimeLabel.leadingAnchor).isActive = true
        runDateLabel.topAnchor.constraint(equalTo: runTimeLabel.topAnchor).isActive = true
        runDateLabel.heightAnchor.constraint(equalTo: runTimeLabel.heightAnchor, multiplier: 0.2).isActive = true
        runDateLabel.trailingAnchor.constraint(equalTo: runTimeLabel.trailingAnchor, constant: -5).isActive = true
    }
    
    public func configure(with model: RunResults) {
        runTimeLabel.text = model.time
        runDistanceLabel.text = String(model.distance)
        runSpeedLabel.text = String(model.averageSpeed)
    }
}
