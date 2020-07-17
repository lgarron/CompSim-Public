//
//  SimpleAlertViewController.swift
//  CompSim
//
//  Created by Rami Sbahi on 12/30/19.
//  Copyright © 2019 Rami Sbahi. All rights reserved.
//

import UIKit

class SimpleAlertViewController: UIViewController {
    
    @IBOutlet weak var SimpleTitle: UILabel!
    @IBOutlet weak var SimpleView: UIView!
    @IBOutlet weak var YesButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    
    var enterAction: (() -> Void)?
    var myTitle = String()
    var yesText = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        SimpleTitle.text = myTitle
        YesButton.setTitle(yesText, for: .normal)
        if #available(iOS 11.0, *) {
            SimpleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        
        if(HomeViewController.darkMode)
        {
            SimpleView.backgroundColor = HomeViewController.darkPurpleColor()
        }

        YesButton.titleLabel?.adjustsFontSizeToFitWidth = true
        CancelButton.titleLabel?.adjustsFontSizeToFitWidth = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func yesPressed(_ sender: Any) {
        dismiss(animated: true)
        enterAction?()
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
