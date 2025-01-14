//
//  TSQL+UPDATE.swift
//
//
//  Created by DURAND SAINT OMER Sacha on 04/04/2024.
//

import Foundation


public extension SQL {

    static func UPDATE<T, Y: Encodable>(_ table: T, SET keypath: KeyPath<T, Field<Y>>, value: Y?) -> TypedFromSQLQuery<T> {
        let q = "UPDATE \(table.tableName) SET \(table[keyPath: keypath].name) = $1"
        return TypedFromSQLQuery(for: table, query: q, parameters: [value])
    }
}
