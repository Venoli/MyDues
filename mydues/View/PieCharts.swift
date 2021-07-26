//
//  PieCharts.swift
//  MyDuesApp
//
//  Created by Venoli Gamage on 2021-05-16.
//
//
import UIKit

class PieCharts: UIView {

    public var outOfBudget = false
    private var backgroundLayer: CAShapeLayer!
    private var foregroundLayer: CAShapeLayer!
    private var titleTextLayer: CATextLayer!
    private var subTitleTextLayer: CATextLayer!
    private var gradientLayer: CAGradientLayer!
    
    private var layers : [CAGradientLayer] = []
    private var shapeLayers : [CAShapeLayer] = []
    private var startGradientColors : [UIColor?] = [ UIColor(hex: "#cbb2feff"), UIColor(hex: "#006ba6ff"), UIColor(hex:"#ec5766ff"), UIColor(hex: "#ecc927ff"), UIColor(hex: "#ea9ab2ff"), UIColor(hex: "#04a6c2ff")]
    private var endGradientColors : [UIColor] = [UIColor.white, UIColor.white, UIColor.white, UIColor.white, UIColor.white, UIColor.white]
    private var category1Layer: CAGradientLayer!
    private var category2Layer: CAGradientLayer!
    private var category3Layer: CAGradientLayer!
    private var category4Layer: CAGradientLayer!
    private var otherLayer: CAGradientLayer!
    private var remainingLayer: CAGradientLayer!
    private var currentAngle: CGFloat = 0.0
    
    
    
    public var expenses: [Double] = [0,0,0,0,0,0]{
        didSet {
            setNeedsDisplay()
        }
    }
    public var totalBudget: Double = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    override func draw(_ rect: CGRect) {

        let width = rect.width
        let height = rect.height
        let center = CGPoint(x: width / 2, y: height / 2)
        let radius = (min(width, height)) / 2
        let context = UIGraphicsGetCurrentContext()
        
        for index in 0...5 { // loop through the values list
            
            let startAngle = currentAngle
            let endAngle = Calculations.calculateAngle(startAngle: startAngle, expenceAmount: expenses[index], totalBudget: totalBudget)
            currentAngle = endAngle
            
            
            context?.setFillColor(startGradientColors[index]?.cgColor ?? UIColor.gray.cgColor)
            if(index == 5 && outOfBudget){
                context?.setFillColor(UIColor(hex: "#343a40ff")?.cgColor ?? UIColor.gray.cgColor)
            }
            
            context?.move(to: center)
            context?.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)

            context?.fillPath()
            
         

        }
        
    }
 
    
}
