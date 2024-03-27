//
//  SQL+AND.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

extension SQLQuery {
    func AND(_ clause: String) -> SQLQuery {
        return BareSQLQuery(raw: raw + " AND \(clause)")
    }
}

extension TypedSQLQuery {
    func AND<U>(_ kp: KeyPath<T, Field<U>>, equals value: U) -> TypedSQLQuery<T> {
        return TypedSQLQuery(schema: schema, raw: raw + " " + "AND" + " \(schema[keyPath: kp].name)" + " = " + "\(value)" )
    }
    
    func AND<U>(_ kp: KeyPath<T, Field<U>>, equals value: U) -> TypedSQLQuery<T> where U == String {
        return TypedSQLQuery(schema: schema, raw: raw + " " + "AND" + " \(schema[keyPath: kp].name)" + " = " + "'\(value)'" )
    }
}


//extension SQLQuery {
//
//    func AND(_ column: ColumnName, equals value: Any) -> SQLQuery {
//        return SQLQuery(raw: self.raw + " " + "AND \(column) = \(value)")
//    }
//}
