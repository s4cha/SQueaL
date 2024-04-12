//
//  File.swift
//  
//
//  Created by DURAND SAINT OMER Sacha on 11/04/2024.
//

import Foundation

// Format Queries.
public extension SQLQuery {
    func toString() -> String {
        var q = query
        for (index, value) in parameters.enumerated() {
            var formattedValue = ""
            if value == nil {
                formattedValue = "NULL"
            } else if let stringValue = value as? String {
                formattedValue = "'\(stringValue)'"
            } else if let uuid = value as? UUID {
                formattedValue = "'\(uuid.uuidString)'"
            } else if let int = value as? Int {
                formattedValue = "\(int)"
            } else {
                formattedValue = "\(value!)" // TODO quotes for UUIDs etc ?
            }
            q = q.replacingOccurrences(of: "$\(index + 1)", with: "\(formattedValue)")
        }
        return q
    }
}

public extension SQLQuery {
    var description: String { return toString() }
}
