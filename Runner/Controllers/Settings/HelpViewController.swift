
import UIKit

class HelpViewController: UIViewController {

    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "FAQ"
        view.backgroundColor = Constants.mainColor
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(label1)
        contentView.addSubview(label2)
        contentView.addSubview(label3)
    }
    
    let label1: UITextView = {
        let label = UITextView()
        let titleAttributes = [NSAttributedString.Key.foregroundColor: Constants.textColorAccent, NSAttributedString.Key.font: Constants.mainFontLargeSB]
        let infoTextAttributes = [NSAttributedString.Key.foregroundColor: Constants.textColorAccent, NSAttributedString.Key.font: Constants.mainFont]
        let title = NSMutableAttributedString(string: "This is the title\n", attributes: titleAttributes as [NSAttributedString.Key : Any])
        let infoText = NSMutableAttributedString(string: "Sed ut erat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?", attributes: infoTextAttributes as [NSAttributedString.Key : Any])
        let text = NSMutableAttributedString()
        text.append(title)
        text.append(infoText)
        label.attributedText = text
        label.sizeToFit()
        label.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.layer.masksToBounds = true
        label.clipsToBounds = true
        label.isScrollEnabled = false
        label.backgroundColor = Constants.mainColor
        label.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        return label
    }()
    
    let label2: UITextView = {
        let label = UITextView()
        let titleAttributes = [NSAttributedString.Key.foregroundColor: Constants.textColorAccent, NSAttributedString.Key.font: Constants.mainFontLargeSB]
        let infoTextAttributes = [NSAttributedString.Key.foregroundColor: Constants.textColorAccent, NSAttributedString.Key.font: Constants.mainFont]
        let title = NSMutableAttributedString(string: "This is the title\n", attributes: titleAttributes as [NSAttributedString.Key : Any])
        let infoText = NSMutableAttributedString(string: "Sed ut erat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?", attributes: infoTextAttributes as [NSAttributedString.Key : Any])
        let text = NSMutableAttributedString()
        text.append(title)
        text.append(infoText)
        label.attributedText = text
        label.sizeToFit()
        label.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.layer.masksToBounds = true
        label.clipsToBounds = true
        label.isScrollEnabled = false
        label.backgroundColor = Constants.mainColor
        label.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        return label
    }()
    
    let label3: UITextView = {
        let label = UITextView()
        let titleAttributes = [NSAttributedString.Key.foregroundColor: Constants.textColorAccent, NSAttributedString.Key.font: Constants.mainFontLargeSB]
        let infoTextAttributes = [NSAttributedString.Key.foregroundColor: Constants.textColorAccent, NSAttributedString.Key.font: Constants.mainFont]
        let title = NSMutableAttributedString(string: "This is the title\n", attributes: titleAttributes as [NSAttributedString.Key : Any])
        let infoText = NSMutableAttributedString(string: "Sed ut erat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?", attributes: infoTextAttributes as [NSAttributedString.Key : Any])
        let text = NSMutableAttributedString()
        text.append(title)
        text.append(infoText)
        label.attributedText = text
        label.sizeToFit()
        label.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.layer.masksToBounds = true
        label.clipsToBounds = true
        label.isScrollEnabled = false
        label.backgroundColor = Constants.mainColor
        label.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        return label
    }()
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        label1.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        label1.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        label1.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true
        
        label2.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        label2.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: Constants.sideMargin).isActive = true
        label2.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true

        label3.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        label3.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: Constants.sideMargin).isActive = true
        label3.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true
        label3.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
    }

}
