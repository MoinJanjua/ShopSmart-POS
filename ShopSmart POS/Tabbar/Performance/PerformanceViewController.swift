//
//  PerformanceViewController.swift
//  ShopSmart POS
//
//  Created by Maaz on 21/10/2024.
//

import UIKit
import Charts

class PerformanceViewController: UIViewController {

    @IBOutlet weak var ChartView: UIView!
    @IBOutlet weak var MainView: UIView!
    
    var order_Detail: [AllSales] = []
    var lineChartView: LineChartView!
    var noDataImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyCornerRadiusToBottomCorners(view: MainView, cornerRadius: 35)

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Retrieve stored order details from UserDefaults
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
        
        // Once data is loaded, update the chart with sales data
        updateChartWithData()
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
}
