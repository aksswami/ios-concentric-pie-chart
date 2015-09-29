//
//  ASPieChartCircle.swift
//  PieChart
//
//  Created by Amit kumar Swami on 25/09/15.
//  Copyright © 2015 Aks. All rights reserved.
//

import UIKit

class ASPieChartCircle: NSObject {

    var innerRadius: CGFloat = 0.0
    var thickness: CGFloat = 1.0
    var dataItems: [ASPieChartDataItem]!
    var outerRadius: CGFloat = 0.0
    var borderWidth: CGFloat = 0.0
    var radius: CGFloat = 0.0
    private var endPercentages: [Double]!
    var pieLayer: CAShapeLayer!
    var maskLayerAnimation: CABasicAnimation!
    var arcCenterPointAngle: [CGFloat]!
    private var selectedItems: [ASPieChartDataItem]!
    
    init(withInnerRadius innerRadius: CGFloat, thickness: CGFloat, dataItems: [ASPieChartDataItem]){
        super.init()
        self.innerRadius = innerRadius
        self.thickness = thickness
        self.dataItems = dataItems
        
        self.outerRadius = innerRadius + thickness
        self.radius = innerRadius + (self.outerRadius - innerRadius) / 2
        self.borderWidth = thickness
        self.pieLayer = CAShapeLayer.init()
        self.pieLayer.hidden = true
        
        initializeValues()
    }
    
    convenience init(withInnerRadius innerRadius: CGFloat, dataItems: [ASPieChartDataItem]) {
        self.init(withInnerRadius: innerRadius, thickness: 10, dataItems: dataItems)
    }
    
    func initializeValues() {
        selectedItems = []
        endPercentages = []
        arcCenterPointAngle = []
        var currentTotal: Double = 0
        let total: Double = (dataItems as AnyObject).valueForKeyPath("@sum.value") as! Double
        for (index, dataItem) in dataItems.enumerate() {
            if total == 0 {
                endPercentages.append(1.0 / Double(dataItems.count * (index + 1)))
            }
            else {
                currentTotal += Double(dataItem.value)
                endPercentages.append(currentTotal / total)
            }
            
            var centerPercentage: Double = Double((startPercentageForItemAtIndex(index) + (endPercentageForItemAtIndex(index) - startPercentageForItemAtIndex(index)) / 2) * CGFloat(M_PI * 2))
            if centerPercentage < M_PI {
                centerPercentage = M_PI - centerPercentage
            }
            else {
                centerPercentage = 3 * M_PI - centerPercentage
            }
            
            arcCenterPointAngle.append(CGFloat(centerPercentage))
        }
    }
    
    
    func startPercentageForItemAtIndex(index: Int) -> CGFloat {
        if index == 0 {
            return 0
        }
        return CGFloat(endPercentages[index - 1])
    }
    
    func endPercentageForItemAtIndex(index: Int) -> CGFloat {
        return CGFloat(endPercentages[index])
    }
    
    func ratioForItemAtIndex(index: Int) -> CGFloat {
        return endPercentageForItemAtIndex(index) - startPercentageForItemAtIndex(index)
    }
    
    func dataItemForIndex(index: Int) -> ASPieChartDataItem? {
        if index < dataItems.count {
            return dataItems[index]
        }
        return nil
    }

}
