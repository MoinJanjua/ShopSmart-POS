//
//  UserAllDataViewController.swift
//  AssetAssign
//
//  Created by Moin Janjua on 20/08/2024.
//

import UIKit

class UserAllDataViewController: UIViewController {

    @IBOutlet weak var TittleName: UILabel!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var MianView: UIView!
    @IBOutlet weak var YourBounce: UILabel!
    @IBOutlet weak var TotalSalesAmount: UILabel!
    @IBOutlet weak var commessionView: UIView!
    
    var tittleName = String()
    var Users_Detail: [SalesPerson] = []
    var selectedCustomerDetail: SalesPerson?
    var selectedOrderDetail: AllSales?
    var order_Detail: [AllSales] = []
    var currency: String = "$"  // Assuming you have a currency field
    
    var percentageSet = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        addDropShadow(to: commessionView)
        applyCornerRadiusToBottomCorners(view: MianView, cornerRadius: 35)
        TittleName.text = tittleName

        TableView.delegate = self
        TableView.dataSource = self
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        currency = UserDefaults.standard.value(forKey: "currencyISoCode") as? String ?? "$"

        if let savedData = UserDefaults.standard.array(forKey: "OrderDetails") as? [Data] {
            let decoder = JSONDecoder()
            order_Detail = savedData.compactMap { data in
                do {
                    let order = try decoder.decode(AllSales.self, from: data)
                    return order
                } catch {
                    print("Error decoding order: \(error.localizedDescription)")
                    return nil
                }
            }

            // Now filter orders based on the current selected customer
            if let selectedCustomer = selectedCustomerDetail {
                let filteredOrders = order_Detail.filter { $0.userName == selectedCustomer.name }
                order_Detail = filteredOrders // Update the order_Detail array with filtered results

                // Calculate total sales amount for the selected customer
                let totalAmount = filteredOrders.reduce(0.0) { (total, order) -> Double in
                    return total + (Double(order.amount) ?? 0.0)
                }

                // Update the TotalSalesAmount label
                TotalSalesAmount.text = " Total Sales Amount: \(currency) \(String(format: "%.2f", totalAmount))"

                // Assuming `percentageSet` is a string of comma-separated percentages
                let percentages = percentageSet.split(separator: ",").compactMap { Double($0) }

                // Loop through percentages and calculate bounce for each percentage
                var bounceAmountTotal = 0.0

                for percentage in percentages {
                    let bounceAmount = totalAmount * (percentage / 100)
                    bounceAmountTotal += bounceAmount
                    print("Calculated Bounce for percentage \(percentage)%: \(currency) \(String(format: "%.2f", bounceAmount))")
                }

                // Set the bounce total
                YourBounce.text = "\(tittleName) Commission Percentage Amount is : \(currency) \(String(format: "%.2f", bounceAmountTotal))"
            }
        }

        TableView.reloadData()
    }


    func makeImageViewCircular(imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
    }

    func convertDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }

    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // Method to create PDF from table view data
     func createPDF() -> Data {
         let pdfMetaData = [
             kCGPDFContextCreator: "ShareWise Ease",
             kCGPDFContextTitle: "SalesMen Sales Report"
         ]
         let format = UIGraphicsPDFRendererFormat()
         format.documentInfo = pdfMetaData as [String: Any]
         
         let pageWidth = 8.5 * 72.0 // Letter size 8.5 x 11 inches in points
         let pageHeight = 11 * 72.0
         let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
         
         let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
         
         let data = renderer.pdfData { (context) in
             context.beginPage()
             
             var yPosition: CGFloat = 20
             
             // Add Title to PDF
             let titleFont = UIFont.boldSystemFont(ofSize: 18)
             let titleAttributes: [NSAttributedString.Key: Any] = [
                 .font: titleFont
             ]
             let titleString = "Sales Report for \(selectedCustomerDetail?.name ?? "Customer")"
             titleString.draw(at: CGPoint(x: 20, y: yPosition), withAttributes: titleAttributes)
             yPosition += 40
             
             // Add Table Headers
             let headerFont = UIFont.boldSystemFont(ofSize: 16)
             let headerAttributes: [NSAttributedString.Key: Any] = [.font: headerFont]
             "Product".draw(at: CGPoint(x: 20, y: yPosition), withAttributes: headerAttributes)
             "Amount".draw(at: CGPoint(x: 200, y: yPosition), withAttributes: headerAttributes)
             "Sale Type".draw(at: CGPoint(x: 300, y: yPosition), withAttributes: headerAttributes)
             yPosition += 20
             
             // Add each row from table view
             for order in order_Detail {
                 let rowFont = UIFont.systemFont(ofSize: 14)
                 let rowAttributes: [NSAttributedString.Key: Any] = [.font: rowFont]
                 
                 order.product.draw(at: CGPoint(x: 20, y: yPosition), withAttributes: rowAttributes)
                 "\(currency) \(order.amount)".draw(at: CGPoint(x: 200, y: yPosition), withAttributes: rowAttributes)
                 order.SaleType.draw(at: CGPoint(x: 300, y: yPosition), withAttributes: rowAttributes)
                 yPosition += 20
                 
                 // Add page break if necessary
                 if yPosition > pageHeight - 40 {
                     context.beginPage()
                     yPosition = 20
                 }
             }
             
             // Add total sales and bounce
             yPosition += 40
             let totalFont = UIFont.boldSystemFont(ofSize: 16)
             let totalAttributes: [NSAttributedString.Key: Any] = [.font: totalFont]
             let totalSalesText = "Total Sales Amount: \(currency) \(TotalSalesAmount.text ?? "0.00")"
             totalSalesText.draw(at: CGPoint(x: 20, y: yPosition), withAttributes: totalAttributes)
             yPosition += 20
             let bounceText = "Your Bounce is: \(currency) \(YourBounce.text ?? "0.00")"
             bounceText.draw(at: CGPoint(x: 20, y: yPosition), withAttributes: totalAttributes)
         }
         
         return data
     }
     
     // Method to share PDF
     func sharePDF(_ pdfData: Data) {
         let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("SalesReport.pdf")
         do {
             try pdfData.write(to: tempURL)
         } catch {
             print("Error writing PDF file: \(error)")
             return
         }
         
         let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
         activityVC.excludedActivityTypes = [.postToFacebook, .postToTwitter]
         present(activityVC, animated: true, completion: nil)
     }
    
    @IBAction func PdfGenerator(_ sender: Any) {
        let pdfData = createPDF()
               sharePDF(pdfData)
        
    }
    
    @IBAction func EmpDetailButton(_ sender: Any) {
        // Check if selectedCustomerDetail is not nil
            if let selectedEmpDetail = selectedCustomerDetail {
                // Get storyboard instance and instantiate EmployeeDetailViewController
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                if let newViewController = storyBoard.instantiateViewController(withIdentifier: "EmployeeDetailViewController") as? EmployeeDetailViewController {
                    // Pass the selected employee details to the EmployeeDetailViewController
                    newViewController.selectedEmpDetail = selectedEmpDetail
                    
                    // Set presentation style and transition
                    newViewController.modalPresentationStyle = .fullScreen
                    newViewController.modalTransitionStyle = .crossDissolve
                    
                    // Present the view controller
                    self.present(newViewController, animated: true, completion: nil)
                }
            } else {
                // Handle case where no employee is selected (optional)
                showAlert("Error", "No employee selected.")
            }
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}


extension UserAllDataViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order_Detail.count
    }
    
    // Configure the cell for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentCell", for: indexPath) as! TableViewCell
     
        let order = order_Detail[indexPath.row]
        
        // Set the product information to the cell labels
        cell.nameLabel.text = "Product: \(order.product)"
        cell.productLabel.text = "\(currency) \(order.amount)"
        cell.saleType.text? = order.SaleType

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: order.DateOfOrder)
        cell.dateLabe.text = dateString
        
   
        
        return cell
    }
    
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80  // Adjust as per your design
    }
    
}

