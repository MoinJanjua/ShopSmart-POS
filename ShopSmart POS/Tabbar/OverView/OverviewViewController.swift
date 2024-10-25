//
//  OverviewViewController.swift
//  ShareWise Ease
//
//  Created by Maaz on 16/10/2024.
//

import UIKit
import Charts

class OverviewViewController: UIViewController {

    @IBOutlet weak var MianView: UIView!
    @IBOutlet weak var detailMianView2: UIView!
    @IBOutlet weak var detailMianView1: UIView!

    @IBOutlet weak var SaleRepairSegment: UISegmentedControl!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var ChartView: UIView!

    
    @IBOutlet weak var todaySalesAmount: UILabel!
    @IBOutlet weak var totalSalesAmount: UILabel!
    
    var order_Detail: [AllSales] = [] // This contains all the orders
    var filteredOrders: [AllSales] = [] // This will contain the filtered orders
    var lineChartView: LineChartView!
    var noDataImageView: UIImageView!
    var currency = String()
    var noDataLabel: UILabel! // Add a label to show "No data available"


    override func viewDidLoad() {
        super.viewDidLoad()

        applyCornerRadiusToBottomCorners(view: MianView, cornerRadius: 35)
        addDropShadow(to: detailMianView2)
        addDropShadow(to: detailMianView1)        
        TableView.dataSource = self
        TableView.delegate = self
        
        // Set default segment to 0 (All orders)
        SaleRepairSegment.selectedSegmentIndex = 0
        
        // Initialize the chart view and add it to the ChartView
        lineChartView = LineChartView(frame: ChartView.bounds)
        lineChartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        ChartView.addSubview(lineChartView)
        // Initialize the no data image view
        noDataImageView = UIImageView(frame: ChartView.bounds)
        noDataImageView.contentMode = .scaleAspectFit
        noDataImageView.image = UIImage(named: "NoData") // Replace with your image name
        noDataImageView.isHidden = true
        ChartView.addSubview(noDataImageView)
        
        // Optionally configure the chart view (e.g., styling)
        configureChartView()
        
        // Initialize no data label
             noDataLabel = UILabel(frame: TableView.bounds)
             noDataLabel.text = "There is no data available"
             noDataLabel.textColor = .gray
             noDataLabel.textAlignment = .center
             noDataLabel.font = UIFont.systemFont(ofSize: 18)
             noDataLabel.isHidden = true
             TableView.backgroundView = noDataLabel // Set the label as table view's background
             
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currency = UserDefaults.standard.value(forKey: "currencyISoCode") as? String ?? "$"

        // Load data from UserDefaults
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
        }
        TableView.reloadData()
        updateChartWithData()

        // Calculate sales amounts
        calculateSalesAmounts()
        
        // Apply initial filter (all orders by default)
        filterOrdersBySegment()
    }
    func configureChartView() {
        // Customizations for the chart view if needed
        lineChartView.rightAxis.enabled = false
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }

    func updateChartWithData() {
        // Check if the order_Detail array has data
        if order_Detail.isEmpty {
            // Show the no data image and hide the chart view
            noDataImageView.isHidden = false
            lineChartView.isHidden = true
        } else {
            // Hide the no data image and show the chart view
            noDataImageView.isHidden = true
            lineChartView.isHidden = false

            // Sort the order_Detail array by the DateOfOrder property in ascending order
            order_Detail.sort { (order1: AllSales, order2: AllSales) -> Bool in
                return order1.DateOfOrder < order2.DateOfOrder
            }

            // Prepare the data entries for the line chart
            var dataEntries: [ChartDataEntry] = []

            for (index, order) in order_Detail.enumerated() {
                if let amount = Double(order.amount) {
                    // Each entry needs a double value for x (index) and y (amount) axis
                    let dataEntry = ChartDataEntry(x: Double(index), y: amount)
                    dataEntries.append(dataEntry)
                }
            }

            // Create a data set with the entries
            let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: "Sales Amount")
            lineChartDataSet.colors = [NSUIColor.blue]
            lineChartDataSet.circleColors = [NSUIColor.red]
            lineChartDataSet.circleRadius = 3.0

            // Create a data object with the dataset
            let lineChartData = LineChartData(dataSet: lineChartDataSet)

            // Set the data to the chart view
            lineChartView.data = lineChartData
        }
    }
    @IBAction func SRsegment(_ sender: UISegmentedControl) {
        // Filter the orders when the segment changes
        filterOrdersBySegment()
    }
    
    func filterOrdersBySegment() {
           let selectedSegment = SaleRepairSegment.selectedSegmentIndex

           // Change the appearance of the selected and unselected segments
           let whiteTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
           let blackTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
           
           // Set all segments to have white title text
           SaleRepairSegment.setTitleTextAttributes(whiteTextAttributes, for: .normal)
           
           // Set the selected segment to have black title text
           SaleRepairSegment.setTitleTextAttributes(blackTextAttributes, for: .selected)

           // Handle filtering based on the selected segment
           switch selectedSegment {
           case 0:
               // Show all orders
               filteredOrders = order_Detail
           case 1:
               // Filter for sales
               filteredOrders = order_Detail.filter { $0.SaleType == "Sales" }
           case 2:
               // Filter for repairs
               filteredOrders = order_Detail.filter { $0.SaleType == "Repairs" }
           default:
               // Default to show all orders
               filteredOrders = order_Detail
           }

           // Check if there is no data available after filtering
           noDataLabel.isHidden = !filteredOrders.isEmpty
           TableView.reloadData()
       }

    
    // Function to calculate the total and today's sales amounts
    func calculateSalesAmounts() {
        let today = Date()
        let calendar = Calendar.current
        
        // Format today's date to compare with order dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let todayString = dateFormatter.string(from: today)
        
        var totalSales: Double = 0.0
        var todaySales: Double = 0.0
        
        // Loop through all orders to calculate the total sales and today's sales
        for order in order_Detail {
            // Convert amount to Double (assuming it's a valid number)
            if let amount = Double(order.amount) {
                // Add to total sales
                totalSales += amount
                
                // Check if the order date is today
                let orderDateString = dateFormatter.string(from: order.DateOfOrder)
                if orderDateString == todayString {
                    todaySales += amount
                }
            }
        }
        
        // Update labels with the calculated values
        totalSalesAmount.text = String(format: "\(currency)%.2f", totalSales)   // "\(currency) \(totalSales)"
        todaySalesAmount.text = String(format: "\(currency)%.2f", todaySales)   //  "\(currency) \(todaySales)"
    }
    
    @IBAction func ViewAllSalesbutton(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ViewSalesViewController") as! ViewSalesViewController
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    @IBAction func CurrenctButton(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "CurrencyViewController") as! CurrencyViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    
    
}

extension OverviewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredOrders.isEmpty ? 0 : filteredOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "overviewCell", for: indexPath) as! OverviewTableViewCell
        
        let OrderData = filteredOrders[indexPath.row] // Use filtered orders
        cell.productNameLbl?.text = OrderData.product
        cell.salesTypeLabel?.text = OrderData.SaleType
        cell.saleMenNameLabel?.text = OrderData.userName
        cell.amountOFProductLabel?.text = "\(currency) \(OrderData.amount)"

        
        // Convert the Date object to a String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy" // Match this format to saved data
        let dateString = dateFormatter.string(from: OrderData.DateOfOrder)
        
        // Assign the formatted date string to the label
        cell.dateLbl.text = dateString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}
