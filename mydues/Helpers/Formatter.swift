//
//  Formatter.swift
//  MyDuesApp
//
//  Created by Venoli Gamage on 2021-05-16.
//
//

import Foundation

public class Formatter {
    // Helper to format date
    public func formatDate(_ date: Date) -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
}
