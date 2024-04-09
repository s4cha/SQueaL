//
//  SQLQuery.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public protocol SQLQuery: CustomStringConvertible {
    var query: String { get }
    var parameters: [(any Encodable)?] { get }
}

public extension SQLQuery {
    var description: String { return toString() }
}


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
    
    func nextDollarSign() -> String {
        return "$\(parameterNumber() + 1)"
    }
    
    func parameterNumber() -> Int {
        return query.filter { $0 == "$" }.count
    }
}
