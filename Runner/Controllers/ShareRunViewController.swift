//
//  ViewController.swift
//  Runner
//
//  Created by Ingrid on 29/11/2021.
//

import UIKit
import Photos

class ShareRunViewController: UIViewController, UIScrollViewDelegate {
    
    var selectedImage = UIImage(named: "Sprinter")
    var result: RunResults?
    var metricSystemOnOpen = true
    var photoFinishImage: UIImage?
    
    var imageArray = [UIImage]()
    
    // Helpers for image cropping
    let viewWidth = Constants.widthOfDisplay
    let viewHeight = Constants.heightOfDisplay * 0.75
    
    let dontCollapseLargeTitleWhenScrollView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        return view
    }()
    
    let shareImageLayer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        return view
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        scrollView.backgroundColor = Constants.mainColor
        return scrollView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeResult: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.layer.masksToBounds = true
        label.font = Constants.resultFontMedium
        label.textColor = Constants.textColorWhite
        label.text = " 00:00:00"
        label.backgroundColor = Constants.contrastColor
        return label
    }()
    
    let timeTitle: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = Constants.mainFontLarge
        titleLabel.textColor = Constants.textColorWhite
        titleLabel.text = " Time"
        titleLabel.backgroundColor = .clear
        return titleLabel
    }()
    
    let speedResult: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.layer.masksToBounds = true
        label.font = Constants.resultFontSmall
        label.textColor = Constants.textColorWhite
        label.text = " 00.00 km/h"
        label.backgroundColor = Constants.contrastColor
        return label
    }()
    
    let speedTitle: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = Constants.mainFontLarge
        titleLabel.textColor = Constants.textColorWhite
        titleLabel.text = " Speed"
        titleLabel.backgroundColor = .clear
        return titleLabel
    }()
    
    let distanceResult: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.layer.masksToBounds = true
        label.font = Constants.resultFontSmall
        label.textColor = Constants.textColorWhite
        label.text = " 0 m"
        label.backgroundColor = Constants.contrastColor
        return label
    }()
    
    let typeTitle: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = Constants.mainFontLarge
        titleLabel.textColor = Constants.textColorWhite
        titleLabel.text = " Sprint"
        titleLabel.backgroundColor = .clear
        return titleLabel
    }()
    
    let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Constants.mainColor
        self.title = "Share run"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: Constants.mainFontLargeSB!,
                                                                         NSAttributedString.Key.foregroundColor: Constants.mainColor!]
        
        self.navigationController?.navigationBar.tintColor = Constants.accentColorDark
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "camera"),
                                                              style: .done,
                                                              target: self,
                                                              action: #selector(presentCamera)),
                                              UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"),
                                                              style: .done,
                                                              target: self,
                                                              action: #selector(shareResultOnSoMe))]

        
        scrollView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        
        view.addSubview(dontCollapseLargeTitleWhenScrollView)
        view.addSubview(shareImageLayer)
        shareImageLayer.addSubview(scrollView)
        scrollView.addSubview(imageView)
        shareImageLayer.addSubview(timeResult)
        shareImageLayer.addSubview(timeTitle)
        shareImageLayer.addSubview(distanceResult)
        shareImageLayer.addSubview(typeTitle)
        shareImageLayer.addSubview(speedResult)
        shareImageLayer.addSubview(speedTitle)

        view.addSubview(collectionView)
        
        // Set image in imageview
        let image = grabPhoto(index: 0)
        if let finishImage = photoFinishImage {
            let scaleHeight = Constants.widthOfDisplay/finishImage.size.width
            let scaleWidth = Constants.widthOfDisplay/finishImage.size.height
            let maxScale = max(scaleWidth, scaleHeight)
            scrollView.minimumZoomScale = maxScale
            scrollView.zoomScale = maxScale
            imageView.image = finishImage
        }
        else {
            let scaleHeight = Constants.widthOfDisplay/image.size.width
            let scaleWidth = Constants.widthOfDisplay/image.size.height
            let maxScale = max(scaleWidth, scaleHeight)
            scrollView.minimumZoomScale = maxScale
            scrollView.zoomScale = maxScale
            imageView.image = image
        }

        // Set result texts
        setResults()
        
        // Get photos for photoselector
        grabPhotos()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewDidLayoutSubviews() {
        dontCollapseLargeTitleWhenScrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        dontCollapseLargeTitleWhenScrollView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        dontCollapseLargeTitleWhenScrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        dontCollapseLargeTitleWhenScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        shareImageLayer.heightAnchor.constraint(equalTo: shareImageLayer.widthAnchor).isActive = true
        shareImageLayer.topAnchor.constraint(equalTo: dontCollapseLargeTitleWhenScrollView.bottomAnchor).isActive = true
        shareImageLayer.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay).isActive = true
        shareImageLayer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        scrollView.heightAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: dontCollapseLargeTitleWhenScrollView.bottomAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay).isActive = true
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        imageView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        
        timeResult.topAnchor.constraint(equalTo: shareImageLayer.centerYAnchor, constant: Constants.mainButtonSize / 2).isActive = true
        timeResult.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        timeResult.trailingAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        timeResult.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        timeTitle.bottomAnchor.constraint(equalTo: timeResult.topAnchor).isActive = true
        timeTitle.leadingAnchor.constraint(equalTo: timeResult.leadingAnchor).isActive = true
        timeTitle.widthAnchor.constraint(equalTo: timeResult.widthAnchor).isActive = true
        timeTitle.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 0.7 * 0.75).isActive = true
        
        distanceResult.bottomAnchor.constraint(equalTo: timeTitle.topAnchor, constant: -Constants.sideMargin / 3).isActive = true
        distanceResult.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        distanceResult.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay * 0.2).isActive = true
        distanceResult.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 0.7).isActive = true
        
        typeTitle.bottomAnchor.constraint(equalTo: distanceResult.topAnchor).isActive = true
        typeTitle.leadingAnchor.constraint(equalTo: distanceResult.leadingAnchor).isActive = true
        typeTitle.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        typeTitle.heightAnchor.constraint(equalTo: distanceResult.heightAnchor, multiplier: 0.75).isActive = true
        
        speedResult.topAnchor.constraint(equalTo: speedTitle.bottomAnchor).isActive = true
        speedResult.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        speedResult.widthAnchor.constraint(equalTo: timeResult.widthAnchor, multiplier: 0.9).isActive = true
        speedResult.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 0.7).isActive = true
        
        speedTitle.topAnchor.constraint(equalTo: timeResult.bottomAnchor, constant: Constants.sideMargin / 3).isActive = true
        speedTitle.leadingAnchor.constraint(equalTo: speedResult.leadingAnchor).isActive = true
        speedTitle.widthAnchor.constraint(equalTo: speedResult.widthAnchor).isActive = true
        speedTitle.heightAnchor.constraint(equalTo: speedResult.heightAnchor, multiplier: 0.75).isActive = true
        
        collectionView.topAnchor.constraint(equalTo: shareImageLayer.bottomAnchor, constant: 1).isActive = true
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // Creates imageg out of what is in a view
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
    
    @objc private func shareResult() {
        presentPhotoActionSheet()
    }
    
    func setResults() {
        
        if let result = result {
            let speed = String(result.averageSpeed)
            var speedUnit = " km/h"
            if metricSystemOnOpen == false {
                speedUnit =  " mph"
            }
            
            let distance = String(result.distance)
            var distUnit = " m"
            if metricSystemOnOpen == false {
                distUnit = " yd"
            }
            
            let time = " \(result.minutes):\(result.seconds):\(result.hundreths)"
            
            timeResult.text = time
            distanceResult.text = " " + distance + distUnit
            speedResult.text = " " + speed + speedUnit
            typeTitle.text = result.type
        }
    }
    
    func setImageToCrop(image: UIImage){
        imageView.image = image
        let scaleHeight = scrollView.frame.size.width/image.size.width
        let scaleWidth = scrollView.frame.size.height/image.size.height
        let maxScale = max(scaleWidth, scaleHeight)
        scrollView.minimumZoomScale = maxScale
        scrollView.zoomScale = maxScale
    }
    
    /* // THIS CROP FUNCTION ACTUALLY WORKS; BUT ENDED UP NOT NEEDING IT - KEEP IT SECRET, KEEP IT SAFE.
    @objc func crop() {
        let scale:CGFloat = 1/scrollView.zoomScale
        let x:CGFloat = scrollView.contentOffset.x * scale
        let y:CGFloat = scrollView.contentOffset.y * scale
        let width:CGFloat = scrollView.frame.size.width * scale
        let height:CGFloat = scrollView.frame.size.height * scale
        let croppedCGImage = imageView.image?.cgImage?.cropping(to: CGRect(x: x, y: y, width: width, height: height))
        let croppedImage = UIImage(cgImage: croppedCGImage!)
        setImageToCrop(image: croppedImage)
    }*/
    
    @objc private func shareResultOnSoMe() {
        //crop()
        if let viewimage = image(with: shareImageLayer) {
            let activityController = UIActivityViewController(activityItems: [viewimage], applicationActivities: nil)
            present(activityController, animated: true, completion: nil)
        }
    }
}

// Extension with regards to showing user their photosfor selection in sharing
extension ShareRunViewController {
    
    func grabPhotos() {
        
        let authorization = PHPhotoLibrary.authorizationStatus()
        if authorization == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    let imageManager = PHImageManager.default()
                    
                    let requestOptions = PHImageRequestOptions()
                    requestOptions.isSynchronous = true
                    requestOptions.deliveryMode = .opportunistic
                    
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.fetchLimit = 100
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    
                    let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                    
                    if fetchResult.count > 0 {
                        for i in 0..<fetchResult.count {
                            
                            imageManager.requestImage(for: fetchResult.object(at: i) , targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: requestOptions, resultHandler:
                                {
                                    image, error in
                                    
                                    if let unwrappedimage = image {
                                        self.imageArray.append(unwrappedimage)
                                    }
                                })
                        }
                    }
                    else {
                        print("User has no photos.")
                        self.collectionView.reloadData()
                    }
                } else {}
            })
        }
        else if authorization == .authorized {
            let imageManager = PHImageManager.default()
            
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            requestOptions.deliveryMode = .opportunistic
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.fetchLimit = 100
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            if fetchResult.count > 0 {
                for i in 0..<fetchResult.count {
                    
                    imageManager.requestImage(for: fetchResult.object(at: i) , targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: requestOptions, resultHandler:
                        {
                            image, error in
                            
                            if let unwrappedimage = image {
                                self.imageArray.append(unwrappedimage)
                            }
                        })
                }
            }
            else {
                print("User has no photos.")
                self.collectionView.reloadData()
            }
        }
        
        

    }
    
    func grabPhoto(index: Int) -> UIImage {
        
        var returnImage = UIImage()
        
        let authorization = PHPhotoLibrary.authorizationStatus()
        if authorization == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    print("Authorized")
                    let imageManager = PHImageManager.default()
                    
                    let requestOptions = PHImageRequestOptions()
                    requestOptions.isSynchronous = true
                    requestOptions.deliveryMode = .highQualityFormat
                    
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    
                    let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                    
                    imageManager.requestImage(for: fetchResult.object(at: index), targetSize: CGSize(width: 512, height: 512), contentMode: .aspectFill, options: requestOptions, resultHandler:
                        {
                            image, error in
                            if let unwrappedimage = image {
                                returnImage = unwrappedimage
                            }
                        })

                }
            })
        }
        else if authorization == .authorized {
            print("Authorized")
            let imageManager = PHImageManager.default()
            
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            requestOptions.deliveryMode = .highQualityFormat
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            imageManager.requestImage(for: fetchResult.object(at: index), targetSize: CGSize(width: 512, height: 512), contentMode: .aspectFill, options: requestOptions, resultHandler:
                {
                    image, error in
                    if let unwrappedimage = image {
                        returnImage = unwrappedimage
                    }
                })
        }
        return returnImage
        
        
    }
}

extension ShareRunViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        
        cell.imageView.image = imageArray[indexPath.row]
        
        return cell
    }
}

extension ShareRunViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 4 - 1
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = grabPhoto(index: indexPath.row)
        setImageToCrop(image: image)
    }
}

/// All code assosiated with selecting a profile picture
extension ShareRunViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// Called when user cancels the taking of a picture
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    /// Called when user takes a photo or selects a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: {
            guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
                return
            }
            self.setImageToCrop(image: selectedImage)
        })
    }
    
    /// Creates an action sheet that allows the user to pick whether to take a photo or select a photo from library
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Select background for post",
                                            message: "How would you like to select a background?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentPhotoPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose background color",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    
    @objc func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
}
