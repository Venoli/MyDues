//
//  Category+CoreDataProperties.swift
//  MyDuesApp
//
//  Created by Venoli Gamage on 2021-05-16.
//
//


import Foundation
import CoreData


extension Category {
    
///
///what is the use of @objc and @nonobjc in swift?
///https://stackoverflow.com/questions/41036045/when-objc-and-nonobjc-write-before-method-and-variable-in-swift
///https://docs.swift.org/swift-book/ReferenceManual/Attributes.html
///

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var colour: String
    @NSManaged public var monthlyBudget: Double
    @NSManaged public var name: String
    @NSManaged public var notes: String
    @NSManaged public var numberOfTaps: Int64
    @NSManaged public var expense: NSSet?

}

// MARK: Generated accessors for tasks
extension Category {

    @objc(addExpenseObject:)
    @NSManaged public func addToExpense(_ value: Expense)

    @objc(removeExpenseObject:)
    @NSManaged public func removeFromExpense(_ value: Expense)

    @objc(addExpense:)
    @NSManaged public func addToExpense(_ values: NSSet)

    @objc(removeExpense:)
    @NSManaged public func removeFromExpense(_ values: NSSet)

}
