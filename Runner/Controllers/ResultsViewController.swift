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
    
    deinit {
        print("DESTROYED RESULT PAGE")
    }
    
    /*
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "Tracks")
        return imageView
    }()*/
    
    let resultContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.shadeColor
        view.layer.cornerRadius = Constants.smallCornerRadius
        view.clipsToBounds = true
        view.layer.masksToBounds = false
        return view
    }()
    
    /*
    let raceTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Constants.textColorWhite
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = false
        label.text = "Run time"
        label.font = Constants.mainFontLargeSB
        return label
    }()*/
    
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
        label.textColor = Constants.textColorDarkGray
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
        label.textColor = Constants.textColorDarkGray
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
        label.textColor = Constants.accentColorDark
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
        label.textColor = Constants.accentColorDark
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = false
        label.font = Constants.resultFontMedium
        return label
    }()

    let detailComponent1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.accentColor
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = Constants.smallCornerRadius
        view.clipsToBounds = true
        view.layer.masksToBounds = false
        return view
    }()
    
    let detailComponent2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.accentColor
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Navigation bar appearance
        title = "Run completed!"
        
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: Constants.mainFontLargeSB!,
                                                                         NSAttributedString.Key.foregroundColor: Constants.textColorWhite]

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))

        setResults()
        
        // Makes navigation bar translucent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        view.backgroundColor = Constants.accentColorDark
        
        view.addSubview(resultContainer)
        resultContainer.addSubview(raceTimeMinutes)
        resultContainer.addSubview(raceTimeSeconds)
        resultContainer.addSubview(raceTimeHundreths)
        resultContainer.addSubview(raceTimeMinutesTitle)
        resultContainer.addSubview(raceTimeSecondsTitle)
        resultContainer.addSubview(raceTimeHundrethsTitle)

        view.addSubview(detailComponent1)
        detailComponent1.addSubview(racelengthTitle)
        detailComponent1.addSubview(racelengthResult)
        view.addSubview(detailComponent2)
        detailComponent2.addSubview(raceSpeedTitle)
        detailComponent2.addSubview(raceSpeedResult)
        
        view.addSubview(shareButtonView)
        
        setConstraints()
        startAnimation()
        
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
        
        resultContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        resultContainer.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 25).isActive = true
        resultContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.sideMargin).isActive = true
        resultContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true
        
        /*
        raceTimeLabel.centerXAnchor.constraint(equalTo: resultContainer.centerXAnchor).isActive = true
        raceTimeLabel.topAnchor.constraint(equalTo: resultContainer.topAnchor, constant: Constants.sideMargin).isActive = true
        raceTimeLabel.heightAnchor.constraint(equalTo: resultContainer.heightAnchor, multiplier: 0.1).isActive = true
        raceTimeLabel.widthAnchor.constraint(equalTo: resultContainer.widthAnchor).isActive = true*/
        
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
        
        detailComponent1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        detailComponent1.topAnchor.constraint(equalTo: resultContainer.bottomAnchor, constant: Constants.sideMargin).isActive = true
        detailComponent1.heightAnchor.constraint(equalToConstant: Constants.widthOfDisplay * 0.5 - Constants.sideMargin * 3/2).isActive = true
        detailComponent1.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -Constants.sideMargin / 2).isActive = true
        
        racelengthResult.trailingAnchor.constraint(equalTo: detailComponent1.trailingAnchor).isActive = true
        racelengthResult.centerYAnchor.constraint(equalTo: detailComponent1.centerYAnchor).isActive = true
        racelengthResult.heightAnchor.constraint(equalTo: detailComponent1.heightAnchor, multiplier: 0.4).isActive = true
        racelengthResult.leadingAnchor.constraint(equalTo: detailComponent1.leadingAnchor).isActive = true
        
        racelengthTitle.trailingAnchor.constraint(equalTo: detailComponent1.trailingAnchor).isActive = true
        racelengthTitle.bottomAnchor.constraint(equalTo: detailComponent1.bottomAnchor).isActive = true
        racelengthTitle.topAnchor.constraint(equalTo: racelengthResult.bottomAnchor).isActive = true
        racelengthTitle.leadingAnchor.constraint(equalTo: detailComponent1.leadingAnchor).isActive = true
        
        detailComponent2.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: Constants.sideMargin / 2).isActive = true
        detailComponent2.topAnchor.constraint(equalTo: resultContainer.bottomAnchor, constant: Constants.sideMargin).isActive = true
        detailComponent2.heightAnchor.constraint(equalToConstant: Constants.widthOfDisplay * 0.5 - Constants.sideMargin * 3/2).isActive = true
        detailComponent2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        raceSpeedResult.leadingAnchor.constraint(equalTo: detailComponent2.leadingAnchor).isActive = true
        raceSpeedResult.centerYAnchor.constraint(equalTo: detailComponent2.centerYAnchor).isActive = true
        raceSpeedResult.heightAnchor.constraint(equalTo: detailComponent2.heightAnchor, multiplier: 0.4).isActive = true
        raceSpeedResult.trailingAnchor.constraint(equalTo: detailComponent2.trailingAnchor).isActive = true
        
        raceSpeedTitle.leadingAnchor.constraint(equalTo: detailComponent2.leadingAnchor).isActive = true
        raceSpeedTitle.topAnchor.constraint(equalTo: raceSpeedResult.bottomAnchor).isActive = true
        raceSpeedTitle.bottomAnchor.constraint(equalTo: detailComponent2.bottomAnchor).isActive = true
        raceSpeedTitle.trailingAnchor.constraint(equalTo: detailComponent2.trailingAnchor).isActive = true
        
        /*
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 350).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 350).isActive = true*/
        
        shareButtonView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        shareButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        shareButtonView.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        shareButtonView.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay * 0.5).isActive = true
    
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
        
        raceTimeHundreths.text = result.hundreths
        raceTimeMinutes.text = result.minutes
        raceTimeSeconds.text = result.seconds
        racelengthResult.text = String(result.distance)
        raceSpeedResult.text = String(result.averageSpeed)
    }
    
    @objc private func shareResultOnSoMe() {
        let image = drawImagesAndText()
        let imageToShare = [image]
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    // Creates the SoME post
    func drawImagesAndText() -> UIImage {
        
        let size = 512
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))

        let img = renderer.image { ctx in

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left

            let mouse = UIImage(named: "SprintLady")
            mouse?.draw(at: CGPoint(x: 0, y: 0))
            
            guard let result = result else {
                raceTimeHundreths.text = "00"
                raceTimeMinutes.text = "00"
                raceTimeSeconds.text = "00"
                racelengthResult.text = "00"
                raceSpeedResult.text = "00"
                return
            }
            
            var speedUnit = ""
            var distanceUnit = ""
            if let metricSystem = UserDefaults.standard.value(forKey: "unit") as? Bool {
                if metricSystem == true {
                    speedUnit = "km/h"
                    distanceUnit = "m"
                }
                else {
                    speedUnit = "mph"
                    distanceUnit = "yd"
                }
            }
            else {
                speedUnit = "km/h"
                distanceUnit = "m"
            }
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: Constants.mainFontXLargeSB,
                .foregroundColor: Constants.mainColor,
                .backgroundColor: Constants.contrastColor!.withAlphaComponent(0.5)
            ]
            
            let largeAttrs: [NSAttributedString.Key: Any] = [
                .font: Constants.resultFont,
                .foregroundColor: Constants.mainColor,
                .backgroundColor: Constants.contrastColor!.withAlphaComponent(0.5),
            ]
            
            let largeTitleAttrs: [NSAttributedString.Key: Any] = [
                .font: Constants.resultFont,
                .foregroundColor: Constants.mainColor,
            ]
            
            // 3
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: Constants.mainFontXLarge,
                .foregroundColor: Constants.mainColor,
            ]
            
            let titleTime = "Time"
            let titleAttributedString = NSAttributedString(string: titleTime, attributes: titleAttrs)
            
            let titleDistance = "Run"
            let titleDistanceAttributedString = NSAttributedString(string: titleDistance, attributes: titleAttrs)
            
            let titleSpeed = "Speed"
            let titleSpeedAttributedString = NSAttributedString(string: titleSpeed, attributes: titleAttrs)

            let timeString = " \(result.minutes):\(result.seconds):\(result.hundreths) "
            let attributedString = NSAttributedString(string: timeString, attributes: largeAttrs)
            
            let distanceString = " \(String(result.distance)) \(distanceUnit) "
            let attributedDistanceString = NSAttributedString(string: distanceString, attributes: attrs)
            
            let speedString = " \(String(result.averageSpeed.round(to: 2))) \(speedUnit) "
            let attributedSpeedString = NSAttributedString(string: speedString, attributes: attrs)

            let title = "My run"
            let attributedTitle = NSAttributedString(string: title, attributes: largeTitleAttrs)
            
            let middel = size / 2
            let spacing = 36
            
            attributedTitle.draw(with: CGRect(x: middel - 90, y: 35, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
            
            titleAttributedString.draw(with: CGRect(x: 32, y: middel - spacing, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
            attributedString.draw(with: CGRect(x: 32, y: middel, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
            
            titleDistanceAttributedString.draw(with: CGRect(x: 32 , y: middel - 90 - spacing, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
            attributedDistanceString.draw(with: CGRect(x: 32, y: middel - 90, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
            
            titleSpeedAttributedString.draw(with: CGRect(x: 32, y: middel + 100, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
            attributedSpeedString.draw(with: CGRect(x: 32, y: middel + 100 + spacing, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
        }
        return img
    }
}



