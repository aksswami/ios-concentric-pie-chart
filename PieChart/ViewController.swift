//
//  ViewController.swift
//  PieChart
//
//  Created by Amit kumar Swami on 23/09/15.
//  Copyright © 2015 Aks. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let circleChart = PNCircleChart(frame: CGRectMake(0.0, 100.0, 200.0, 200.0), total: 100, current: 30, clockwise: true)
        circleChart.backgroundColor = UIColor.clearColor()
        circleChart.strokeColor = UIColor.greenColor()
        circleChart.strokeChart()

        view.addSubview(circleChart)
        
        
        let items = [PNPieChartDataItem(value: 10, color: UIColor.redColor()), PNPieChartDataItem(value: 30, color: UIColor.blueColor()), PNPieChartDataItem(value: 50, color: UIColor.greenColor())]
        
        let pieChart = PNPieChart(frame: CGRectMake(200, 100, 200, 200), items: items)
        view.addSubview(pieChart)
        
        let newItems = [ASPieChartDataItem(value: 10, color: UIColor.brownColor()), ASPieChartDataItem(value: 40, color: UIColor.blackColor()), ASPieChartDataItem(value: 5, color: UIColor.yellowColor())]
        let newPieChart = ASPieChart(fromFrame: CGRectMake(0, 300, 200, 200), items: newItems)
        newPieChart.strokeChart()
        
        view.addSubview(newPieChart)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

