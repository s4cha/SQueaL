//
//  SQL+DELETE.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public extension SQLQuery {
    func DELETE() -> SQLQuery {
        return BareSQLQuery(raw: raw + "DELETE")
    }
}

public extension TypedSQLQuery {
    func DELETE() -> TypedSelectSQLQuery<T> {
        return TypedSelectSQLQuery(for: schema, raw: raw + "DELETE")
    }
}
