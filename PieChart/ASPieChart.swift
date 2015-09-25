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
    
    var circles: [ASPieChartCircle]!
    
    var items: [ASPieChartDataItem]!
    
    var descriptionTextFont: UIFont = UIFont(name: "Avenir Medium", size: 18.0)!
    
    var descriptionTextColor: UIColor = UIColor.whiteColor()
    
    var descriptionTextShadowColor: UIColor = UIColor.blackColor()
    
    var descriptionShadowOffset: CGSize = CGSizeMake(0, 1)
    
    var duration: NSTimeInterval = 2.0
    
//    var showOnlyValues: Bool = true
    
//    var showAbsoluteValues: Bool = true
    
//    var labelPercentageCutoff: CGFloat = 0.0
    
//    var shouldHighlightSectorOnTouch: Bool = true
    
    var outerCircleRadius: CGFloat!
    
    var innerCircleRadius: CGFloat!
    
    var enableMultipleSelection: Bool = false
    
//    private var selectedItems: [ASPieChartDataItem]!
    
    private var pieLayer: CAShapeLayer!
    
    private var endPercentages: [Double]!
    
    private var contentView: UIView!
    
//    private var descriptionLabels: [NSObject]!
    
//    private var sectorHighlight: CAShapeLayer!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    init(fromFrame frame: CGRect, circles: [ASPieChartCircle]) {
        super.init(frame: frame)
        self.circles = circles
        
        configureDefault()
    }
    
    func configureDefault() {
        contentView?.removeFromSuperview()
        contentView = UIView.init(frame: self.bounds)
        self.addSubview(contentView)
        
        for circle in circles as [ASPieChartCircle] {
            contentView.layer.addSublayer(circle.pieLayer)
        }
    }
    
    func strokeChart() {
        configureDefault()
        
        for circle in circles as [ASPieChartCircle] {
            for (index, dataItem) in circle.dateItems.enumerate() {
                let startPercentage = circle.startPercentageForItemAtIndex(index)
                let endPercentage = circle.endPercentageForItemAtIndex(index)
                
                let currentPieLayer = newCircleLayerWithRadius(circle.radius, borderWidth: circle.borderWidth, fillColor: UIColor.clearColor(), borderColor: dataItem.color, startPercentage: startPercentage, endPercentage: endPercentage)
                circle.pieLayer.addSublayer(currentPieLayer)
            }
        }
        maskChart()
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
    
    func maskChart() {
        for (index, circle) in circles.enumerate() {
            let maskLayer: CAShapeLayer = newCircleLayerWithRadius(circle.radius, borderWidth: circle.borderWidth, fillColor: UIColor.clearColor(), borderColor: UIColor.blackColor(), startPercentage: 0, endPercentage: 1)
            circle.pieLayer.mask = maskLayer
            let animation: CABasicAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
            animation.setValue(index, forKey: "id")
            animation.duration = duration
            animation.fromValue = NSInteger.init(0)
            animation.toValue = NSInteger.init(1)
            animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.removedOnCompletion = true
            animation.delegate = self
            animation.beginTime = CACurrentMediaTime() + duration * Double(index)
            circle.maskLayerAnimation = animation
        }
        kickOffAnimation()
    }
    
    func kickOffAnimation(){
        if circles.count > 1 {
            circles[0].pieLayer?.hidden = false
            if let animation = circles[0].maskLayerAnimation {
                circles[0].pieLayer.mask?.addAnimation(animation, forKey: "circleAnimation\(0)")
            }
        }
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        let index: Int = (anim.valueForKey("id")?.integerValue)!
        if index >= 0 && (index + 1) < circles.count && flag {
            circles[index + 1].pieLayer?.hidden = false
            if let animation = circles[index + 1].maskLayerAnimation {
                 circles[index + 1].pieLayer.mask?.addAnimation(animation, forKey: "circleAnimation\(index)")
            }
           
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        strokeChart()
    }
    
    
}


