//
//  TypedSQL + DELETE.swift
//  
//
//  Created by DURAND SAINT OMER Sacha on 04/04/2024.
//

import Foundation

//public extension TypedSQLQuery {
//    func DELETE() -> TypedSelectSQLQuery<T> {
//        return TypedSelectSQLQuery(for: table, query: query + "DELETE", parameters: [])
//    }
//}

public extension SQL {
    static func DELETE_FROM<T>(_ table: T) -> TypedFromSQLQuery<T> {
        return TypedSelectSQLQuery(for: table, query: "DELETE", parameters: []).FROM(table)
    }
}
