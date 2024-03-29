//
//  TypedSQLQuery+Helpers.swift
//  
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public extension TypedSQLQuery {

    func all() -> SQLQuery {
        return self.SELECT(.all)
            .FROM(schema.tableName)
    }
     
    func find<U>(_ kp: KeyPath<T, Field<U>>, equals value: U) -> TypedLimitSQLQuery<T> {
        return self.SELECT(.all)
            .FROM(schema.tableName)
            .WHERE(kp, equals: value)
            .LIMIT(1)
    }
}

public extension Table {
//    static func all() -> SQLQuery {
//        return SQLQueryBuilder()
//            .query(for: self)
//            .SELECT(.all)
//            .FROM(tableName)
//    }
    

    func query() -> TypedSQLQuery<Self> {
        return SQLQueryBuilder()
            .query(for: self)
    }

    func all() -> SQLQuery {
        return SQLQueryBuilder()
            .query(for: self)
            .SELECT(.all)
            .FROM(tableName)
    }
    
    func find<U>(_ kp: KeyPath<Self, Field<U>>, equals value: U) -> TypedLimitSQLQuery<Self> {
        return TypedSQLQuery(for: self)
           .SELECT(.all)
           .FROM(tableName)
           .WHERE(kp, equals: value)
           .LIMIT(1)
    }
}
