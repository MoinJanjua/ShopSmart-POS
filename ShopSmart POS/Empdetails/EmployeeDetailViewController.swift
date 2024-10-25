//
//  EmployeeDetailViewController.swift
//  ShopSmart POS
//
//  Created by Maaz on 22/10/2024.
//
import UIKit

class EmployeeDetailViewController: UIViewController {

    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userAddress: UILabel!
    @IBOutlet weak var userContact: UILabel!
    @IBOutlet weak var userSetPercentage: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var MianView: UIView!
    @IBOutlet weak var userView: UIView!
    
    // Ensure selectedEmpDetail is of type SalesPerson
    var selectedEmpDetail: SalesPerson?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyCornerRadiusToBottomCorners(view: MianView, cornerRadius: 35)
        addDropShadow(to: userView)
        
        // Check if selectedEmpDetail is not nil and populate UI
        if let empDetail = selectedEmpDetail {
            userPicture.image = empDetail.pic
            userName.text = empDetail.name
            userAddress.text = empDetail.Address
            userContact.text = empDetail.contact
            genderLbl.text = empDetail.gender
            userSetPercentage.text = empDetail.percentage
        }
        makeImageViewCircular(imageView: userPicture)
    }
    
    func makeImageViewCircular(imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
