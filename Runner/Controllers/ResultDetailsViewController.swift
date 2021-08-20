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
    
    var type = "Type"
    var distance = 0
    var time = "00:00"
    var lapLength = 0
    var averageSpeed = "00.00"
    var date = "3, July"
    var lapTimes: [Double] = [5.0]
    var laps = 0
    
    let summaryView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.accentColor
        view.layer.cornerRadius = Constants.smallCornerRadius
        view.layer.masksToBounds = false
        return view
    }()
    
    let detailRowType: DetailRow = {
        let view = DetailRow(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let detailRowTime: DetailRow = {
        let view = DetailRow(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let detailRowDistance: DetailRow = {
        let view = DetailRow(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let detailRowSpeed: DetailRow = {
        let view = DetailRow(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let lapsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.accentColorDark
        view.layer.cornerRadius = Constants.smallCornerRadius
        view.layer.masksToBounds = false
        return view
    }()
    
    let tabGraphLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Constants.accentColorDark
        label.text = "Identical Runs"
        label.textAlignment = .center
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.clipsToBounds = true
        label.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        label.font = Constants.mainFontLargeSB
        label.textColor = Constants.textColorWhite
        return label
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
        leftAxis.labelTextColor = Constants.textColorWhite
        leftAxis.labelFont = Constants.mainFont!
        
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = true
        rightAxis.labelCount = leftAxis.labelCount
        rightAxis.valueFormatter = leftAxis.valueFormatter
        rightAxis.spaceTop = 0.15
        rightAxis.axisLineColor = .clear
        rightAxis.axisMinimum = 0
        rightAxis.drawGridLinesEnabled = false
        rightAxis.labelTextColor = Constants.textColorWhite
        rightAxis.labelFont = Constants.mainFont!
        
        let l = chartView.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .circle
        l.formSize = 9
        l.font = Constants.mainFont!
        l.textColor = Constants.textColorWhite
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
        chartView.xAxis.labelTextColor = Constants.textColorWhite

        return chartView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Run Stats"
        
        resultDetailsViewModel.resultsViewModelDelegate = self
        
        view.backgroundColor = Constants.mainColor
        view.addSubview(summaryView)
        
        summaryView.addSubview(detailRowType)
        summaryView.addSubview(detailRowTime)
        summaryView.addSubview(detailRowDistance)
        summaryView.addSubview(detailRowSpeed)
        
        detailRowType.setProperties(title: "Run Type", unit: "", detail: type)
        detailRowTime.setProperties(title: "Time", unit: "s", detail: time)
        detailRowDistance.setProperties(title: "Total Distance", unit: "m", detail: String(lapLength * laps))
        detailRowSpeed.setProperties(title: "Average Speed", unit: "km/h", detail: averageSpeed)

        view.addSubview(lapsView)
        lapsView.addSubview(tabGraphLabel)
        lapsView.addSubview(lapsChartView)
        
        resultDetailsViewModel.getAllIdenticalRuns(type: type, distance: distance, completion: { [weak self]  success in
            if success {
                self?.setDataForWaveChart()
            }
            else {
                
            }
        })
        
        setConstraints()
    }
    
    func setConstraints() {
        
        summaryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.sideMargin).isActive = true
        summaryView.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        summaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        summaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        detailRowType.topAnchor.constraint(equalTo: summaryView.topAnchor).isActive = true
        detailRowType.heightAnchor.constraint(equalTo: summaryView.heightAnchor, multiplier: 1/4).isActive = true
        detailRowType.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor, constant: Constants.sideMargin).isActive = true
        detailRowType.trailingAnchor.constraint(equalTo: summaryView.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        detailRowTime.topAnchor.constraint(equalTo: detailRowType.bottomAnchor).isActive = true
        detailRowTime.heightAnchor.constraint(equalTo: summaryView.heightAnchor, multiplier: 1/4).isActive = true
        detailRowTime.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor, constant: Constants.sideMargin).isActive = true
        detailRowTime.trailingAnchor.constraint(equalTo: summaryView.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        detailRowDistance.topAnchor.constraint(equalTo: detailRowTime.bottomAnchor).isActive = true
        detailRowDistance.heightAnchor.constraint(equalTo: summaryView.heightAnchor, multiplier: 1/4).isActive = true
        detailRowDistance.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor, constant: Constants.sideMargin).isActive = true
        detailRowDistance.trailingAnchor.constraint(equalTo: summaryView.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        detailRowSpeed.topAnchor.constraint(equalTo: detailRowDistance.bottomAnchor).isActive = true
        detailRowSpeed.heightAnchor.constraint(equalTo: summaryView.heightAnchor, multiplier: 1/4).isActive = true
        detailRowSpeed.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor, constant: Constants.sideMargin).isActive = true
        detailRowSpeed.trailingAnchor.constraint(equalTo: summaryView.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        lapsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        lapsView.topAnchor.constraint(equalTo: summaryView.bottomAnchor, constant: Constants.sideMargin).isActive = true
        lapsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        lapsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        tabGraphLabel.topAnchor.constraint(equalTo: lapsView.topAnchor).isActive = true
        tabGraphLabel.heightAnchor.constraint(equalTo: lapsView.heightAnchor, multiplier: 1/7).isActive = true
        tabGraphLabel.trailingAnchor.constraint(equalTo: lapsView.trailingAnchor).isActive = true
        tabGraphLabel.leadingAnchor.constraint(equalTo: lapsView.leadingAnchor).isActive = true
        
        lapsChartView.topAnchor.constraint(equalTo: tabGraphLabel.bottomAnchor).isActive = true
        lapsChartView.bottomAnchor.constraint(equalTo: lapsView.bottomAnchor, constant: -Constants.sideMargin / 2).isActive = true
        lapsChartView.leadingAnchor.constraint(equalTo: lapsView.leadingAnchor, constant: Constants.sideMargin / 2).isActive = true
        lapsChartView.trailingAnchor.constraint(equalTo: lapsView.trailingAnchor, constant: -Constants.sideMargin / 2).isActive = true
    }
    
    @objc func setDataForWaveChart() {
        var entries = [ChartDataEntry]()
        for i in 0...lapTimes.count - 1 {
            let entry = ChartDataEntry(x: Double(i+1), y: Double(lapTimes[i]) )
            print(entry)
            entries.append(entry)
        }
        let set = LineChartDataSet(entries: entries)
        set.colors = [UIColor.white]
        set.mode = .linear
        set.drawCirclesEnabled = true
        set.circleColors = [.white]
        set.lineWidth = 3
        set.setColor(.white)
        set.fill = Fill(color: UIColor.clear)
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
}

extension ResultDetailsViewController: ResultDetailsViewModelDelegate {
    func sortedRuns(sortedRuns: [Double]) {
        DispatchQueue.main.async {
            self.lapTimes = sortedRuns
            self.setDataForWaveChart()
        }
    }
}
