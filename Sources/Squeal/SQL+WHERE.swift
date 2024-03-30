//
//  SQL+WHERE.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public func == (left: String, right: Any) -> SQLEquation {
    return SQLEquation(left: left, sign: "=", right: right)
}

public func == <T>(left: Field<T>, right: Any) -> SQLEquation {
    return SQLEquation(left: left.name, sign: "=", right: right)
}

public func == <T,Y>(left: KeyPath<T, Field<Y>>, right: Y) -> KPSQLEquation<T, Y> {
    return KPSQLEquation(left: left, sign: "=", right: right)
}


public struct SQLEquation {
    let left: String
    let sign: String
    let right: Any
}

public struct KPSQLEquation<T, Y> {
    let left: KeyPath<T, Field<Y>>
    let sign: String
    let right: Y
}

public extension SQLQuery {
    func WHERE(_ clause: String) -> SQLQuery {
        return BareSQLQuery(raw: raw + " WHERE \(clause)")
    }
    
    func WHERE(_ column: String, equals value: Any) -> SQLQuery {
        return BareSQLQuery(raw: raw + " WHERE \(column) = \(value)")
    }
}

public extension FromSQLQuery {
    func WHERE(_ clause: String) -> WhereSQLQuery {
        return WhereSQLQuery(raw: raw + " WHERE \(clause)")
    }
    
    func WHERE(_ column: String, equals value: Any) -> WhereSQLQuery {
        return WhereSQLQuery(raw: raw + " WHERE \(column) = \(value)")
    }
    
    func WHERE(_ equation: SQLEquation) -> WhereSQLQuery {
        return WhereSQLQuery(raw: raw + " WHERE \(equation.left) \(equation.sign) \(equation.right)")
    }
    
//    func WHERE(v1: String, op: ((Int, Int) -> Int), v2: String) -> WhereSQLQuery {
//        return WhereSQLQuery(raw: raw + " WHERE \(v1) = \(v2)")
//    }
}


public extension TypedFromSQLQuery {
    func WHERE<U>(_ kp: KeyPath<T, Field<U>>, equals value: U) -> TypedWhereSQLQuery<T> {
        return TypedWhereSQLQuery(for: table, raw: raw + " " + "WHERE" + " \(table[keyPath: kp].name)" + " = " + "\(value)" )
    }
    
    func WHERE(_ equation: SQLEquation) -> TypedWhereSQLQuery<T> {
        return TypedWhereSQLQuery(for: table, raw: raw + " WHERE \(equation.left) \(equation.sign) \(equation.right)")
    }
    
    func WHERE<Y>(_ equation: KPSQLEquation<T, Y>) -> TypedWhereSQLQuery<T> {
        return TypedWhereSQLQuery(for: table, raw: raw + " WHERE \(table[keyPath: equation.left].name) \(equation.sign) \(equation.right)")
    }
    
//    func WHERE<U>(_ kp: KeyPath<T, Field<U>>, equals value: U) -> TypedWhereSQLQuery<T> {
//        return TypedWhereSQLQuery(for: table, raw: raw + " " + "WHERE" + " \(table[keyPath: kp].name)" + " = " + "\(value)" )
//    }
}

public struct WhereSQLQuery: CustomStringConvertible {
    public var description: String { return raw }
    let raw: String
}

public struct TypedWhereSQLQuery<T: Table>: CustomStringConvertible {
    public var description: String { return raw }
    let table: T
    public var raw: String
    

    init(for table: T, raw: String) {
        self.table = table
        self.raw = raw
    }
}

//
//extension TypedSQLQuery {
//    
//    func WHERE<U>(_ kp: KeyPath<T, Field<U>>, equals value: U) -> SQLQuery {
//        return SQLQuery(schema: schema, raw: raw + " " + "WHERE" + " \(schema[keyPath: kp].name)" + " = " + "\(value)" )
//    }
//    
//    func AND<U>(_ kp: KeyPath<T, Field<U>>, equals value: U) -> SQLQuery {
//        return SQLQuery(schema: schema, raw: raw + " " + "AND" + " \(schema[keyPath: kp].name)" + " = " + "\(value)" )
//    }
//    
////    func WHERE(_ column: ColumnName, equals value: Any) -> SQLQuery {
////        return SQLQuery(raw: self.raw + " " + "WHERE \(column) = \(value)")
////    }
////
////    func WHERE(columnEnum: T.ColumnsEnum, equals value: Any) -> SQLQuery {
////        return SQLQuery(raw: self.raw + " " + "WHERE \(columnEnum) = \(value)")
////    }
//    
////    func WHERE(_ columnEnum: T.ColumnsEnum, equals value: Any) -> SQLQuery {
////        return SQLQuery(raw: self.raw + " " + "WHERE \(columnEnum) = \(value)")
////    }
//}
