//
//  EditPhotoViewController.swift
//  Runner
//
//  Created by Ingrid on 11/11/2021.
//

import UIKit

class EditPhotoViewController: UIViewController, UIScrollViewDelegate {
    
    var photoFinishImage = UIImage()
    var textResultImage = UIImage()
    var redrawnImage = UIImage()
    var result: RunResults?
    
    // Helpers for image cropping
    let viewWidth = Constants.widthOfDisplay
    let viewHeight = Constants.heightOfDisplay * 0.75
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        return scrollView
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let textResultImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        return imageView
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

        navigationController?.navigationBar.tintColor = Constants.mainColor
        view.backgroundColor = Constants.accentColorDarkest
        self.title = "Photo finish"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: Constants.mainFontLargeSB!,
                                                                         NSAttributedString.Key.foregroundColor: Constants.mainColor!]
        
        scrollView.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        imageView.image = photoFinishImage
        view.addSubview(shareButtonView)
        view.addSubview(textResultImageView)
        
        let resultImage = drawImagesAndText(image: textResultImage)
        textResultImageView.image = resultImage
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewDidLayoutSubviews() {
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: shareButtonView.topAnchor, constant: -Constants.sideMargin).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        imageView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        textResultImageView.heightAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        textResultImageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        textResultImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        textResultImageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        shareButtonView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        shareButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        shareButtonView.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        shareButtonView.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay * 0.5).isActive = true
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func image(with view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
    
    
    @objc private func shareResultOnSoMe() {
        guard let imageToCrop = imageView.image else {
            return
        }
        
        let ratio = imageToCrop.size.height / scrollView.contentSize.height
        let origin = CGPoint(x: scrollView.contentOffset.x * ratio, y: scrollView.contentOffset.y * ratio)
        let size = CGSize(width: scrollView.bounds.size.width * ratio, height: scrollView.bounds.size.height * ratio)
        let cropFrame = CGRect(origin: origin, size: size)
        let croppedImage = imageToCrop.croppedInRect(rect: cropFrame)
        
        imageView.image = croppedImage
        scrollView.zoomScale = 1

        let viewimage = image(with: view)
    
        
        //let image = drawImagesAndText(image: croppedImage)
        let activityController = UIActivityViewController(activityItems: [viewimage], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    // Creates the SoME post
    private func drawImagesAndText(image: UIImage) -> UIImage {
        
        let size = 512
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        let img = renderer.image { ctx in

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left

            let mouse = image
            mouse.draw(at: CGPoint(x: 0, y: 0))
            
            guard let result = result else {
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
                .backgroundColor: Constants.contrastColor!.withAlphaComponent(1)
            ]
            
            let largeAttrs: [NSAttributedString.Key: Any] = [
                .font: Constants.resultFont,
                .foregroundColor: Constants.mainColor,
                .backgroundColor: Constants.contrastColor!.withAlphaComponent(1)
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
            
            let middel = size / 2
            let spacing = 36

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


extension UIImage {
    func croppedInRect(rect: CGRect) -> UIImage {
        func rad(_ degree: Double) -> CGFloat {
            return CGFloat(degree / 180.0 * .pi)
        }

        var rectTransform: CGAffineTransform
        switch imageOrientation {
        case .left:
            rectTransform = CGAffineTransform(rotationAngle: rad(90)).translatedBy(x: 0, y: -self.size.height)
        case .right:
            rectTransform = CGAffineTransform(rotationAngle: rad(-90)).translatedBy(x: -self.size.width, y: 0)
        case .down:
            rectTransform = CGAffineTransform(rotationAngle: rad(-180)).translatedBy(x: -self.size.width, y: -self.size.height)
        default:
            rectTransform = .identity
        }
        rectTransform = rectTransform.scaledBy(x: self.scale, y: self.scale)

        let imageRef = self.cgImage!.cropping(to: rect.applying(rectTransform))
        let result = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return result
    }
}
