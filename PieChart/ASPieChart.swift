//
//  ASPieChart.swift
//  PieChart
//
//  Created by Amit kumar Swami on 24/09/15.
//  Copyright © 2015 Aks. All rights reserved.
//

import UIKit

protocol ASPieChartDelegate {
    func clickedOnPie(circleIndex: Int, dataItemIndex: Int)
    func unselectedPieChartItem()
}

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
    
    var shouldHighlightSectorOnTouch: Bool = true
    
    var outerMostCircleRadius: CGFloat!
    
    var innerMostCircleRadius: CGFloat!
    
    var enableMultipleSelection: Bool = false
    
    private var pieLayer: CAShapeLayer!
    
    private var endPercentages: [Double]!
    
    private var contentView: UIView!
    
    private var circleCenter: CGPoint!
    
    var delegate: ASPieChartDelegate?
    
//    private var descriptionLabels: [NSObject]!
    
    private var sectorHighlight: CAShapeLayer!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    init(fromFrame frame: CGRect, circles: [ASPieChartCircle]) {
        super.init(frame: frame)
        self.circles = circles
        
        configureDefault()
    }
    
    func configureDefault() {
        circles.sortInPlace({$0.innerRadius < $1 .innerRadius})
        if circles.count > 0 {
            innerMostCircleRadius = circles[0].innerRadius
            outerMostCircleRadius = circles[circles.count - 1].outerRadius
        }
        
        circleCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
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
            for (index, dataItem) in circle.dataItems.enumerate() {
                let startPercentage = circle.startPercentageForItemAtIndex(index)
                let endPercentage = circle.endPercentageForItemAtIndex(index)
                
                let currentPieLayer = newCircleLayerWithRadius(circle.radius, borderWidth: circle.borderWidth, fillColor: UIColor.clearColor(), borderColor: dataItem.color, startPercentage: startPercentage, endPercentage: endPercentage)
                circle.pieLayer.addSublayer(currentPieLayer)
                circle.pieLayer.hidden = true
            }
        }
        //createLabelLines()
        maskChart()
        
    }
    
    func newCircleLayerWithRadius(radius: CGFloat, borderWidth: CGFloat, fillColor: UIColor, borderColor: UIColor, startPercentage: CGFloat, endPercentage: CGFloat) -> CAShapeLayer {
        let circle = CAShapeLayer.init()
        
        let path = UIBezierPath.init(arcCenter: circleCenter, radius: radius, startAngle: -CGFloat(M_PI_2), endAngle: CGFloat(M_PI_2 * 3), clockwise: true)
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
        if index + 1 == circles.count {
            createLabelLines();
        }
    }
    
    func createLabelLines() {
        let labelCircleMargin: CGFloat = 70
        let labelCenterDistance: CGFloat = 150
        for circle in circles as [ASPieChartCircle] {
            for (index, angle) in (circle.arcCenterPointAngle?.enumerate())! {
                let startPoint = CGPointMake(circleCenter.x + circle.radius * sin(angle), circleCenter.y + circle.radius * cos(angle))
                let endPoint = CGPointMake(circleCenter.x + (circle.radius + labelCircleMargin) * sin(angle) , circleCenter.y + (circle.radius + labelCircleMargin) * cos(angle))
                let labelStartPointRight = CGPointMake(circleCenter.x + labelCenterDistance , endPoint.y)
                let labelStartPointLeft = CGPointMake(circleCenter.x - labelCenterDistance , endPoint.y)
                
                let line: CAShapeLayer = CAShapeLayer.init()
                
                let path = UIBezierPath()
                path.moveToPoint(startPoint)
                path.addLineToPoint(endPoint)
                path.addLineToPoint(Double(angle) < M_PI ? labelStartPointRight : labelStartPointLeft)
                let dashes: [CGFloat] = [ path.lineWidth * 0, path.lineWidth * 2 ]
                path.setLineDash(dashes, count: dashes.count, phase: 0)
                path.lineCapStyle = .Round
                
                line.fillColor = UIColor.clearColor().CGColor
                line.strokeColor = circle.dataItems[index].color.CGColor
                line.lineWidth = 2
                line.lineDashPattern = [2,2]
                line.path = path.CGPath
                
                contentView.layer.addSublayer(line)

            }
        }
    }
    
    func didTouch(atLocation touchLocation: CGPoint) {
        let distanceFromCenter = sqrtf(powf(Float(touchLocation.x - circleCenter.x), 2) + powf(Float(touchLocation.y - circleCenter.y), 2))
        

        var touchedCircleIndex = -1
        for (index, circle) in circles.enumerate() {
            if distanceFromCenter > Float(circle.innerRadius) && distanceFromCenter < Float(circle.outerRadius) {
                touchedCircleIndex = index
            }
        }
        
        // TODO: create delegate method
        if touchedCircleIndex == -1 {
            delegate?.unselectedPieChartItem()
            return
        }
        
        let percentage = findPercentageOfAngleInCircle(forCenter: circleCenter, fromPoint: touchLocation)
        var touchedItemindex = 0
        while percentage > circles[touchedCircleIndex].endPercentageForItemAtIndex(touchedItemindex) {
            touchedItemindex++
        }
        
        delegate?.clickedOnPie(touchedCircleIndex, dataItemIndex: touchedItemindex)
        
        if shouldHighlightSectorOnTouch {
            if !enableMultipleSelection {
                if sectorHighlight != nil {
                    sectorHighlight.removeFromSuperlayer()
                }
            }
            
            let currentCircle: ASPieChartCircle = circles[touchedCircleIndex]
            
            let currentItem: ASPieChartDataItem = currentCircle.dataItems[touchedItemindex]
            
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            let oldColor: UIColor = currentItem.color
            oldColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            alpha /= 2
            let newColor = UIColor.init(red: red, green: green, blue: blue, alpha: alpha)
            
            let startPercentage = currentCircle.startPercentageForItemAtIndex(touchedItemindex)
            let endPercentage = currentCircle.endPercentageForItemAtIndex(touchedItemindex)
            
            self.sectorHighlight = newCircleLayerWithRadius(currentCircle.outerRadius + 5, borderWidth: 10, fillColor: UIColor.clearColor(), borderColor: newColor, startPercentage: startPercentage, endPercentage: endPercentage)
            
            if self.enableMultipleSelection {
                
            }
            else {
                contentView.layer.addSublayer(self.sectorHighlight)
            }
            
        
        }
        
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches as Set<UITouch> {
            let touchLocation: CGPoint = touch.locationInView(contentView)
            didTouch(atLocation: touchLocation)
        }
    }
    
    func findPercentageOfAngleInCircle(forCenter center: CGPoint, fromPoint: CGPoint) -> CGFloat {
        let angleOfLine = atanf(Float(fromPoint.y - center.y) / Float(fromPoint.x - center.x))
        let percentage: CGFloat = CGFloat((angleOfLine + Float(M_PI/2)) / Float(2 * M_PI))
        
        return (fromPoint.x - center.x) > 0 ? percentage : percentage + 0.5
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        strokeChart()
    }
    
    
}


