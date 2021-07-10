import Foundation
import UIKit

struct Constants {
 
    //Colors
    static let mainColor = UIColor(named: "MainColor")
    static let accentColor = UIColor(named: "AccentColor")
    static let accentColorDark = UIColor(named: "AccentColorDark")
    static let whiteColor = UIColor(named: "WhiteColor")
    static let contrastColor = UIColor(named: "ContrastColor")
    
    
    //Text Colors
    static let textColorMain = UIColor.black
    
    //Design dimensions
    static let cornerRadius: CGFloat = 12
    static let borderWidth: CGFloat = 1
    static let sideSpacing: CGFloat = 15
    static let verticalSpacing: CGFloat = 20
    static let fieldHeight: CGFloat = 52
    static let fieldHeightLarge: CGFloat = fieldHeight * 3
    
    //European Units
    static let meters = "m"
    static let seconds = "s"
    
    // Dimension
    static let widthOfDisplay = UIScreen.main.bounds.size.width
    static let heightOfDisplay = UIScreen.main.bounds.size.height
    static let sideMargin = widthOfDisplay * 0.05
    
    // Picker dimensions
    static let widthOfPickerLabel = Constants.widthOfDisplay * 0.2
    static let widthOfLengthPicker = widthOfPickerLabel * 3
    static let widthOfDelayPicker = widthOfPickerLabel * 2
}
