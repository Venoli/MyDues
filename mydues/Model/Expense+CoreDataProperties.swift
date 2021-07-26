//
//  Expense+CoreDataProperties.swift
//  MyDuesApp
//
//  Created by Venoli Gamage on 2021-05-16.
//
//



import Foundation
import CoreData


extension Expense {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expense> {
        return NSFetchRequest<Expense>(entityName: "Expense")
    }

    @NSManaged public var amount: Double
    @NSManaged public var date: NSDate
    @NSManaged public var notes: String
    @NSManaged public var occurrence: Int
    @NSManaged public var reminder: Bool
    @NSManaged public var category: Category?
    
}
