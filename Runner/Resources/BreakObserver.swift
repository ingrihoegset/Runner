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
    private let sensitivity: CGFloat = 0.2
    var currentTime: String

    init() {
        currentTime = ""
    }
    
    /// Uses current frame to check for a break by comparing to average of last frames.
    // Function first adds the current frame to an array of recent frames.
    // Then, the average color of the frames in the array is calculated.
    // Then, check if current frame is sufficiently different from recent frames.
    // If so, conclude that a break has occured and return TRUE.
    
    func checkIfBreakHasOccured(cvPixelBuffer: CVImageBuffer) -> Bool {
        let currentFrame = CIImage(cvPixelBuffer: cvPixelBuffer)
        
        
        addCurrentFrameToArray(currentFrame: currentFrame)
        
        // When the analysis array is full, calculate if break has occured.
        if recentFramesArray.count >= numberOfFramesForAnalysis {
            let averageColorOfArray = findAverageColorOfRecentFramesArray(realTimeArray: recentFramesArray)
            let hasBroken = checkForBreak(average: averageColorOfArray, currentObservation: currentFrame.averageColor)
            print("ACA ", averageColorOfArray, "arraycount ", recentFramesArray.count , "ACCF ",currentFrame.averageColor)
            if (hasBroken == true) {
                print("Break has been detected")
                return true
            }
        }
        return false
    }
    
    /// Adds current frame to an array of most recent frames
    private func addCurrentFrameToArray(currentFrame: CIImage) {
        // Removes the oldest input from the matrix when the matrix reaches a certain size
        if(recentFramesArray.count >= numberOfFramesForAnalysis) {
            recentFramesArray.removeFirst(1)
        }
        
        // Appends current frame to back of data array
        recentFramesArray.append(currentFrame.averageColor)
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
