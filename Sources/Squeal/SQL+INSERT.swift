//
//  SQL+INSERT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

extension SQLQuery {
    func INSERT(INTO tableName: String, columns: String...) -> SQLQuery {
        return BareSQLQuery(raw: raw + "INSERT INTO \(tableName)" + " ("  + columns.joined(separator: ", ") +  ")")
    }
    
    func VALUES(_ values: String...) -> SQLQuery {
        return BareSQLQuery(raw: raw + " VALUES ("  + values.map {"'\($0)'"} .joined(separator: ", ") +  ")")
    }
}


//INSERT INTO table_name (column1, column2, column3, ...)
//VALUES (value1, value2, value3, ...);
