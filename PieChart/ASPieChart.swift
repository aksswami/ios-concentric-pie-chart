//
//  ASPieChart.swift
//  PieChart
//
//  Created by Amit kumar Swami on 24/09/15.
//  Copyright © 2015 Aks. All rights reserved.
//

import UIKit

class ASPieChart: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var items: [ASPieChartDataItem]!
    
    var descriptionTextFont: UIFont = UIFont(name: "Avenir Medium", size: 18.0)!
    
    var descriptionTextColor: UIColor = UIColor.whiteColor()
    
    var descriptionTextShadowColor: UIColor = UIColor.blackColor()
    
    var descriptionShadowOffset: CGSize = CGSizeMake(0, 1)
    
    var duration: NSTimeInterval = 1.0
    
    var showOnlyValues: Bool = true
    
    var showAbsoluteValues: Bool = true
    
    var labelPercentageCutoff: CGFloat = 0.0
    
    var shouldHighlightSectorOnTouch: Bool = true
    
    var outerCircleRadius: CGFloat!
    
    var innerCircleRadius: CGFloat!
    
    var enableMultipleSelection: Bool = false
    
    private var selectedItems: [ASPieChartDataItem]!
    
    private var pieLayer: CAShapeLayer!
    
    private var endPercentages: [Double]!
    
    private var contentView: UIView!
    
    private var descriptionLabels: [NSObject]!
    
    private var sectorHighlight: CAShapeLayer!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(fromFrame frame: CGRect, items: [ASPieChartDataItem]) {
        super.init(frame: frame)
        self.items = items
        self.selectedItems = []
        self.endPercentages = []
        
        loadDefault()
    }
    
    func loadDefault() {
        var currentTotal: Double = 0
        let total: Double = (items as AnyObject).valueForKeyPath("@sum.value") as! Double
        for (index,item) in items.enumerate() {
            if total == 0 {
                endPercentages.append(1.0 / Double(items.count * (index + 1)))
            }
            else {
                currentTotal += Double(item.value)
                endPercentages.append(currentTotal / total)
            }
        }
        contentView?.removeFromSuperview()
        contentView = UIView.init(frame: self.bounds)
        
        self.addSubview(contentView)
        pieLayer = CAShapeLayer.init()
        contentView.layer.addSublayer(pieLayer)
        
    }

    func recompute() {
        outerCircleRadius = CGRectGetWidth(self.bounds) / 2
        innerCircleRadius = CGRectGetWidth(self.bounds) / 6
    }
    
    func strokeChart() {
        loadDefault()
        recompute()
        for (index, item) in items.enumerate() {
            
            let startPercentage = startPercentageForItemAtIndex(index)
            let endPercentage = endPercentageForItemAtIndex(index)
            
            let radius = innerCircleRadius + (outerCircleRadius - innerCircleRadius) / 2
            let borderWidth = outerCircleRadius - innerCircleRadius
            
            let currentPieLayer = newCircleLayerWithRadius(radius, borderWidth: borderWidth, fillColor: UIColor.clearColor(), borderColor: item.color, startPercentage: startPercentage, endPercentage: endPercentage)
            
            pieLayer.addSublayer(currentPieLayer)
        }
        maskChart()
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
    
    func newCircleLayerWithRadius(radius: CGFloat, borderWidth: CGFloat, fillColor: UIColor, borderColor: UIColor, startPercentage: CGFloat, endPercentage: CGFloat) -> CAShapeLayer {
        let circle = CAShapeLayer.init()
        
        let center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        
        let path = UIBezierPath.init(arcCenter: center, radius: radius, startAngle: -CGFloat(M_PI_2), endAngle: CGFloat(M_PI_2 * 3), clockwise: true)
        circle.fillColor = fillColor.CGColor
        circle.strokeColor = borderColor.CGColor
        circle.strokeStart = startPercentage
        circle.strokeEnd = endPercentage
        circle.lineWidth = borderWidth
        circle.path = path.CGPath
    
        return circle
    }
    
    func maskChart(){
        let radius: CGFloat = innerCircleRadius + (outerCircleRadius - innerCircleRadius) / 2
        let borderWidth: CGFloat = outerCircleRadius - innerCircleRadius
        let maskLayer: CAShapeLayer = newCircleLayerWithRadius(radius, borderWidth: borderWidth, fillColor: UIColor.clearColor(), borderColor: UIColor.blackColor(), startPercentage: 0, endPercentage: 1)
        
        pieLayer.mask = maskLayer;
        let animation: CABasicAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = NSInteger.init(0)
        animation.toValue = NSInteger.init(1)
        animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.removedOnCompletion = true
        maskLayer.addAnimation(animation, forKey: "circleAnimation")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        strokeChart()
    }
    
    
}


