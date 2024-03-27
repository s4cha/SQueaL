//
//  TypedSQLQuery+Helpers.swift
//  
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

extension TypedSQLQuery {

    func all() -> SQLQuery {
        return self.SELECT(.all)
            .FROM(schema.tableName)
    }
     
    func find<U>(_ kp: KeyPath<T, Field<U>>, equals value: U) -> SQLQuery {
        return self.SELECT(.all)
            .FROM(schema.tableName)
            .WHERE(kp, equals: value)
            .LIMIT(1)
    }
}

extension Table {
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
    
    func find<U>(_ kp: KeyPath<Self, Field<U>>, equals value: U) -> SQLQuery {
        return SQLQueryBuilder()
           .query(for: self)
           .SELECT(.all)
           .FROM(tableName)
           .WHERE(kp, equals: value)
           .LIMIT(1)
    }
}
