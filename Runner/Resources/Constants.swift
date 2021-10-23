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
    static let shadeColor = UIColor(named: "WhiteShade")
    static let lightGray = UIColor(named: "LightGray")
    
    //Text Colors
    static let textColorMain = UIColor.black
    static let textColorWhite = UIColor.white
    static let textColorDarkGray = UIColor.darkGray
    
    //Design dimensions
    static let smallCornerRadius: CGFloat = 8
    static let cornerRadius: CGFloat = 16
    static let borderWidth: CGFloat = 0
    static let sideSpacing: CGFloat = 10
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
    static let headerSize: CGFloat = heightOfDisplay * 0.25 // 140 previously
    static let mainButtonSize: CGFloat = heightOfDisplay * 0.08
    static let sorterButtonWidth = (Constants.widthOfDisplay - (Constants.sideMargin * 2) - (Constants.verticalSpacingSmall * 4)) / 5
    
    // Picker dimensions
    static let widthOfPickerLabel = Constants.widthOfDisplay * 0.165
    static let widthOfLengthPicker = widthOfPickerLabel * 3 + 10
    static let widthOfDelayPicker = widthOfPickerLabel * 2 + 5
    
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
    static let mainFontXXLargeSB = UIFont(name: "BarlowSemiCondensed-SemiBold", size: 40)
    static let countDownFont = UIFont(name: "BarlowSemiCondensed-SemiBold", size: 120)
    static let resultFont = UIFont(name: "BarlowSemiCondensed-SemiBold", size: 70)
    static let resultFontSmall = UIFont(name: "BarlowSemiCondensed-SemiBold", size: 30)
    static let pickerFont = UIFont(name: "BarlowSemiCondensed-SemiBold", size: 45)
    
    // Set race VC texts
    static let noOfLaps = "Number of laps"
    static let lengthOfLap = "Distance to gate"
    static let delayTime = "Seconds count down"
    static let reactionPeriod = "Reaction period"
    
    // User Default Strings
    static let currentRunID = "currentRunID"
    static let profileImageURL = "profileImageURL"
    
    // User Default Onboarding strings
    static let hasOnBoardedScroll = "hasOnBoardedScroll"
    static let hasOnBoardedReaction = "hasOnboardedReaction"
    static let hasOnboardedStartLineTwoUsers = "hasOnboardedStartLineTwoUsers"
    static let hasOnboardedFinishLineOneUser = "hasOnboardedFinishLineOneUser"
    static let hasOnboardedConnectToPartner = "hasOnboardedConnectToPartner"
    static let hasOnboardedTableViewClickMe = "hasOnboardedTableViewClickMe"
    static let hasOnboardedScanPartnerQR = "hasOnboardedScanPartnerQR"
    static let hasOnboardedLetPartnerScanYourQR = "hasOnboardedLetPartnerScanYourQR"
    static let hasOnboardedOpenEndGate = "hasOnboardedOpenEndGate"
    static let hasOnboardedFinishLineTwoUsers = "hasOnboardedFinishLineTwoUsers"
    
    // Camera uses to know if race has started and whether it should listen for breaks or not
    static var isRunning = false
    
    // Network status
    static let networkIsReachable = "networkIsReachable"
    static let networkIsNotReachable = "networkIsNotReachable"
}
