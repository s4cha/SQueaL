//
//  TypedSQL + DELETE.swift
//  
//
//  Created by DURAND SAINT OMER Sacha on 04/04/2024.
//

import Foundation

public extension TypedSQLQuery {
    func DELETE() -> TypedSelectSQLQuery<T> {
        return TypedSelectSQLQuery(for: schema, raw: raw + "DELETE")
    }
}
