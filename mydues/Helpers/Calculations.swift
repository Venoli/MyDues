//
//  Colours.swift
//  MyDuesApp
//
//  Created by Venoli Gamage on 2021-05-16.
//
//

import Foundation
import UIKit

public class Calculations {

    public func getTimeDiff(_ start: Date, end: Date) -> (Int, Int, Int) {
        let difference: TimeInterval? = end.timeIntervalSince(start)

        let secondsInAnHour: Double = 3600
        let secondsInADay: Double = 86400
        let secondsInAMinute: Double = 60

        let diffInDays = Int((difference! / secondsInADay))
        let diffInHours = Int((difference! / secondsInAnHour))
        let diffInMinutes = Int((difference! / secondsInAMinute))

        var daysLeft = diffInDays
        var hoursLeft = diffInHours - (diffInDays * 24)
        var minutesLeft = diffInMinutes - (diffInHours * 60)

        if daysLeft < 0 {
            daysLeft = 0
        }

        if hoursLeft < 0 {
            hoursLeft = 0
        }

        if minutesLeft < 0 {
            minutesLeft = 0
        }

        return (daysLeft, hoursLeft, minutesLeft)
    }
    
    public func getProjectProgress(_ tasks: [Expense]) -> Int { 
        var progressTotal: Float = 0
        var progress: Int = 0
        
//        if tasks.count > 0 {
//            for task in tasks {
//                progressTotal += task.progress
//            }
//            progress = Int(progressTotal) / tasks.count
//        }
        
        return progress
    }
    
    public func getExpenseProportionPercentage(totalBudget: Double, expenceAmount: Double) -> Double{
        
        return (expenceAmount / totalBudget) * 100
    }
    public static func calculateAngle(startAngle: CGFloat, expenceAmount: Double, totalBudget: Double) -> CGFloat{
        let gap = (CGFloat(expenceAmount) / CGFloat(totalBudget)) * CGFloat.pi * CGFloat(2)
        
        let endAngle = startAngle + gap
        return endAngle
    }
    
    
}
