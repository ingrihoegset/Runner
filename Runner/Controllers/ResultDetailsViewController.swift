//
//  ResultDetailsViewController.swift
//  Runner
//
//  Created by Ingrid on 20/08/2021.
//
//


import UIKit
import Charts

class ResultDetailsViewController: UIViewController {
    
    let resultDetailsViewModel = ResultDetailsViewModel()
    
    var icon = "Favourite"
    
    var selectedRun = RunResults(time: 0.0,
                                 minutes: "00",
                                 seconds: "00",
                                 hundreths: "00",
                                 distance: 0,
                                 averageSpeed: 0.0,
                                 type: "Sprint",
                                 date: Date(),
                                 runID: "runid")
    
    var allruns = [RunResults]()
    
    var type = "Type"
    var distance = 0
    var time = "00:00"
    var lapLength = 0
    var averageSpeed = "00.00"
    var date = "3, July"
    var lapTimes: [Double] = [5.0]
    var laps = 0
    var metricSystemOnOpen = true
    
    let summaryView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: Constants.heightOfDisplay * 0.325).isActive = true
        view.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay - 2 * Constants.sideMargin).isActive = true
        view.backgroundColor = .clear
        view.layer.cornerRadius = Constants.smallCornerRadius
        view.layer.masksToBounds = false
        return view
    }()
    
    let detailRowDate: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Constants.resultFontXSmall
        button.titleLabel?.textColor = Constants.mainColorDark
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = Constants.mainColor
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.layer.masksToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin, spread: 0)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    let detailRowTime: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Constants.resultFontSmall
        button.titleLabel?.textColor = Constants.mainColorDark
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = Constants.mainColor
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.layer.masksToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin, spread: 0)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    let detailRowDistance: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Constants.resultFontSmall
        button.titleLabel?.textColor = Constants.mainColorDark
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = Constants.mainColor
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.layer.masksToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin, spread: 0)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    let detailRowSpeed: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Constants.resultFontSmall
        button.titleLabel?.textColor = Constants.mainColorDark
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = Constants.mainColor
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.layer.masksToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin, spread: 0)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    let lapsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: Constants.heightOfDisplay * 0.375).isActive = true
        view.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay - 2 * Constants.sideMargin).isActive = true
        view.backgroundColor = Constants.mainColor
        view.layer.cornerRadius = Constants.smallCornerRadius
        view.layer.masksToBounds = false
        view.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin, spread: 0)
        return view
    }()
    
    let reactionTimeView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 1.5).isActive = true
        view.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay - 2 * Constants.sideMargin).isActive = true
        view.backgroundColor = Constants.mainColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.smallCornerRadius
        view.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin, spread: 0)
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
    
    let tabGraphLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Constants.mainColor
        label.text = "Identical runs"
        label.textAlignment = .center
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.clipsToBounds = true
        label.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        label.font = Constants.mainFontLargeSB
        label.textColor = Constants.textColorAccent
        return label
    }()
    
    let shareButtonView: LargeImageButton = {
        let button = LargeImageButton()
        button.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        button.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay * 0.5).isActive = true
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
    
    lazy var lapsChartView: LineChartView = {
        let chartView = LineChartView()
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.decimalSeparator = "."
        leftAxisFormatter.minimumFractionDigits = 1
        leftAxisFormatter.maximumFractionDigits = 1
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.labelCount = 5
        leftAxis.axisLineColor = .clear
        leftAxis.axisMinimum = 0 // FIXME: HUH?? this replaces startAtZero = YES
        leftAxis.drawGridLinesEnabled = false
        leftAxis.labelTextColor = Constants.textColorAccent!
        leftAxis.labelFont = Constants.mainFont!
        
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = true
        rightAxis.labelCount = leftAxis.labelCount
        rightAxis.valueFormatter = leftAxis.valueFormatter
        rightAxis.spaceTop = 0.15
        rightAxis.axisLineColor = .clear
        rightAxis.axisMinimum = 0
        rightAxis.drawGridLinesEnabled = false
        rightAxis.labelTextColor = Constants.textColorAccent!
        rightAxis.labelFont = Constants.mainFont!
        
        let l = chartView.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .circle
        l.formSize = 9
        l.font = Constants.mainFont!
        l.textColor = Constants.textColorAccent!
        l.xOffset = -Constants.widthOfDisplay * 0.08
        
        chartView.animate(yAxisDuration: 2.0)
        chartView.pinchZoomEnabled = false
        chartView.drawBordersEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.drawGridBackgroundEnabled = false
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.backgroundColor = .clear
        chartView.xAxis.enabled = true
        chartView.xAxis.axisLineColor = .clear
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.gridColor = .clear
        chartView.xAxis.axisMinimum = 0.8
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelFont = Constants.mainFont!
        chartView.xAxis.labelTextColor = Constants.textColorAccent!

        return chartView
    }()
    
    let dontCollapseLargeTitleWhenScrollView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title =  type + " stats"
        
        resultDetailsViewModel.resultsViewModelDelegate = self
        self.navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = Constants.mainColorDark
        
        view.backgroundColor = Constants.mainColor
        
        view.addSubview(dontCollapseLargeTitleWhenScrollView)
        view.addSubview(scrollView)
        
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(summaryView)

        summaryView.addSubview(detailRowDate)
        summaryView.addSubview(detailRowTime)
        summaryView.addSubview(detailRowDistance)
        summaryView.addSubview(detailRowSpeed)
        
        reactionTimeView.addSubview(reactionTimeResultLabel)
        
        let resultAttributes = [NSAttributedString.Key.foregroundColor: Constants.mainColorDark, NSAttributedString.Key.font: Constants.resultFontSmall]
        let unitAttributes = [NSAttributedString.Key.foregroundColor: Constants.textColorAccent, NSAttributedString.Key.font: Constants.mainFontLargeSB]

        let timeResult = NSMutableAttributedString(string: time, attributes: resultAttributes as [NSAttributedString.Key : Any])
        let timeUnit = NSMutableAttributedString(string: " s", attributes: unitAttributes as [NSAttributedString.Key : Any])
        let timeText = NSMutableAttributedString()
        timeText.append(timeResult)
        timeText.append(timeUnit)
        
        let speedResult = NSMutableAttributedString(string: averageSpeed, attributes: resultAttributes as [NSAttributedString.Key : Any])
        var speedUnit = NSMutableAttributedString(string: " km/h", attributes: unitAttributes as [NSAttributedString.Key : Any])
        if metricSystemOnOpen == false {
            speedUnit = NSMutableAttributedString(string: " mph", attributes: unitAttributes as [NSAttributedString.Key : Any])
        }
        let speedText = NSMutableAttributedString()
        speedText.append(speedResult)
        speedText.append(speedUnit)
        
        let distResult = NSMutableAttributedString(string: String(distance), attributes: resultAttributes as [NSAttributedString.Key : Any])
        var distUnit = NSMutableAttributedString(string: " m", attributes: unitAttributes as [NSAttributedString.Key : Any])
        if metricSystemOnOpen == false {
            distUnit = NSMutableAttributedString(string: " yd", attributes: unitAttributes as [NSAttributedString.Key : Any])
        }
        let distText = NSMutableAttributedString()
        distText.append(distResult)
        distText.append(distUnit)
        
        let dateAttributes = [NSAttributedString.Key.foregroundColor: Constants.mainColorDark]
        let dated = NSMutableAttributedString(string: String(date), attributes: dateAttributes as [NSAttributedString.Key : Any])
        let dateText = NSMutableAttributedString()
        dateText.append(dated)
        
        if let reactionSeconds = selectedRun.reactionSeconds, let reactionHundreths = selectedRun.reactionHundreths {
            stackView.addArrangedSubview(reactionTimeView)
            let reactionText = NSMutableAttributedString()
            if reactionSeconds == "00" && reactionHundreths == "00" {
                let reactionTitle = NSMutableAttributedString(string: "Reaction time:  ", attributes: unitAttributes as [NSAttributedString.Key : Any])
                let reactionResult = NSMutableAttributedString(string: "N/A", attributes: resultAttributes as [NSAttributedString.Key : Any])
                reactionText.append(reactionTitle)
                reactionText.append(reactionResult)
                reactionTimeResultLabel.attributedText = reactionText
            }
            else {
                let reactionTitle = NSMutableAttributedString(string: "Reaction time:  ", attributes: unitAttributes as [NSAttributedString.Key : Any])
                let reactionResult = NSMutableAttributedString(string: "\(reactionSeconds).\(reactionHundreths)", attributes: resultAttributes as [NSAttributedString.Key : Any])
                let reactionUnit = NSMutableAttributedString(string: " s", attributes: unitAttributes as [NSAttributedString.Key : Any])
                reactionText.append(reactionTitle)
                reactionText.append(reactionResult)
                reactionText.append(reactionUnit)
                reactionTimeResultLabel.attributedText = reactionText
            }
        }
        
        stackView.addArrangedSubview(lapsView)
        stackView.addArrangedSubview(shareButtonView)

        detailRowDate.setAttributedTitle(dateText, for: .normal)
        detailRowTime.setAttributedTitle(timeText, for: .normal)
        detailRowDistance.setAttributedTitle(distText, for: .normal)
        detailRowSpeed.setAttributedTitle(speedText, for: .normal)

        lapsView.addSubview(tabGraphLabel)
        lapsView.addSubview(lapsChartView)
        
        // Sorts all runs so that page shows all identical runs, calls sortedRuns when complete
        resultDetailsViewModel.getAllIdenticalRunsLocally(selectedRun: selectedRun, allruns: allruns)
        
        setConstraints()
        startAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    deinit {
        print("DESTROYED \(self)")
    }
    
    func setConstraints() {
        dontCollapseLargeTitleWhenScrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        dontCollapseLargeTitleWhenScrollView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        dontCollapseLargeTitleWhenScrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        dontCollapseLargeTitleWhenScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        scrollView.topAnchor.constraint(equalTo: dontCollapseLargeTitleWhenScrollView.bottomAnchor).isActive = true
        scrollView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        
        let widthOfSummaryView = Constants.widthOfDisplay - 2 * Constants.sideMargin
        
        detailRowTime.topAnchor.constraint(equalTo: summaryView.topAnchor, constant: Constants.sideMargin).isActive = true
        detailRowTime.heightAnchor.constraint(equalTo: summaryView.heightAnchor, multiplier: 0.6).isActive = true
        detailRowTime.widthAnchor.constraint(equalToConstant: (widthOfSummaryView / 2) - (Constants.sideMargin / 2)).isActive = true
        detailRowTime.trailingAnchor.constraint(equalTo: summaryView.trailingAnchor).isActive = true
        
        detailRowDistance.topAnchor.constraint(equalTo: summaryView.topAnchor, constant: Constants.sideMargin).isActive = true
        detailRowDistance.heightAnchor.constraint(equalTo: detailRowSpeed.heightAnchor).isActive = true
        detailRowDistance.widthAnchor.constraint(equalToConstant: (widthOfSummaryView / 2) - (Constants.sideMargin / 2)).isActive = true
        detailRowDistance.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor).isActive = true
        
        detailRowDate.topAnchor.constraint(equalTo: detailRowTime.bottomAnchor, constant: Constants.sideMargin).isActive = true
        detailRowDate.bottomAnchor.constraint(equalTo: summaryView.bottomAnchor).isActive = true
        detailRowDate.widthAnchor.constraint(equalToConstant: (widthOfSummaryView / 2) - (Constants.sideMargin / 2)).isActive = true
        detailRowDate.trailingAnchor.constraint(equalTo: summaryView.trailingAnchor).isActive = true
        
        detailRowSpeed.topAnchor.constraint(equalTo: detailRowDistance.bottomAnchor, constant: Constants.sideMargin).isActive = true
        detailRowSpeed.bottomAnchor.constraint(equalTo: summaryView.bottomAnchor).isActive = true
        detailRowSpeed.widthAnchor.constraint(equalToConstant: (widthOfSummaryView / 2) - (Constants.sideMargin / 2)).isActive = true
        detailRowSpeed.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor).isActive = true
        
        tabGraphLabel.topAnchor.constraint(equalTo: lapsView.topAnchor, constant: Constants.sideMargin / 2).isActive = true
        tabGraphLabel.heightAnchor.constraint(equalTo: lapsView.heightAnchor, multiplier: 1/7).isActive = true
        tabGraphLabel.trailingAnchor.constraint(equalTo: lapsView.trailingAnchor).isActive = true
        tabGraphLabel.leadingAnchor.constraint(equalTo: lapsView.leadingAnchor).isActive = true
        
        lapsChartView.topAnchor.constraint(equalTo: tabGraphLabel.bottomAnchor).isActive = true
        lapsChartView.bottomAnchor.constraint(equalTo: lapsView.bottomAnchor, constant: -Constants.sideMargin / 2).isActive = true
        lapsChartView.leadingAnchor.constraint(equalTo: lapsView.leadingAnchor, constant: Constants.sideMargin / 2).isActive = true
        lapsChartView.trailingAnchor.constraint(equalTo: lapsView.trailingAnchor, constant: -Constants.sideMargin / 2).isActive = true
        
        reactionTimeResultLabel.trailingAnchor.constraint(equalTo: reactionTimeView.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        reactionTimeResultLabel.centerYAnchor.constraint(equalTo: reactionTimeView.centerYAnchor).isActive = true
        reactionTimeResultLabel.heightAnchor.constraint(equalTo: reactionTimeView.heightAnchor, multiplier: 0.8).isActive = true
        reactionTimeResultLabel.leadingAnchor.constraint(equalTo: reactionTimeView.leadingAnchor, constant: Constants.sideMargin).isActive = true
    }
    
    @objc func setDataForWaveChart() {
        var entries = [ChartDataEntry]()

        for i in 0...lapTimes.count - 1 {
            let entry = ChartDataEntry(x: Double(i+1), y: Double(lapTimes[i]) )
            entries.append(entry)
        }
        let set = LineChartDataSet(entries: entries)
        set.mode = .linear
        set.drawCirclesEnabled = true
        set.circleColors = [Constants.contrastColor ?? UIColor.white]
        set.circleHoleColor = Constants.contrastColor ?? UIColor.white
        set.lineWidth = Constants.borderWidth
        set.circleRadius = 5
        set.fill = Fill(color: Constants.contrastColor ?? UIColor.clear)
        set.fillAlpha = 1
        set.drawFilledEnabled = true
        set.highlightEnabled = false
        set.valueFont = Constants.mainFont!
        let data =  LineChartData(dataSet: set)
        data.setDrawValues(false)
        
        lapsChartView.legend.enabled = false
    
        lapsChartView.data = data
        if entries.count >= 1 {
            lapsChartView.xAxis.axisMaximum = entries.last!.x + 0.2
        }
        else {
            lapsChartView.xAxis.axisMaximum = lapsChartView.xAxis.axisMinimum
        }
    }
    
    @objc func shareResultOnSoMe() {
        let vc = ShareRunViewController()
        vc.result = self.selectedRun
        
        // Tells destination controller which units to display
        vc.metricSystemOnOpen = true
        if let metricSystem = UserDefaults.standard.value(forKey: "unit") as? Bool {
            if metricSystem == false {
                vc.metricSystemOnOpen = false
            }
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        self.navigationItem.backBarButtonItem = backItem
        vc.navigationController?.navigationItem.backBarButtonItem = backItem
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func secondsToHoursMinutesSeconds (seconds : Double) -> (Int, Int, Int, Int) {
        let int = Int(seconds)
        let rest = seconds - Double(int)
        return (int / 3600, (int % 3600) / 60, (int % 3600) % 60, Int(rest * 100))
    }
    
    func lapSpeed(lapLength: Int, laps: Int, lapTime: Double) -> Double {
        
        let km = Double(lapLength) / Double(1000)
        let hours = lapTime / 3600
        let speed = km / hours

        return speed
    }
    
    func startAnimation() {
        
        detailRowDistance.alpha = 0
        detailRowTime.alpha = 0
        detailRowSpeed.alpha = 0
        detailRowDate.alpha = 0
        lapsView.alpha = 0
        
        detailRowDistance.transform = CGAffineTransform(translationX: 0, y: 150)
        detailRowTime.transform = CGAffineTransform(translationX: 0, y: 175)
        detailRowSpeed.transform = CGAffineTransform(translationX: 0, y: 150)
        detailRowDate.transform = CGAffineTransform(translationX: 0, y: 160)
        reactionTimeView.transform = CGAffineTransform(translationX: 0, y: 160)
        lapsView.transform = CGAffineTransform(translationX: 0, y: 180)
        
        // Show cancel button and countdown label when start is clicked
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.detailRowDistance.transform = CGAffineTransform(translationX: 0, y: 0)
            self.detailRowDistance.alpha = 1
            UIView.animate(withDuration: 0.15, delay: 0.05, options: .curveEaseOut) {
                self.detailRowTime.transform = CGAffineTransform(translationX: 0, y: 0)
                self.detailRowTime.alpha = 1
            }
            UIView.animate(withDuration: 0.35, delay: 0.05, options: .curveEaseOut) {
                self.detailRowSpeed.transform = CGAffineTransform(translationX: 0, y: 0)
                self.detailRowDate.transform = CGAffineTransform(translationX: 0, y: 0)
                self.detailRowSpeed.alpha = 1
                self.detailRowDate.alpha = 1
                
            }
            UIView.animate(withDuration: 0.3, delay: 0.15, options: .curveEaseOut) {
                self.detailRowDate.transform = CGAffineTransform(translationX: 0, y: 0)
                self.detailRowDate.alpha = 1
                
            }
            UIView.animate(withDuration: 0.35, delay: 0.175, options: .curveEaseOut) {
                self.reactionTimeView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.reactionTimeView.alpha = 1
            }
            UIView.animate(withDuration: 0.4, delay: 0.2, options: .curveEaseOut) {
                self.lapsView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.lapsView.alpha = 1
            }
        }) { (_) in
            
        }
    }
}

extension ResultDetailsViewController: ResultDetailsViewModelDelegate {
    func sortedRuns(sortedRuns: [Double]) {
        DispatchQueue.main.async {
            self.lapTimes = sortedRuns
            self.setDataForWaveChart()
        }
    }
}


