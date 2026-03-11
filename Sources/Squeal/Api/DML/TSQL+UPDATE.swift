//
//  TSQL+UPDATE.swift
//
//
//  Created by DURAND SAINT OMER Sacha on 04/04/2024.
//

import Foundation

public struct TypedUpdateSQLQuery<T: Table, Row>: TableSQLQuery, WHEREableQuery {
    
    public let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
        
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}


public extension SQL {
    
    static func UPDATE<T, each U: Encodable>(_ table: T, SET pairs: repeat (KeyPath<T, TableColumn<T, each U>>, (each U)?)) -> TypedUpdateSQLQuery<T, Void> {
        var q = "UPDATE \(T.schema) SET "
        let table = T()
        var parameters = [Encodable]()
        var setValues = [String]()
        var nextPIndex = 0
        for pair in repeat each pairs {
            nextPIndex = nextPIndex + 1
            setValues.append(table[keyPath: pair.0].name + " = $\(nextPIndex)")
            parameters.append(pair.1)
        }
        q += setValues.joined(separator: ", ")
        return TypedUpdateSQLQuery(for: table, query: q, parameters: parameters)
    }
}
