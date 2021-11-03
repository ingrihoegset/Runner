//
//  BreakObserver.swift
//  Runner
//
//  Created by Ingrid on 15/07/2021.
//

//  This class analyzes whether a break has occured - i.e. whether or not someone has run passed the gate.

import Foundation
import AVFoundation
import UIKit

class BreakObserver {
    
    var recentFramesArray = [CGFloat]()
    private let numberOfFramesForAnalysis = 12
    private var sensitivity: CGFloat = (UserDefaults.standard.value(forKey: Constants.cameraSensitivity) as? CGFloat)!
    var currentTime: String

    init() {
        currentTime = ""
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setSensitivity),
            name: NSNotification.Name(Constants.cameraSensitivity),
            object: nil
        )
    }
    
    /// Uses current frame to check for a break by comparing to average of last frames.
    // Function first adds the average color of current frame to an array of recent frames.
    // Then, the average color of the frames in the array is calculated.
    // Then, check if current frame is sufficiently different from recent frames.
    // If so, conclude that a break has occured and return TRUE.
    
    func checkIfBreakHasOccured(cvPixelBuffer: CVPixelBuffer) -> Bool {
        let currentFrame = CIImage(cvPixelBuffer: cvPixelBuffer)

        // Crop outputted data to the focus area that will be analyzed
        let croppedimage = convertCIImageToCGImage(inputImage: currentFrame)
        let focusimage = CIImage(cgImage: croppedimage)

        // Get average color of focus frame
        let averageColorCurrentFocusFrame = focusimage.averageColor
       
        addCurrentFrameToArray(averageColorCurrentFocusFrame: averageColorCurrentFocusFrame)

        // When the analysis array is full, calculate if break has occured.
        if recentFramesArray.count >= numberOfFramesForAnalysis {
            let averageColorOfArray = findAverageColorOfRecentFramesArray(realTimeArray: recentFramesArray)
            let hasBroken = checkForBreak(average: averageColorOfArray, currentObservation: averageColorCurrentFocusFrame)
           // print("ACA ", averageColorOfArray, "arraycount ", recentFramesArray.count , "ACCF ",focusimage.averageColor)
            if (hasBroken == true) {
                print("Break has been detected")
                return true
            }
        }
        return false
    }
    
    /// Adds color of current frame to an array of most recent frames
    private func addCurrentFrameToArray(averageColorCurrentFocusFrame: CGFloat) {
        // Removes the oldest input from the matrix when the matrix reaches a certain size
        if(recentFramesArray.count >= numberOfFramesForAnalysis) {
            recentFramesArray.removeFirst(1)
        }
        
        // Appends color of current frame to back of data array
        recentFramesArray.append(averageColorCurrentFocusFrame)
    }
          
    /// Returns average color of the recent frames that are being analyzed
    private func findAverageColorOfRecentFramesArray(realTimeArray: [CGFloat]) -> CGFloat {
        var sum = CGFloat(0)
        var count = CGFloat(0)
        
        for i in 0...realTimeArray.count - 1 {
            sum = sum + realTimeArray[i]
            count = count + 1
        }

        let averageColor = sum / count
        return averageColor
    }
        
    /// Compares average color of recent frames with average color of current frame. If difference is bigger than sensitity constraint, we conclude that a break has occured, return true.
    private func checkForBreak(average: CGFloat, currentObservation: CGFloat) -> Bool {
        if (abs((currentObservation - average) / average) > sensitivity) {
            return true
        }
        else {
            return false
        }
    }
    
    /// Convert to CGI so that we can crop image before being analyzed
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage {
        let context = CIContext(options: nil)
        
        let width = inputImage.extent.width / 6
        let height = inputImage.extent.width / 6
        let x = inputImage.extent.width / 2 - width / 2
        let y = inputImage.extent.height / 2 - height / 2

        return context.createCGImage(inputImage, from: CGRect(x: x, y: y, width: width, height: height))!
    }
    
    @objc func setSensitivity() {
        print("Changed sensitivity to \((UserDefaults.standard.value(forKey: Constants.cameraSensitivity) as? CGFloat)!)")
        sensitivity = (UserDefaults.standard.value(forKey: Constants.cameraSensitivity) as? CGFloat)!
    }
}

//This extension reads in the source image and creates an extent for the full image.
//It then uses the “CIAreaAverage” filter to do the actual work, then renders the average color to a 1x1 image.
//Finally, it reads each of the color values into a UIColor, and sends it back.
extension CIImage {
    var averageColor: CGFloat {
   
        let extentVector = CIVector(x: self.extent.origin.x, y: self.extent.origin.y, z: self.extent.size.width, w: self.extent.size.height)

        let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: self, kCIInputExtentKey: extentVector])
        let outputImage = filter?.outputImage

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage!, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return CGFloat(bitmap[0]) / 255 + CGFloat(bitmap[1]) / 255 + CGFloat(bitmap[2]) / 255
    }
}
