//
//  RunTableViewCell.swift
//  Runner
//
//  Created by Ingrid on 23/07/2021.
//

import UIKit

class RunTableViewCell: UITableViewCell {
    
    static let identifier = "RunTableViewCell"
    var runID = ""
    
    let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.mainColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let runTypeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let runTypeImage: UIImageView = {
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
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(cellView)
        cellView.addSubview(runTypeImageView)
        runTypeImageView.addSubview(runTypeImage)
        cellView.addSubview(runLapsLabel)
        cellView.addSubview(runTimeLabel)
        cellView.addSubview(runDistanceLabel)
        cellView.addSubview(runSpeedLabel)
        runTimeLabel.addSubview(runDateLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let widthSides = (Constants.widthOfDisplay - 5 * Constants.sideMargin) * 0.25 + Constants.sideMargin * 1.5
        let widthMid = (Constants.widthOfDisplay - 5 * Constants.sideMargin) * 0.25 + Constants.sideMargin
        
        cellView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2.5).isActive = true
        cellView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        cellView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        cellView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2.5).isActive = true
        
        runTypeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.sideMargin/2).isActive = true
        runTypeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        runTypeImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.15).isActive = true
        runTypeImageView.widthAnchor.constraint(equalToConstant: widthMid * 0.5).isActive = true
        
        runTypeImage.centerYAnchor.constraint(equalTo: runTypeImageView.centerYAnchor).isActive = true
        runTypeImage.centerXAnchor.constraint(equalTo: runTypeImageView.centerXAnchor).isActive = true
        runTypeImage.widthAnchor.constraint(equalTo: runTypeImageView.widthAnchor, multiplier: 0.45).isActive = true
        runTypeImage.heightAnchor.constraint(equalTo: runTypeImageView.heightAnchor, multiplier: 0.45).isActive = true
        
        runLapsLabel.leadingAnchor.constraint(equalTo: runTypeImageView.trailingAnchor).isActive = true
        runLapsLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        runLapsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        runLapsLabel.widthAnchor.constraint(equalToConstant: widthMid * 0.5).isActive = true

        runDistanceLabel.leadingAnchor.constraint(equalTo: runLapsLabel.trailingAnchor).isActive = true
        runDistanceLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        runDistanceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        runDistanceLabel.widthAnchor.constraint(equalToConstant: widthMid).isActive = true
        
        runSpeedLabel.leadingAnchor.constraint(equalTo: runDistanceLabel.trailingAnchor).isActive = true
        runSpeedLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        runSpeedLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        runSpeedLabel.widthAnchor.constraint(equalToConstant: widthMid).isActive = true
        
        runTimeLabel.leadingAnchor.constraint(equalTo: runSpeedLabel.trailingAnchor).isActive = true
        runTimeLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        runTimeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        runTimeLabel.widthAnchor.constraint(equalToConstant: widthMid).isActive = true
        
        runDateLabel.leadingAnchor.constraint(equalTo: runTimeLabel.leadingAnchor).isActive = true
        runDateLabel.topAnchor.constraint(equalTo: runTimeLabel.topAnchor).isActive = true
        runDateLabel.heightAnchor.constraint(equalTo: runTimeLabel.heightAnchor, multiplier: 0.3).isActive = true
        runDateLabel.trailingAnchor.constraint(equalTo: runTimeLabel.trailingAnchor, constant: -5).isActive = true
    }
    
    public func configure(with model: RunResults) {
        runTimeLabel.text = String(model.time)
        runDistanceLabel.text = String(model.distance)
        runSpeedLabel.text = String(model.averageSpeed)
        runDateLabel.text = FirstGateViewModel.dateFormatterShort.string(from: model.date)
        if model.type == "Speed" {
            runTypeImage.image = UIImage(systemName: "bolt.fill")
            runTypeImage.tintColor = Constants.contrastColor
        }
    }
}
