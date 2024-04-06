//
//  TSQL+UPDATE.swift
//
//
//  Created by DURAND SAINT OMER Sacha on 04/04/2024.
//

import Foundation


public extension String {

    func UPDATE<T, Y>(_ table: T, SET keypath: KeyPath<T, Field<Y>>, value: Y?) -> TypedFromSQLQuery<T> {
        let v = value == nil ? "NULL" : "'\(value!)'"
        return TypedFromSQLQuery(for: table, raw: "UPDATE \(table.tableName) SET \(table[keyPath: keypath].name) = \(v)")
    }
}
