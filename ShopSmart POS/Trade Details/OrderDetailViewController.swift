//
//  OrderDetailViewController.swift
//  POS
//
//  Created by Maaz on 11/10/2024.
//

import UIKit
import PDFKit

class OrderDetailViewController: UIViewController {
    
    @IBOutlet weak var MianView: UIView!
    
    @IBOutlet weak var EmpType: UILabel!
    @IBOutlet weak var AmountLabel: UILabel!
    @IBOutlet weak var salesType: UILabel!
    @IBOutlet weak var productNameLbl: UILabel!
    @IBOutlet weak var dateOfOrderLbl: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var orderNoLabel: UILabel!
    
    @IBOutlet weak var pdfView: UIView!
  
    
    var selectedOrderDetail: AllSales?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currency = UserDefaults.standard.value(forKey: "currencyISoCode") as? String ?? "$"
        
        applyCornerRadiusToBottomCorners(view: MianView, cornerRadius: 35)
        
        if let orderDetail = selectedOrderDetail {
            orderNoLabel.text = orderDetail.orderNo
            userNameLabel.text = orderDetail.userName
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let dateString = dateFormatter.string(from: orderDetail.DateOfOrder)
            dateOfOrderLbl.text = dateString
            
            productNameLbl.text = orderDetail.product
            salesType.text = orderDetail.SaleType
            AmountLabel.text =  "\(currency) \(orderDetail.amount)"
            EmpType.text = orderDetail.UsertType
          
    
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        currency = UserDefaults.standard.value(forKey: "currencyISoCode") as? String ?? "$"
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @IBAction func PdfGenerateButton(_ sender: Any) {
        let pdfData = createPDF(from: pdfView)
        savePdf(data: pdfData)
    }
    
    
    // Function to create PDF from the view
    func createPDF(from view: UIView) -> Data {
        let pdfPageFrame = view.bounds
        let pdfData = NSMutableData()
        
        // Create the PDF context
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageFrame, nil)
        
        UIGraphicsBeginPDFPageWithInfo(pdfPageFrame, nil)
        
        // Render the view into the PDF context
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return Data() }
        view.layer.render(in: pdfContext)
        
        // Close the PDF context
        UIGraphicsEndPDFContext()
        
        return pdfData as Data
    }
    
    // Function to save the PDF data to the device
    func savePdf(data: Data) {
        // Specify the file path and name
        let fileName = "OrderDetail.pdf"
        
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            
            // Write the PDF data to the file
            do {
                try data.write(to: fileURL)
                print("PDF saved at: \(fileURL)")
                
                // Present sharing options for the saved PDF
                let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                present(activityVC, animated: true, completion: nil)
                
            } catch {
                print("Could not save PDF file: \(error.localizedDescription)")
            }
        }
    }
}
