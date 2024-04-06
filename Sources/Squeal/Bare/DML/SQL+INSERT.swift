//
//  SQL+INSERT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public extension SQLQuery {
    func INSERT(INTO tableName: String, columns: String...) -> SQLQuery {
        return BareSQLQuery(query: query + "INSERT INTO \(tableName)" + " ("  + columns.joined(separator: ", ") +  ")", parameters: []) // TODO
    }
    
    func VALUES(_ values: String...) -> SQLQuery {
        return BareSQLQuery(query: query + " VALUES ("  + values.map {"'\($0)'"} .joined(separator: ", ") +  ")", parameters: []) // TODO
    }
}
