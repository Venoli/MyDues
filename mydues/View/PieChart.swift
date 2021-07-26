//
//  PieChart.swift
//  MyDuesApp
//
//  Created by Venoli Gamage on 2021-05-16.
//
//
import UIKit
class PieChart: UIView {
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
 private struct Constants {
 static let numberOfGlasses = 100
 static let lineWidth: CGFloat = 5.0
 static let arcWidth: CGFloat = 76

 static var halfOfLineWidth: CGFloat {
 return lineWidth / 2
 }
 }

 @IBInspectable var counter: Int = 5
 @IBInspectable var outlineColor: UIColor = UIColor.blue
 @IBInspectable var counterColor: UIColor = UIColor.orange

 override func draw(_ rect: CGRect) {
    let width = rect.width
    let height = rect.height
    let center = CGPoint(x: width / 2, y: height / 2)

    let radius = (max(width, height)) / 2
    // 3
    let startAngle: CGFloat = 3 * .pi / 2
    let endAngle: CGFloat = .pi / 4
    // 4
    let path = UIBezierPath(
     arcCenter: center,
     radius: radius/2,
     startAngle: startAngle,
     endAngle: endAngle,
     clockwise: true)
    // 5
    path.lineWidth = Constants.arcWidth
    counterColor.setStroke()
    path.stroke()
 }
}
