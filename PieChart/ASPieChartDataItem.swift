//
//  ASPieChartDataItem.swift
//  PieChart
//
//  Created by Amit kumar Swami on 24/09/15.
//  Copyright © 2015 Aks. All rights reserved.
//

import UIKit

class ASPieChartDataItem: NSObject {
    
    var value: CGFloat
    var color:UIColor!
    var textDescription:String!
    
    init(fromValue value: CGFloat, color: UIColor, textDescription: String) {
        self.value = value
        self.color = color
        self.textDescription = textDescription
        super.init()
    }
    
    convenience init(value: CGFloat, color: UIColor) {
        self.init(fromValue: value, color: color, textDescription: "")
    }

}
