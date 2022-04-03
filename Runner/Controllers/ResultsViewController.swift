//
//  ResultsViewController.swift
//  Runner
//
//  Created by Ingrid on 18/07/2021.
//

import UIKit
import Social

class ResultsViewController: UIViewController {
    
    var result: RunResults?
    var photoFinishImage: UIImage?
    var unwrappedPhotoFinishImage = UIImage()
    
    deinit {
        print("DESTROYED RESULT PAGE")
    }
    
    let resultContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: Constants.heightOfDisplay * 0.35).isActive = true
        view.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay - 2 * Constants.sideMargin).isActive = true
        view.backgroundColor = Constants.shadeColor
        view.layer.cornerRadius = Constants.smallCornerRadius
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()
    
    let runIncompleteImageView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.mainColor
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        let imageView = UIImageView()
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "exclamationmark.circle")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        
        let label = UILabel()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.sideMargin * 2).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive  = true
        
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: view.widthAnchor).isActive  = true
        
        label.text = "Ups, couldn't calculate run time!\nNo break registered at first gate."
        label.font = Constants.mainFontLarge
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return view
    }()

    let raceTimeHundreths: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Constants.textColorWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = false
        label.font = Constants.resultFont
        return label
    }()
    
    let raceTimeSeconds: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Constants.textColorWhite
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = false
        label.font = Constants.resultFont
        return label
    }()
    
    let raceTimeMinutes: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Constants.textColorWhite
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = false
        label.font = Constants.resultFont
        return label
    }()
    
    let raceTimeHundrethsTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Constants.textColorWhite
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = false
        label.font = Constants.mainFont
        label.text = "Centiseconds"
        return label
    }()
    
    let raceTimeSecondsTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Constants.textColorWhite
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = false
        label.font = Constants.mainFont
        label.text = "Seconds"
        return label
    }()
    
    let raceTimeMinutesTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Constants.textColorWhite
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = false
        label.font = Constants.mainFont
        label.text = "Minutes"
        return label
    }()
    
    let raceSpeedTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Constants.textColorAccent
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = false
        label.font = Constants.mainFontLargeSB
        if let metricSystem = UserDefaults.standard.value(forKey: "unit") as? Bool {
            if metricSystem == true {
                label.text = "km/h"
            }
            else {
                label.text = "mph"
            }
        }
        else {
            label.text = "km/h"
        }
        return label
    }()
    
    let racelengthTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Constants.textColorAccent
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = false
        label.font = Constants.mainFontLargeSB
        if let metricSystem = UserDefaults.standard.value(forKey: "unit") as? Bool {
            if metricSystem == true {
                label.text = "meters"
            }
            else {
                label.text = "yards"
            }
        }
        else {
            label.text = "meters"
        }
        return label
    }()
    
    let raceSpeedResult: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Constants.mainColorDark
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = false
        label.font = Constants.resultFontMedium
        return label
    }()
    
    let racelengthResult: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Constants.mainColorDark
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = false
        label.font = Constants.resultFontMedium
        return label
    }()
    
    let reactionTimeView: UIView = {
        let view = UIView()
        view.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay - 2 * Constants.sideMargin).isActive = true
        view.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 1.5).isActive = true
        view.backgroundColor = Constants.mainColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.smallCornerRadius
        return view
    }()
    
    let reactionTimeResultLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Constants.mainColorDark
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = Constants.resultFontMedium
        return label
    }()
    
    let detailComponentView: UIView = {
        let view = UIView()
        view.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay - 2 * Constants.sideMargin).isActive = true
        view.heightAnchor.constraint(equalToConstant: (Constants.widthOfDisplay - Constants.sideMargin * 3) / 2).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let detailComponent1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = Constants.smallCornerRadius
        view.clipsToBounds = true
        view.layer.masksToBounds = false
        return view
    }()
    
    let detailComponent2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = Constants.smallCornerRadius
        view.clipsToBounds = true
        view.layer.masksToBounds = false
        return view
    }()
    
    let shareButtonView: LargeImageButton = {
        let button = LargeImageButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.contrastColor
        button.layer.cornerRadius = Constants.mainButtonSize / 2
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.title.text = "Share my run"
        button.title.textColor = Constants.textColorWhite
        button.title.font = Constants.mainFontSB
        let image = UIImage(systemName: "square.and.arrow.up")?.withTintColor(Constants.mainColor!)
        button.imageview.isOpaque = true
        button.imageview.alpha = 1
        button.imageview.image = image?.imageWithInsets(insets: UIEdgeInsets(top: 5, left: 10, bottom: 9, right: 5))
        button.addTarget(self, action: #selector(shareResultOnSoMe), for: .touchUpInside)
        return button
    }()
    
    let photoFinishButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 2
        button.layer.borderColor = Constants.mainColor?.cgColor
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(showPhotoFinishImage), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution  = .fill
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = Constants.sideMargin
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Navigation bar appearance
        title = "Run completed!"
        
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: Constants.mainFontLargeSB!,
                                                                         NSAttributedString.Key.foregroundColor: Constants.mainColor!]

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))


        
        // Makes navigation bar translucent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = Constants.mainColor
        
        view.backgroundColor = Constants.mainColorDark

        stackView.addArrangedSubview(resultContainer)
        // Reaction time view is addd to stack view if there is a reaction result (will only happen if the run is a reaction run).
        setResults()
        stackView.addArrangedSubview(detailComponentView)

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        resultContainer.addSubview(raceTimeMinutes)
        resultContainer.addSubview(raceTimeSeconds)
        resultContainer.addSubview(raceTimeHundreths)
        resultContainer.addSubview(raceTimeMinutesTitle)
        resultContainer.addSubview(raceTimeSecondsTitle)
        resultContainer.addSubview(raceTimeHundrethsTitle)
        
        // View that is shown if no start time was registered during flying start
        resultContainer.addSubview(runIncompleteImageView)
        resultContainer.addSubview(photoFinishButton)

        detailComponentView.addSubview(detailComponent1)
        detailComponent1.addSubview(racelengthTitle)
        detailComponent1.addSubview(racelengthResult)
        detailComponentView.addSubview(detailComponent2)
        detailComponent2.addSubview(raceSpeedTitle)
        detailComponent2.addSubview(raceSpeedResult)
        
        reactionTimeView.addSubview(reactionTimeResultLabel)
        
        view.addSubview(shareButtonView)
        photoFinishButton.setImage(photoFinishImage, for: .normal)
        
        setConstraints()
        startAnimation()
        
        if let image = photoFinishImage {
            photoFinishButton.isHidden = false
            unwrappedPhotoFinishImage = image
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
    }
    
    func startAnimation() {
        resultContainer.transform = CGAffineTransform(translationX: 0, y: 100)
        detailComponent1.transform = CGAffineTransform(translationX: 0, y: 150)
        detailComponent2.transform = CGAffineTransform(translationX: 0, y: 100)
        shareButtonView.transform = CGAffineTransform(translationX: 0, y: 150)
        
        // Show cancel button and countdown label when start is clicked
        UIView.animate(withDuration: 0.5, animations: {
            //self.summaryView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (_) in
            UIView.animate(withDuration: 0.3) {
                self.resultContainer.transform = CGAffineTransform(translationX: 0, y: 0)
            }
            UIView.animate(withDuration: 0.4) {
                //self.detailComponent1.transform = CGAffineTransform.identity
                //self.detailComponent2.transform = CGAffineTransform.identity
                self.detailComponent2.transform = CGAffineTransform(translationX: 0, y: 0)
            }
            UIView.animate(withDuration: 0.5) {
                self.detailComponent1.transform = CGAffineTransform(translationX: 0, y: 0)
            }
            UIView.animate(withDuration: 0.7) {
                self.shareButtonView.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        }
    }
    
    private func setConstraints() {
        
        scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: shareButtonView.topAnchor, constant: -Constants.sideMargin).isActive = true
        
        runIncompleteImageView.topAnchor.constraint(equalTo: resultContainer.topAnchor).isActive = true
        runIncompleteImageView.bottomAnchor.constraint(equalTo: resultContainer.bottomAnchor).isActive = true
        runIncompleteImageView.leadingAnchor.constraint(equalTo: resultContainer.leadingAnchor).isActive = true
        runIncompleteImageView.trailingAnchor.constraint(equalTo: resultContainer.trailingAnchor).isActive = true
        
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        raceTimeSeconds.centerXAnchor.constraint(equalTo: resultContainer.centerXAnchor).isActive = true
        raceTimeSeconds.centerYAnchor.constraint(equalTo: resultContainer.centerYAnchor).isActive = true
        raceTimeSeconds.heightAnchor.constraint(equalTo: resultContainer.heightAnchor, multiplier: 0.4).isActive = true
        raceTimeSeconds.widthAnchor.constraint(equalTo: resultContainer.widthAnchor, multiplier: 1/3).isActive = true
        
        raceTimeHundreths.leadingAnchor.constraint(equalTo: raceTimeSeconds.trailingAnchor).isActive = true
        raceTimeHundreths.centerYAnchor.constraint(equalTo: raceTimeSeconds.centerYAnchor).isActive = true
        raceTimeHundreths.heightAnchor.constraint(equalTo: resultContainer.heightAnchor, multiplier: 0.4).isActive = true
        raceTimeHundreths.widthAnchor.constraint(equalTo: resultContainer.widthAnchor, multiplier: 1/3).isActive = true
        
        raceTimeMinutes.trailingAnchor.constraint(equalTo: raceTimeSeconds.leadingAnchor).isActive = true
        raceTimeMinutes.centerYAnchor.constraint(equalTo: raceTimeSeconds.centerYAnchor).isActive = true
        raceTimeMinutes.heightAnchor.constraint(equalTo: resultContainer.heightAnchor, multiplier: 0.4).isActive = true
        raceTimeMinutes.widthAnchor.constraint(equalTo: resultContainer.widthAnchor, multiplier: 1/3).isActive = true
        
        raceTimeSecondsTitle.centerXAnchor.constraint(equalTo: resultContainer.centerXAnchor).isActive = true
        raceTimeSecondsTitle.topAnchor.constraint(equalTo: raceTimeSeconds.bottomAnchor).isActive = true
        raceTimeSecondsTitle.heightAnchor.constraint(equalTo: resultContainer.heightAnchor, multiplier: 0.1).isActive = true
        raceTimeSecondsTitle.widthAnchor.constraint(equalTo: resultContainer.widthAnchor, multiplier: 1/3).isActive = true
        
        raceTimeHundrethsTitle.leadingAnchor.constraint(equalTo: raceTimeSecondsTitle.trailingAnchor).isActive = true
        raceTimeHundrethsTitle.topAnchor.constraint(equalTo: raceTimeHundreths.bottomAnchor).isActive = true
        raceTimeHundrethsTitle.heightAnchor.constraint(equalTo: resultContainer.heightAnchor, multiplier: 0.1).isActive = true
        raceTimeHundrethsTitle.widthAnchor.constraint(equalTo: resultContainer.widthAnchor, multiplier: 1/3).isActive = true
        
        raceTimeMinutesTitle.trailingAnchor.constraint(equalTo: raceTimeSecondsTitle.leadingAnchor).isActive = true
        raceTimeMinutesTitle.topAnchor.constraint(equalTo: raceTimeMinutes.bottomAnchor).isActive = true
        raceTimeMinutesTitle.heightAnchor.constraint(equalTo: resultContainer.heightAnchor, multiplier: 0.1).isActive = true
        raceTimeMinutesTitle.widthAnchor.constraint(equalTo: resultContainer.widthAnchor, multiplier: 1/3).isActive = true
        
        detailComponent1.leadingAnchor.constraint(equalTo: detailComponentView.leadingAnchor).isActive = true
        detailComponent1.topAnchor.constraint(equalTo: detailComponentView.topAnchor).isActive = true
        detailComponent1.heightAnchor.constraint(equalTo:  detailComponentView.heightAnchor).isActive = true
        detailComponent1.trailingAnchor.constraint(equalTo: detailComponentView.centerXAnchor, constant: -Constants.sideMargin / 2).isActive = true
        
        racelengthResult.trailingAnchor.constraint(equalTo: detailComponent1.trailingAnchor).isActive = true
        racelengthResult.centerYAnchor.constraint(equalTo: detailComponent1.centerYAnchor).isActive = true
        racelengthResult.heightAnchor.constraint(equalTo: detailComponent1.heightAnchor, multiplier: 0.4).isActive = true
        racelengthResult.leadingAnchor.constraint(equalTo: detailComponent1.leadingAnchor).isActive = true
        
        racelengthTitle.trailingAnchor.constraint(equalTo: detailComponent1.trailingAnchor).isActive = true
        racelengthTitle.bottomAnchor.constraint(equalTo: detailComponent1.bottomAnchor).isActive = true
        racelengthTitle.topAnchor.constraint(equalTo: racelengthResult.bottomAnchor).isActive = true
        racelengthTitle.leadingAnchor.constraint(equalTo: detailComponent1.leadingAnchor).isActive = true
        
        detailComponent2.leadingAnchor.constraint(equalTo: detailComponentView.centerXAnchor, constant: Constants.sideMargin / 2).isActive = true
        detailComponent2.topAnchor.constraint(equalTo: detailComponentView.topAnchor).isActive = true
        detailComponent2.heightAnchor.constraint(equalTo: detailComponentView.heightAnchor).isActive = true
        detailComponent2.trailingAnchor.constraint(equalTo: detailComponentView.trailingAnchor).isActive = true
        
        raceSpeedResult.leadingAnchor.constraint(equalTo: detailComponent2.leadingAnchor).isActive = true
        raceSpeedResult.centerYAnchor.constraint(equalTo: detailComponent2.centerYAnchor).isActive = true
        raceSpeedResult.heightAnchor.constraint(equalTo: detailComponent2.heightAnchor, multiplier: 0.4).isActive = true
        raceSpeedResult.trailingAnchor.constraint(equalTo: detailComponent2.trailingAnchor).isActive = true
        
        raceSpeedTitle.leadingAnchor.constraint(equalTo: detailComponent2.leadingAnchor).isActive = true
        raceSpeedTitle.topAnchor.constraint(equalTo: raceSpeedResult.bottomAnchor).isActive = true
        raceSpeedTitle.bottomAnchor.constraint(equalTo: detailComponent2.bottomAnchor).isActive = true
        raceSpeedTitle.trailingAnchor.constraint(equalTo: detailComponent2.trailingAnchor).isActive = true
        
        shareButtonView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        shareButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        shareButtonView.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        shareButtonView.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay * 0.5).isActive = true
        
        photoFinishButton.topAnchor.constraint(equalTo: resultContainer.topAnchor, constant: Constants.sideMargin).isActive = true
        photoFinishButton.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        photoFinishButton.trailingAnchor.constraint(equalTo: resultContainer.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        photoFinishButton.widthAnchor.constraint(equalTo: photoFinishButton.heightAnchor).isActive = true
        photoFinishButton.layer.cornerRadius = Constants.mainButtonSize / 2
        
        reactionTimeResultLabel.trailingAnchor.constraint(equalTo: reactionTimeView.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        reactionTimeResultLabel.centerYAnchor.constraint(equalTo: reactionTimeView.centerYAnchor).isActive = true
        reactionTimeResultLabel.heightAnchor.constraint(equalTo: reactionTimeView.heightAnchor, multiplier: 0.8).isActive = true
        reactionTimeResultLabel.leadingAnchor.constraint(equalTo: reactionTimeView.leadingAnchor, constant: Constants.sideMargin).isActive = true
    }
    
    private func setResults() {
        guard let result = result else {
            raceTimeHundreths.text = "00"
            raceTimeMinutes.text = "00"
            raceTimeSeconds.text = "00"
            racelengthResult.text = "00"
            raceSpeedResult.text = "00"
            return
        }
        
        print(result.time)
        if result.time == 0 && result.type == UserRunSelections.runTypes.FlyingStart.rawValue {
            runIncompleteImageView.isHidden = false
        }
        
        raceTimeHundreths.text = result.hundreths
        raceTimeMinutes.text = result.minutes
        raceTimeSeconds.text = result.seconds
        racelengthResult.text = String(result.distance)
        raceSpeedResult.text = String(result.averageSpeed)
        
        let resultAttributes = [NSAttributedString.Key.foregroundColor: Constants.mainColorDark, NSAttributedString.Key.font: Constants.resultFontSmall]
        let unitAttributes = [NSAttributedString.Key.foregroundColor: Constants.textColorAccent, NSAttributedString.Key.font: Constants.mainFontLargeSB]
        if let reactionSeconds = result.reactionSeconds, let reationHundreths = result.reactionHundreths {
            stackView.addArrangedSubview(reactionTimeView)
            let reactionText = NSMutableAttributedString()
            if reactionSeconds == "00" && reationHundreths == "00" {
                let reactionTitle = NSMutableAttributedString(string: "Reaction time:  ", attributes: unitAttributes as [NSAttributedString.Key : Any])
                let reactionResult = NSMutableAttributedString(string: "N/A", attributes: resultAttributes as [NSAttributedString.Key : Any])
                reactionText.append(reactionTitle)
                reactionText.append(reactionResult)
                reactionTimeResultLabel.attributedText = reactionText
            }
            else {
                let reactionTitle = NSMutableAttributedString(string: "Reaction time:  ", attributes: unitAttributes as [NSAttributedString.Key : Any])
                let reactionResult = NSMutableAttributedString(string: "\(reactionSeconds).\(reationHundreths)", attributes: resultAttributes as [NSAttributedString.Key : Any])
                let reactionUnit = NSMutableAttributedString(string: " s", attributes: unitAttributes as [NSAttributedString.Key : Any])
                reactionText.append(reactionTitle)
                reactionText.append(reactionResult)
                reactionText.append(reactionUnit)
                reactionTimeResultLabel.attributedText = reactionText
            }
        }
    }
    
    @objc private func shareResultOnSoMe() {
        let vc = ShareRunViewController()
        vc.photoFinishImage = unwrappedPhotoFinishImage
        vc.result = result
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        vc.navigationController?.navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func showPhotoFinishImage() {
       shareResultOnSoMe()
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}


