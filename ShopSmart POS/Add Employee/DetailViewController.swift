//
//  DetailViewController.swift
//  AssetAssign
//
//  Created by Moin Janjua on 19/08/2024.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var NameTF: UITextField!
    @IBOutlet weak var DesignationTF: UITextField!
    @IBOutlet weak var GenderTF: DropDown!
    @IBOutlet weak var ContactTF: UITextField!
    @IBOutlet weak var PercentageTF: UITextField!
    @IBOutlet weak var Save_btn: UIButton!
    
    private var datePicker: UIDatePicker?
    var pickedImage = UIImage()
    
    @IBOutlet weak var MianView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyCornerRadiusToBottomCorners(view: MianView, cornerRadius: 35)
        makeImageViewCircular(imageView: Image)
        
        // Set PercentageTF delegate to self for validation
        PercentageTF.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        Image.isUserInteractionEnabled = true
        Image.addGestureRecognizer(tapGesture)
        
        GenderTF.optionArray = ["Male", "Female"]
        GenderTF.didSelect { (selectedText, index, id) in
            self.GenderTF.text = selectedText
        }
        GenderTF.delegate = self
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture2.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture2)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    // UITextFieldDelegate method to validate percentage input
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == PercentageTF {
            // Get the new text by replacing the current text in the range with the replacement string
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            // Check if the input is a valid number and within the allowed range
            if let percentageValue = Int(newText), percentageValue > 100 {
                showAlert(title: "Error", message: "Please add percentage below 100%")
                return false
            }
        }
        return true
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidContact(_ contact: String) -> Bool {
        let contactRegEx = "^\\d{11}$"
        let contactPred = NSPredicate(format: "SELF MATCHES %@", contactRegEx)
        return contactPred.evaluate(with: contact)
    }
    
    func makeImageViewCircular(imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func clearTextFields() {
        NameTF.text = ""
        DesignationTF.text = ""
        GenderTF.text = ""
        ContactTF.text = ""
        PercentageTF.text = ""
        Image.image = nil
    }
    
    @objc func imageViewTapped() {
        openGallery()
    }
    
    func openGallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            picker.dismiss(animated: true) {
                self.pickedImage = pickedImage
                self.Image.image = pickedImage
            }
        }
    }
    
    func saveData(_ sender: Any) {
        // Check if any of the text fields are empty
        guard let pics = Image.image,
              let imageData = pics.jpegData(compressionQuality: 1.0),
              let eName = NameTF.text, !eName.isEmpty,
              let percentageText = PercentageTF.text, !percentageText.isEmpty,
              let designation = DesignationTF.text,
              let gender = GenderTF.text, !gender.isEmpty,
              let contact = ContactTF.text, !contact.isEmpty
        else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }
        
        // Check if the entered percentage is a valid number
        if let percentageValue = Double(percentageText), percentageValue <= 100 {
            // Proceed with saving the data if percentage is valid (<= 100)
            let randomCharacter = generateRandomCharacter()
            let newDetail = SalesPerson(
                id: "\(randomCharacter)",
                picData: imageData,
                name: eName,
                Address: designation,
                gender: gender,
                contact: contact,
                percentage: percentageText
            )
            saveUserDetail(newDetail)
        } else {
            // Show error if the percentage is greater than 100
            showAlert(title: "Error", message: "Please add a percentage below 100%.")
        }
    }

    
    func saveUserDetail(_ employee: SalesPerson) {
        var employees = UserDefaults.standard.object(forKey: "UserDetails") as? [Data] ?? []
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(employee)
            employees.append(data)
            UserDefaults.standard.set(employees, forKey: "UserDetails")
            clearTextFields()
        } catch {
            print("Error encoding medication: \(error.localizedDescription)")
        }
        showAlert(title: "Done", message: "Sales Men Detail has been Saved successfully.")
    }
    
    @IBAction func SaveButton(_ sender: Any) {
        saveData(sender)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
