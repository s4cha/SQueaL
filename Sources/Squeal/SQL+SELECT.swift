//
//  SQL+SELECT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public extension String {
    func SELECT(_ string: String) -> SelectSQLQuery {
        return StartSQLQuery().SELECT(string)
    }
}

public extension Squeal {
    static func SELECT(_ string: String) -> SelectSQLQuery {
        return StartSQLQuery().SELECT(string)
    }
}


public extension SQLQuery {
    func SELECT(_ string: String) -> SQLQuery {
        return BareSQLQuery(raw: raw + "SELECT \(string)")
    }
    
    func SELECT(_ v: SQLSelectValue) -> SQLQuery {
        return BareSQLQuery(raw: raw + "SELECT \(v.rawValue)")
    }
    
    func SELECT<X>(_ field:  Field<X>) -> SQLQuery {
        return BareSQLQuery(raw: "SELECT" + " " + field.name)
    }
    
    func SELECT<X,Y>(_ field:  Field<X>, _ field2:  Field<Y>) -> SQLQuery {
        return BareSQLQuery(raw: "SELECT" + " " + field.name + ", " + field2.name)
    }
}

public extension StartSQLQuery {
    
    func SELECT(_ v: SQLSelectValue) -> SelectSQLQuery {
        return SelectSQLQuery(raw: "SELECT \(v.rawValue)")
    }
    
    func SELECT(_ string: String) -> SelectSQLQuery {
        return SelectSQLQuery(raw: "SELECT \(string)")
    }
    
    func SELECT<X>(_ field:  Field<X>) -> SelectSQLQuery {
        return SelectSQLQuery(raw: "SELECT" + " " + field.name)
    }
    
    func SELECT<X,Y>(_ field:  Field<X>, _ field2:  Field<Y>) -> SelectSQLQuery {
        return SelectSQLQuery(raw: "SELECT" + " " + field.name + ", " + field2.name)
    }
}

public extension TypedSQLQuery {
    func SELECT(_ string: String) -> TypedSQLQuery<T> {
        return TypedSQLQuery(schema: schema, raw: raw + "SELECT \(string)")
    }
    
    func SELECT(_ v: SQLSelectValue) -> TypedSQLQuery<T> {
        return TypedSQLQuery(schema: schema, raw: raw + "SELECT \(v.rawValue)")
    }
    
    func SELECT<X>(_ keypath:  KeyPath<T, Field<X>>) -> TypedSQLQuery<T> {
        return TypedSQLQuery(schema: schema, raw: "SELECT" + " " + schema[keyPath: keypath].name)
    }
}


//
//mutating func SELECT(_ columns: String...) -> SQLQuery {
//    raw += "SELECT" + " " + columns.joined(separator: ", ")
//    return self
//}


extension TypedSQLQuery {
//    func SELECT(_ columnEnum: T.ColumnsEnum) -> SQLQuery<T> {
//        return SQLQuery(raw: "SELECT" + " " + "\(columnEnum)")
//    }
    
//    func SELECT(_ columnEnums: T.ColumnsEnum...) -> SQLQuery<T> {
//        return SQLQuery(raw: "SELECT" + " " +  columnEnums.map { "\($0)"}.joined(separator: ", ") )
//    }
    
//    func SELECT<U>(_ keypath: KeyPath<T, Field<U>>) -> TypedSQLQuery<T> {
//        return TypedSQLQuery(schema: schema, raw: "SELECT" + " "  + schema[keyPath: keypath].name )
//    }
    
//    func SELECT(_ keypaths: KeyPath<T, any AnyField>...) -> SQLQuery<T> {
//        return SQLQuery(schema: schema, raw: "SELECT" + " "  + keypaths.map { schema[keyPath: $0].name }.joined(separator: ", "))
//    }
    
//    func SELECT<U, each X: KeyPath<T, U>>(keypaths: repeat each X) -> SQLQuery<T>  {
//        let test = (repeat (each keypaths))
//        print(test)
////        return SQLQuery(schema: schema, raw: "SELECT" + " "  + keypaths.map { schema[keyPath: $0].name }.joined(separator: ", "))
//        return self
//    }
}


public struct SelectSQLQuery: CustomStringConvertible {
    public var description: String { return raw }
    
    let raw: String
}
