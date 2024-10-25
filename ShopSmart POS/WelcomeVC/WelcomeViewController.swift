//
//  WelcomeViewController.swift
//  DailyExpense
//
//  Created by UCF on 19/08/2024.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var CurveView: UIView!
    
    @IBOutlet weak var startBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        curveTopCornersDown(of: CurveView, radius: 55)
        addDropShadowButtonOne(to: startBtn)
    }

   
    
    @IBAction func LetStartButton(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
          
          // Instantiate your UITabBarController (make sure the identifier is correct in your storyboard)
          let tabBarVC = storyBoard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
          
          // Set the selected tab to the third one (index starts at 0, so 2 means the third tab)
          tabBarVC.selectedIndex = 2
          
          // Present the UITabBarController
          tabBarVC.modalPresentationStyle = .fullScreen
          tabBarVC.modalTransitionStyle = .crossDissolve
          self.present(tabBarVC, animated: true, completion: nil)
    }
    
}




