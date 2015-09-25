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
    var dateItems: [ASPieChartDataItem]!
    
    init(withInnerRadius innerRadius: CGFloat, thickness: CGFloat, dataItems: [ASPieChartDataItem]){
        self.innerRadius = innerRadius
        self.thickness = thickness
        self.dateItems = dataItems
        super.init()
    }
    
    convenience init(withInnerRadius innerRadius: CGFloat, dataItems: [ASPieChartDataItem]) {
        self.init(withInnerRadius: innerRadius, thickness: 10, dataItems: dataItems)
    }
}
