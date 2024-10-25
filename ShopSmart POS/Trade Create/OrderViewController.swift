//
//  OrderViewController.swift
//  POS
//
//  Created by Maaz on 09/10/2024.
//

import UIKit

class OrderViewController: UIViewController, UITextFieldDelegate {
    

    
    @IBOutlet weak var MianView: UIView!
    
    @IBOutlet weak var UserTF: DropDown!
    @IBOutlet weak var ProductTF: UITextField!
    @IBOutlet weak var UserTypeTF: DropDown!
    @IBOutlet weak var DateofOrder: UITextField!
    @IBOutlet weak var SaleTypeTF: DropDown!
    @IBOutlet weak var AmountTF: UITextField!
    

    var pickedImage = UIImage()
    
    var SaleMens_Detail: [SalesPerson] = []
    var products_Detail: [Products] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        applyCornerRadiusToBottomCorners(view: MianView, cornerRadius: 35)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture2.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture2)
        
        setupDatePicker(for: DateofOrder, target: self, doneAction: #selector(donePressed))
   
        
        // UserTypeTF Dropdown
        UserTypeTF.optionArray = ["Owner", "Employee"]
        UserTypeTF.didSelect { (selectedText, index, id) in
               self.UserTypeTF.text = selectedText
           }
        UserTypeTF.delegate = self
        
        // SaleTypeTF Dropdown
        SaleTypeTF.optionArray = ["Sales", "Repairs"]
        SaleTypeTF.didSelect { (selectedText, index, id) in
               self.SaleTypeTF.text = selectedText
           }
       SaleTypeTF.delegate = self
        
        
        
        // Handle UserTF delegate if needed
        UserTF.delegate = self
        
        
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load data from UserDefaults for Users_Detail
        if let savedData = UserDefaults.standard.array(forKey: "UserDetails") as? [Data] {
            let decoder = JSONDecoder()
            SaleMens_Detail = savedData.compactMap { data in
                do {
                    let user = try decoder.decode(SalesPerson.self, from: data)
                    return user
                } catch {
                    print("Error decoding user: \(error.localizedDescription)")
                    return nil
                }
            }
        }
        
        // Set up the dropdown options for UserTF
        setUpUserDropdown()

    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    @objc func donePressed() {
        // Get the date from the picker and set it to the text field
        if let datePicker = DateofOrder.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy" // Same format as in convertStringToDate
            DateofOrder.text = dateFormatter.string(from: datePicker.date)
        }
        // Dismiss the keyboard
        DateofOrder.resignFirstResponder()
    }

    func makeImageViewCircular(imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
    }

    func clearTextFields() {
        UserTF.text = ""
        ProductTF.text = ""
        UserTypeTF.text = ""
        DateofOrder.text = ""
        AmountTF.text = ""
        SaleTypeTF.text = ""
        
    }
    
    // Set up User dropdown options from Users_Detail array
    func setUpUserDropdown() {
        // Check if Users_Detail array is empty
        if SaleMens_Detail.isEmpty {
            // If no users are available, set the text field to "No user available"
            UserTF.text = "No user available please first add the user"
            UserTF.isUserInteractionEnabled = false // Disable interaction if no users are available
        } else {
            // Extract names from the Users_Detail array
            let userNames = SaleMens_Detail.map { $0.name }
            
            // Assign names to the dropdown
            UserTF.optionArray = userNames
            
            // Enable interaction if users are available
            UserTF.isUserInteractionEnabled = true
            
            // Handle selection from dropdown
            UserTF.didSelect { (selectedText, index, id) in
                self.UserTF.text = selectedText
                print("Selected user: \(self.SaleMens_Detail[index])") // Optional: Handle selected user
            }
        }
    }
    // Set up User dropdown options from Users_Detail array
//    func setUpProductsDropdown() {
//        // Check if Users_Detail array is empty
//        if products_Detail.isEmpty {
//            // If no users are available, set the text field to "No user available"
//            ProductTF.text = "No product available please first add the product"
//            ProductTF.isUserInteractionEnabled = false // Disable interaction if no users are available
//        } else {
//            // Extract names from the Users_Detail array
//            let userNames = products_Detail.map { $0.name }
//            
//            // Assign names to the dropdown
//            ProductTF.optionArray = userNames
//            
//            // Enable interaction if users are available
//            ProductTF.isUserInteractionEnabled = true
//            
//            // Handle selection from dropdown
//            ProductTF.didSelect { (selectedText, index, id) in
//                self.ProductTF.text = selectedText
//                print("Selected user: \(self.products_Detail[index])") // Optional: Handle selected user
//            }
//        }
//    }

    func saveOrderData(_ sender: Any) {
        // Check if all mandatory fields are filled
        guard let userType = UserTypeTF.text, !userType.isEmpty,
              
              let users = UserTF.text, !users.isEmpty,
              let product = ProductTF.text, !product.isEmpty,
              let DateOr = DateofOrder.text, !DateOr.isEmpty,
              let saleType = SaleTypeTF.text, !saleType.isEmpty,
              let amountOfsale = AmountTF.text, !amountOfsale.isEmpty
                
        else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }

        // Generate random character for order number
        let randomCharacter = generateOrderNumber()
        let CustomerId = generateCustomerId()

        // Create new order detail safely
        let newCreateSale = AllSales(
            orderNo: "\(randomCharacter)", customerId: "\(CustomerId)",
            UsertType: userType,
            
            userName: users,
            product: product,
            DateOfOrder: convertStringToDate(DateOr) ?? Date(),
            SaleType: saleType, amount: amountOfsale
          
        )
        
        // Save the order detail
        saveCreateSaleDetail(newCreateSale)
    }


    func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy" // Corrected year format
        return dateFormatter.date(from: dateString)
    }
    
    func saveCreateSaleDetail(_ order: AllSales) {
        var orders = UserDefaults.standard.object(forKey: "OrderDetails") as? [Data] ?? []
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(order)
            orders.append(data)
            UserDefaults.standard.set(orders, forKey: "OrderDetails")
            clearTextFields()
           
        } catch {
            print("Error encoding medication: \(error.localizedDescription)")
        }
        showAlert(title: "Done", message: "Sales Data has been Saved successfully.")
    }
    
    @IBAction func SaveButton(_ sender: Any) {
        saveOrderData(sender)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }

}
