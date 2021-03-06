//
//  TargetViewController.swift
//  CompSim
//
//  Created by Rami Sbahi on 7/19/19.
//  Copyright © 2019 Rami Sbahi. All rights reserved.
//

import UIKit
import RealmSwift

class TargetViewController: UIViewController {
    
    @IBOutlet weak var MinTimeLabel: UIButton!
    @IBOutlet weak var MaxTimeLabel: UIButton!
    @IBOutlet weak var SingleTimeLabel: UIButton!

    @IBOutlet weak var Dist1: UILabel!
    @IBOutlet weak var Dist2: UILabel!
    @IBOutlet weak var Dist3: UILabel!
    @IBOutlet weak var Dist4: UILabel!
    @IBOutlet weak var Dist5: UILabel!
    @IBOutlet weak var Dist6: UILabel!
    @IBOutlet weak var Dist7: UILabel!
    
    @IBOutlet weak var WinningTimeSetting: UISegmentedControl!
    @IBOutlet weak var DistributionImage: UIImageView!
    @IBOutlet weak var DistributionLabel: UILabel!
    @IBOutlet weak var ToLabel: UILabel!
    
    @IBOutlet var DistLabels: [UILabel]!
    
    @IBOutlet weak var TargetSettingLabel: UILabel!
    
    @IBOutlet var BlackWhiteLabels: [UILabel]!
    
    @IBOutlet var BigView: UIView!
    
    let realm = try! Realm()
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);
       
        MinTimeLabel.setTitle(SolveTime.makeMyString(num: HomeViewController.mySession.minTime), for: .normal) // set label to min
        MaxTimeLabel.setTitle(SolveTime.makeMyString(num: HomeViewController.mySession.maxTime), for: .normal) // set label to max
        SingleTimeLabel.setTitle(SolveTime.makeMyString(num: HomeViewController.mySession.singleTime), for: .normal)
        
        self.updateDistributionLabels()
        
        // set the selected segment correctly
        
        if(HomeViewController.mySession.targetType == 2)
        {
            try! realm.write {
                HomeViewController.mySession.targetType = 1
            }
        }
        WinningTimeSetting.selectedSegmentIndex = HomeViewController.mySession.targetType
        setup(type: HomeViewController.mySession.targetType)
        
        if(HomeViewController.darkMode)
        {
            makeDarkMode()
        }
        else
        {
            turnOffDarkMode()
        }
        
    }
    
    func setup(type: Int)
    {
        if(type == 0)
        {
            noWinningSetup()
        }
        else if(type == 1)
        {
            singleWinningSetup()
        }
        else
        {
            rangeWinningSetup()
        }
    }
    
    @IBAction func ValueChanged(_ sender: Any) // value changed on winning time setting
    {
        
        setup(type: WinningTimeSetting.selectedSegmentIndex)
        try! realm.write {
            HomeViewController.mySession.targetType = WinningTimeSetting.selectedSegmentIndex
        }
    }
    
    func noWinningSetup()
    {
        MaxTimeLabel.isHidden = true
        ToLabel.isHidden = true
        MinTimeLabel.isHidden = true
        SingleTimeLabel.isHidden = true
        DistributionLabel.isHidden = true
        DistributionImage.isHidden = true
        self.changeDistLabels(hide: true)
    }
    
    func singleWinningSetup()
    {
        SingleTimeLabel.isHidden = false
        MaxTimeLabel.isHidden = true
        ToLabel.isHidden = true
        MinTimeLabel.isHidden = true
        DistributionLabel.isHidden = true
        DistributionImage.isHidden = true
        ToLabel.isHidden = true
        self.changeDistLabels(hide: true)
    }
    
    func rangeWinningSetup()
    {
        SingleTimeLabel.isHidden = true
        MaxTimeLabel.isHidden = false
        ToLabel.isHidden = false
        MinTimeLabel.isHidden = false
        DistributionLabel.isHidden = false
        DistributionImage.isHidden = false
        ToLabel.isHidden = false
        self.changeDistLabels(hide: false)
    }
    
    func changeDistLabels(hide: Bool)
    {
        Dist1.isHidden = hide
        Dist2.isHidden = hide
        Dist3.isHidden = hide
        Dist4.isHidden = hide
        Dist5.isHidden = hide
        Dist6.isHidden = hide
        Dist7.isHidden = hide
    }
    
    @IBAction func MinTimeTouched(_ sender: Any) {
        
        let alertService = AlertService()
        let alert = alertService.alert(placeholder: NSLocalizedString("Time", comment: ""), usingPenalty: false, keyboardType: 0, myTitle: NSLocalizedString("Min Time", comment: ""),
                                       completion: {
            
            let inputTime = alertService.myVC.TextField.text!
            
            if HomeViewController.validEntryTime(time: inputTime)
            {
               let temp = SolveTime(enteredTime: inputTime, scramble: "")
               let str = temp.myString
               let intTime = temp.intTime
               
               if(intTime > HomeViewController.mySession.maxTime)
               {
                   self.MaxTimeLabel.setTitle(str, for: .normal) // set title to string version
                   try! self.realm.write
                   {
                       HomeViewController.mySession.maxTime = intTime
                   }
               }
               self.MinTimeLabel.setTitle(str, for: .normal) // set title to string version
               try! self.realm.write
               {
                   HomeViewController.mySession.minTime = intTime
               }
               self.updateDistributionLabels()
            }
            else
            {
                self.alertValidTime()
            }
        })
        
        self.present(alert, animated: true)
        
    }
    @IBAction func MaxTimeTouched(_ sender: Any) {
        
        let alertService = AlertService()
        let alert = alertService.alert(placeholder: NSLocalizedString("Time", comment: ""), usingPenalty: false, keyboardType: 0, myTitle: NSLocalizedString("Max Time", comment: ""),
                                       completion: {
            
            let inputTime = alertService.myVC.TextField.text!
            
            if HomeViewController.validEntryTime(time: inputTime)
            {
               let temp = SolveTime(enteredTime: inputTime, scramble: "")
               let str = temp.myString
               let intTime = temp.intTime
               
               if(intTime < HomeViewController.mySession.minTime)
               {
                   self.MinTimeLabel.setTitle(str, for: .normal) // set title to string version
                   try! self.realm.write
                   {
                       HomeViewController.mySession.minTime = intTime
                   }
               }
               self.MaxTimeLabel.setTitle(str, for: .normal) // set title to string version
               try! self.realm.write
               {
                   HomeViewController.mySession.maxTime = intTime
               }
               self.updateDistributionLabels()
            }
            else
            {
                self.alertValidTime()
            }
        })
        
        self.present(alert, animated: true)
    }
    
    @IBAction func SingleTimeTouched(_ sender: Any) {
        
        let alertService = AlertService()
        let alert = alertService.alert(placeholder: NSLocalizedString("Time", comment: ""), usingPenalty: false, keyboardType: 0, myTitle: NSLocalizedString("Target Time", comment: ""),
                                       completion: {
            
            let inputTime = alertService.myVC.TextField.text!
            
            if HomeViewController.validEntryTime(time: inputTime)
            {
               let temp = SolveTime(enteredTime: inputTime, scramble: "")
               let str = temp.myString
               let intTime = temp.intTime
               
               self.SingleTimeLabel.setTitle(str, for: .normal) // set title to string version
               try! self.realm.write
               {
                   HomeViewController.mySession.singleTime = intTime
               }
               self.updateDistributionLabels()
            }
            else
            {
                self.alertValidTime()
            }
        })
        
        self.present(alert, animated: true)
    }
    
    func alertValidTime()
    {
        let alertService = NotificationAlertService()
        let alert = alertService.alert(myTitle: NSLocalizedString("Invalid Time", comment: ""))
        self.present(alert, animated: true, completion: nil)
        // ask again - no input
    }
    
    override func viewDidLayoutSubviews() {
        let rangeFont = HomeViewController.fontToFitHeight(view: MinTimeLabel, multiplier: 0.9, name: "Futura")
        MinTimeLabel.titleLabel?.font = rangeFont
        MaxTimeLabel.titleLabel?.font = rangeFont
        
   
        WinningTimeSetting.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: HomeViewController.darkMode ? UIColor.white : UIColor.black, NSAttributedString.Key.font: HomeViewController.fontToFitHeight(view: WinningTimeSetting, multiplier: 0.6, name: "Futura")], for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SingleTimeLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        MinTimeLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        MaxTimeLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        TargetSettingLabel.text = NSLocalizedString("Target Setting", comment: "")
        
        
        updateHeights()
    }
    
    func updateHeights()
    {
        DistLabels.forEach{(label) in
            let textHeight = label.text?.size(withAttributes: [NSAttributedString.Key.font: UIFont(name: "Futura", size: label.font.pointSize)!]).height
            
            
            label.heightAnchor.constraint(equalToConstant: textHeight!).isActive = true
        }
    }
    
    
    func updateDistributionLabels()
    {
        let min = HomeViewController.mySession.minTime
        let max = HomeViewController.mySession.maxTime
        Dist1.text = SolveTime.makeMyString(num: min)
        Dist7.text = SolveTime.makeMyString(num: max)
        let std: Float = Float(max - min) / 6.0
        Dist2.text = SolveTime.makeMyString(num: Int(round(Float(min) + std)))
        Dist3.text = SolveTime.makeMyString(num: Int(round(Float(min) + 2*std)))
        Dist4.text = SolveTime.makeMyString(num: Int(round(Float(min) + 3*std)))
        Dist5.text = SolveTime.makeMyString(num: Int(round(Float(min) + 4*std)))
        Dist6.text = SolveTime.makeMyString(num: Int(round(Float(min) + 5*std)))
        updateHeights()
    }
    
    func makeDarkMode()
    {

        BigView.backgroundColor = HomeViewController.darkModeColor()
        for button in [MinTimeLabel, MaxTimeLabel, SingleTimeLabel, DistributionLabel]
        {
            button?.backgroundColor = .darkGray
        }
        DistributionImage.image = UIImage(named: "DarkModeGaussianCurve")
        BlackWhiteLabels.forEach { (label) in
            label.textColor? = UIColor.white
        }
        WinningTimeSetting.tintColor = HomeViewController.orangeColor()
        WinningTimeSetting.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: HomeViewController.fontToFitHeight(view: WinningTimeSetting, multiplier: 0.6, name: "Futura")], for: .normal)
    }
    
    func turnOffDarkMode()
    {
        BigView.backgroundColor = .white
        for button in [MinTimeLabel, MaxTimeLabel, SingleTimeLabel, DistributionLabel]
        {
            button?.backgroundColor = HomeViewController.darkBlueColor()
        }
        BlackWhiteLabels.forEach { (label) in
            label.textColor? = UIColor.black
        }
        DistributionImage.image = UIImage(named: "GaussianCurve")
        WinningTimeSetting.tintColor = .white
        WinningTimeSetting.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: HomeViewController.fontToFitHeight(view: WinningTimeSetting, multiplier: 0.6, name: "Futura")], for: .normal)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        if HomeViewController.darkMode
        {
            return .lightContent
        }
        return .default
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
