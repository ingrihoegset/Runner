import Foundation
import UIKit

struct Constants {
 
    //Colors
    static let mainColor = UIColor(named: "MainColor")
    static let accentColor = UIColor(named: "AccentColor")
    static let accentColorDark = UIColor(named: "AccentColorDark")
    static let whiteColor = UIColor(named: "WhiteColor")
    static let contrastColor = UIColor(named: "ContrastColor")
    static let superLightGrey = UIColor(named: "SuperLightGrey")
    
    //Text Colors
    static let textColorMain = UIColor.black
    static let textColorWhite = UIColor.white
    
    //Design dimensions
    static let smallCornerRadius: CGFloat = 4
    static let cornerRadius: CGFloat = 16
    static let borderWidth: CGFloat = 0
    static let sideSpacing: CGFloat = 15
    static let verticalSpacing: CGFloat = 20
    static let verticalSpacingSmall: CGFloat = 10
    static let largeVerticalSpacing: CGFloat = UIScreen.main.bounds.size.height * 0.1
    static let fieldHeight: CGFloat = 52
    static let fieldHeightLarge: CGFloat = fieldHeight * 3
    
    //European Units
    static let meters = "m"
    static let seconds = "s"
    
    // Dimension
    static let widthOfDisplay = UIScreen.main.bounds.size.width
    static let heightOfDisplay = UIScreen.main.bounds.size.height
    static let sideMargin = widthOfDisplay * 0.05
    static let displayViewHeight: CGFloat = 100
    static let displayButtonHeight: CGFloat = 40
    
    static let imageSize: CGFloat = 130
    static let headerSize: CGFloat = 140
    static let mainButtonSize: CGFloat = 60
    static let sorterButtonWidth = (Constants.widthOfDisplay - (Constants.sideMargin * 2) - (Constants.verticalSpacingSmall * 4)) / 5
    
    // Picker dimensions
    static let widthOfPickerLabel = Constants.widthOfDisplay * 0.2
    static let widthOfLengthPicker = widthOfPickerLabel * 3
    static let widthOfDelayPicker = widthOfPickerLabel * 2
    
    // Fonts
        //Light
    static let mainFontLarge = UIFont(name: "BarlowSemiCondensed-Light", size: 22)
    static let mainFont = UIFont(name: "BarlowSemiCondensed-Light", size: 18)
    static let mainFontMedium = UIFont(name: "BarlowSemiCondensed-Light", size: 14)
    static let mainFontSmall = UIFont(name: "BarlowSemiCondensed-Light", size: 12)
        //Semi Bold
    static let mainFontSmallSB = UIFont(name: "BarlowSemiCondensed-SemiBold", size: 10)
    static let mainFontMediumSB = UIFont(name: "BarlowSemiCondensed-SemiBold", size: 14)
    static let mainFontSB = UIFont(name: "BarlowSemiCondensed-SemiBold", size: 18)
    static let mainFontLargeSB = UIFont(name: "BarlowSemiCondensed-SemiBold", size: 22)
    static let mainFontXLargeSB = UIFont(name: "BarlowSemiCondensed-SemiBold", size: 35)
    static let mainFontXXLargeSB = UIFont(name: "BarlowSemiCondensed-SemiBold", size: 55)
    static let countDownFont = UIFont(name: "BarlowSemiCondensed-SemiBold", size: 120)
    static let resultFont = UIFont(name: "BarlowSemiCondensed-SemiBold", size: 70)
    static let resultFontSmall = UIFont(name: "BarlowSemiCondensed-SemiBold", size: 40)
    
    // Set race VC texts
    static let noOfLaps = "Number of laps"
    static let lengthOfLap = "Distance to gate"
    static let delayTime = "Seconds count down"
    static let reactionPeriod = "Reaction period"
    
    // User Default Strings
    static let currentRunID = "currentRunID"
    static let profileImageURL = "profileImageURL"

    // Camera uses to know if race has started and whether it should listen for breaks or not
    static var isRunning = false
}
