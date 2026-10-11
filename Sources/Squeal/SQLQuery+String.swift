//
//  File.swift
//  
//
//  Created by DURAND SAINT OMER Sacha on 11/04/2024.
//

import Foundation

// Format Queries.
public extension SQLQuery {
    /// The query with each placeholder replaced by its parameter, for logging and debugging.
    ///
    /// Strings and UUIDs are single-quoted, and `nil` becomes `NULL`. Nothing is escaped, so
    /// never execute this string. Run ``query`` with ``parameters`` instead.
    func toString() -> String {
        var q = query
        for (index, value) in parameters.enumerated().reversed() {
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
    /// The query with its parameters inlined. See ``toString()``.
    var description: String { return toString() }
}
