//
//  StatsViewController.swift
//  CompSim
//
//  Created by Rami Sbahi on 6/26/20.
//  Copyright © 2020 Rami Sbahi. All rights reserved.
//

import UIKit
import Charts

var bestSingleAverageIndex: Int?
var bestSingleSolveIndex: Int? // index in average
var bestSingleTransition = false

var bestAverageIndex: Int?
var bestAverageTransition = false

var bestMoStartIndex: Int?
var bestMoTransition = false

var currentMoTransition = false

class StatsViewController: UIViewController {

    @IBOutlet weak var lineChart: LineChartView!
    
    @IBOutlet weak var BestSingleButton: UIButton!
    @IBOutlet weak var BestAverageButton: UIButton!
    @IBOutlet weak var MedianAverageButton: UIButton!
    @IBOutlet weak var CurrentMoButton: UIButton!
    @IBOutlet weak var BestMoButton: UIButton!
    
    @IBOutlet weak var CurrentMoLabel: UILabel!
    @IBOutlet weak var BestMoLabel: UILabel!
    
    @IBOutlet weak var SessionStackView: UIStackView!
    @IBOutlet weak var SessionButton: UIButton!
    
    var moChartEntries = [ChartDataEntry]()
    var SessionCollection: [UIButton] = []
    var medianChartEntries = [ChartDataEntry]()
    var medianTimeString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BestSingleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        MedianAverageButton.titleLabel?.adjustsFontSizeToFitWidth = true
        BestAverageButton.titleLabel?.adjustsFontSizeToFitWidth = true
        CurrentMoButton.titleLabel?.adjustsFontSizeToFitWidth = true
        BestMoButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        BestMoLabel.adjustsFontSizeToFitWidth = true
        CurrentMoLabel.adjustsFontSizeToFitWidth = true
        
        lineChart.setScaleEnabled(true)
        lineChart.noDataText = "No averages in this session yet!"
        lineChart.xAxis.labelFont = UIFont(name: "Lato-Black", size: 12.0)!
        lineChart.xAxis.labelTextColor = HomeViewController.darkBlueColor()
        lineChart.xAxis.labelPosition = .bottom
        lineChart.leftAxis.labelFont = UIFont(name: "Lato-Black", size: 12.0)!
        lineChart.leftAxis.labelTextColor = HomeViewController.darkBlueColor()
        lineChart.rightAxis.enabled = false
    

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        let radius = BestMoButton.frame.height / 2.0
        BestMoButton.layer.cornerRadius = radius
        CurrentMoButton.layer.cornerRadius = radius
    }
    
    @IBAction func SessionButtonClicked(_ sender: Any) {
        if SessionCollection.count > 0
        {
            if SessionCollection[0].isHidden
            {
                SessionButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            }
            else
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
                {
                    self.SessionButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                }
            }
        }
        
        SessionCollection.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func sessionNamed(title: String) -> Session?
    {
        for session in HomeViewController.allSessions
        {
            if session.name == title
            {
                return session
            }
        }
        return nil
    }
    
    @objc func SessionSelected(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            self.SessionButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
        SessionCollection.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
            button.setTitleColor(.white, for: .normal)
        }
        
        guard let title = sender.currentTitle else
        {
            return // doesn't have title
        }
        
        SessionButton.setTitle(title, for: .normal)
        sender.setTitleColor(HomeViewController.orangeColor(), for: .normal)
        
        if title != HomeViewController.mySession.name // exists,// not same - so switch session
        {
            HomeViewController.mySession = sessionNamed(title: title)!
            HomeViewController.mySession.updateScrambler()
            updateLabels()
            updateGraph()
            HomeViewController.mySession.scrambler.genScramble()
        }
    }
    
    func createButton(name: String) -> UIButton
    {
        SessionCollection.forEach({button in
            button.layer.cornerRadius = 0.0
        })
        
        let retButton = UIButton(type: .system)
        retButton.setTitle(name, for: .normal)
        retButton.isHidden = true
        retButton.setTitleColor(.white, for: .normal)
        retButton.titleLabel?.font = UIFont(name: "Lato-Black", size: 17)
        retButton.backgroundColor = HomeViewController.darkBlueColor()
        retButton.isUserInteractionEnabled = true
        retButton.addTarget(self, action: #selector(SessionSelected(_:)), for: UIControl.Event.touchUpInside)
        retButton.layer.cornerRadius = 6.0
        retButton.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        return retButton
    }
    
    // called whenever something changed with sessions
    func setUpStackView()
    {
        SessionButton.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        SessionButton.setTitle(HomeViewController.mySession.name, for: .normal)
        SessionCollection = []
        for session in HomeViewController.allSessions
        {
            let newButton = createButton(name: session.name)
            if session.name == HomeViewController.mySession.name
            {
                newButton.setTitleColor(HomeViewController.orangeColor(), for: .normal)
            }
            SessionCollection.append(newButton)
            SessionStackView.addArrangedSubview(newButton)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("STATS VIEW WILL APPEAR")
        
        setUpStackView()
        
        updateLabels()
        updateGraph()
    }
    
    func updateGraph()
    {
        var lineChartEntries = [ChartDataEntry]()
        var i: Double = 1
        for averageString in HomeViewController.mySession.allAverages
        {
            if averageString != "DNF"
            {
                let average = averageString.toFloatTime()
                lineChartEntries.append(ChartDataEntry(x: i, y: Double(average)))
            }
            i += 1
        }
        
        let line = LineChartDataSet(entries: lineChartEntries, label: "WCA")
        line.colors = [HomeViewController.darkBlueColor()]
        line.drawCirclesEnabled = false
        line.setDrawHighlightIndicators(false)
        
        let moLine = LineChartDataSet(entries: moChartEntries, label: "WCAmo10")
        moLine.colors = [HomeViewController.orangeColor()]
        moLine.drawCirclesEnabled = false
        moLine.setDrawHighlightIndicators(false)
        
        let medianLine = LineChartDataSet(entries: medianChartEntries, label: "Median Average")
        medianLine.colors = [HomeViewController.grayColor()]
        medianLine.drawCirclesEnabled = false
        medianLine.setDrawHighlightIndicators(false)
        
        let data = LineChartData()
        data.addDataSet(line)
        data.addDataSet(moLine)
        data.addDataSet(medianLine)
        data.setDrawValues(false)
        
        lineChart.data = data
        
        
    }
    
    func updateLabels()
    {
        updateBestSingle()
        updateBestAverage()
        updateMedianAverage()
        moChartEntries = []
        updateMo()
    }
    
    func updateBestSingle()
    {
        bestSingleAverageIndex = nil
        bestSingleSolveIndex = nil // index in average
        bestSingleTransition = false
        let allTimes = HomeViewController.mySession.allTimes
        for averageIndex in 0..<allTimes.count
        {
            let currList = allTimes[averageIndex].list
            for solveIndex in 0..<currList.count
            {
                if bestSingleSolveIndex == nil || currList[solveIndex].intTime < allTimes[bestSingleAverageIndex!].list[bestSingleSolveIndex!].intTime
                {
                    bestSingleSolveIndex = solveIndex
                    bestSingleAverageIndex = averageIndex
                }
            }
        }
        
        
        if bestSingleSolveIndex != nil
        {
            let minSolve = allTimes[bestSingleAverageIndex!].list[bestSingleSolveIndex!]
            var minString = minSolve.getMyString()
            let start = minString.index(minString.startIndex, offsetBy: 1)
            let end = minString.index(minString.endIndex, offsetBy: -1)
            if minString.contains("(")
            {
                minString = String(minString[start..<end])
            }
            
            
            let single = NSLocalizedString("Best single:  ", comment: "")
             let singleString = NSMutableAttributedString(string: "\(single)\(minString)", attributes: [NSAttributedString.Key.foregroundColor: HomeViewController.darkBlueColor()])
            singleString.addAttribute(NSAttributedString.Key.foregroundColor, value: HomeViewController.greenColor(), range: NSRange(location: single.count, length: singleString.length - single.count))
            BestSingleButton.setAttributedTitle(singleString, for: .normal)
        }
        else
        {
            BestSingleButton.setTitle("Best single:  ", for: .normal)
        }
    }
    
    func updateBestAverage()
    {
        bestAverageIndex = nil
        bestAverageTransition = false
        let allAverages = HomeViewController.mySession.allAverages
        for currIndex in 0..<allAverages.count
        {
            if bestAverageIndex == nil || allAverages[currIndex].toFloatTime() < allAverages[bestAverageIndex!].toFloatTime()
            {
                bestAverageIndex = currIndex
            }
        }
        
        if(bestAverageIndex != nil)
        {
            let minString = allAverages[bestAverageIndex!]
            let average = NSLocalizedString("Best average:  ", comment: "")
             let averageString = NSMutableAttributedString(string: "\(average)\(minString)", attributes: [NSAttributedString.Key.foregroundColor: HomeViewController.darkBlueColor()])
            averageString.addAttribute(NSAttributedString.Key.foregroundColor, value: HomeViewController.greenColor(), range: NSRange(location: average.count, length: averageString.length - average.count))
            BestAverageButton.setAttributedTitle(averageString, for: .normal)
        }
        else
        {
            BestAverageButton.setTitle("Best average:  ", for: .normal)
        }
    }
    
    func updateMedianAverage()
    {
        let sorted: [String] = HomeViewController.mySession.allAverages.sorted(by: {
            a, b in
            
            a.toFloatTime() < b.toFloatTime()
        })
        if sorted.count == 0
        {
            return
        }
        medianTimeString = ""
        if sorted.count % 2 != 0 {
            medianTimeString = sorted[sorted.count / 2]
        }
        else
        {
            let medianFloat = (sorted[sorted.count / 2].toFloatTime() + sorted[sorted.count / 2 - 1].toFloatTime()) / 2.0
            
            medianChartEntries.append(ChartDataEntry(x: 1.0, y: Double(medianFloat)))
            medianChartEntries.append(ChartDataEntry(x: Double(HomeViewController.mySession.allAverages.count), y: Double(medianFloat)))
            
            let medianInt = SolveTime.makeIntTime(num: medianFloat)
            if medianInt > 99999 // DNF
            {
                medianTimeString = "DNF"
            }
            else
            {
                medianTimeString = SolveTime.makeMyString(num: medianInt)
            }
        }
        
        let median = NSLocalizedString("MEDIAN AVERAGE:  ", comment: "")
         let medianString = NSMutableAttributedString(string: "\(median)\(medianTimeString!)", attributes: [NSAttributedString.Key.foregroundColor: HomeViewController.darkBlueColor()])
        medianString.addAttribute(NSAttributedString.Key.foregroundColor, value: HomeViewController.grayColor(), range: NSRange(location: median.count, length: medianString.length - median.count))
        MedianAverageButton.setAttributedTitle(medianString, for: .normal)
    }
    
    func updateMo()
    {
        let averages = HomeViewController.mySession.allAverages
        
        if averages.count >= 10
        {
            
            var sum: Float = 0
            
            for i in 0..<10 // add first 10
            {
                sum += averages[i].toFloatTime()
            }
            
            let initialMo: Float = sum / 10.0
            
            moChartEntries.append(ChartDataEntry(x: 10.0, y: Double(initialMo)))
            
            bestMoStartIndex = 0
            var bestMo: Float = initialMo
            
            for i in 10..<averages.count
            {
                sum -= averages[i - 10].toFloatTime()
                sum += averages[i].toFloatTime()
                
                let currentMo = sum / 10.0
                
                if currentMo < 9999
                {
                    moChartEntries.append(ChartDataEntry(x: Double(i + 1), y: Double(currentMo)))
                }
                
                if currentMo < bestMo
                {
                    bestMo = currentMo
                    bestMoStartIndex = i - 9
                }
            }
            
            // best mo10ao5s
            let bestMoInt = SolveTime.makeIntTime(num: bestMo)
            var bestMoString = "DNF"
            if bestMoInt <= 99999
            {
                bestMoString = SolveTime.makeMyString(num: bestMoInt)
            }
            BestMoButton.setTitle(bestMoString, for: .normal)
            
            // current mo10ao5s
            let currMoInt = SolveTime.makeIntTime(num: sum / 10.0)
            var currMoString = "DNF"
            if currMoInt <= 99999
            {
                currMoString = SolveTime.makeMyString(num: currMoInt)
            }
            CurrentMoButton.setTitle(currMoString, for: .normal)
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        closeStack()
        super.viewWillDisappear(animated)
    }
        
    func closeStack()
    {
        for button in SessionStackView.subviews
        {
            if button != SessionButton
            {
                button.isHidden = true
            }
        }
    }

    @IBAction func BestSingleClicked(_ sender: Any) {
        if bestSingleAverageIndex != nil
        {
            bestSingleTransition = true
            self.performSegue(withIdentifier: "SegueToSession", sender: self)
        }
    }
    
    @IBAction func BestAverageClicked(_ sender: Any) {
        if bestAverageIndex != nil
        {
            bestAverageTransition = true
            self.performSegue(withIdentifier: "SegueToSession", sender: self)
        }
    }
    
    @IBAction func MedianAverageClicked(_ sender: Any) {
        
    }
    
    @IBAction func BestMoClicked(_ sender: Any) {
        if bestMoStartIndex != nil
        {
            bestMoTransition = true
            self.performSegue(withIdentifier: "SegueToSession", sender: self)
        }
    }
    
    @IBAction func CurrentMoClicked(_ sender: Any) {
        if HomeViewController.mySession.currentAverage >= 9
        {
            currentMoTransition = true
            self.performSegue(withIdentifier: "SegueToSession", sender: self)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
