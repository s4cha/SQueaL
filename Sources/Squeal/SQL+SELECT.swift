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
    
    func SELECT(_ v: SQLSelectValue) -> SelectSQLQuery {
        return StartSQLQuery().SELECT(v.rawValue)
    }
    
    // Colorouing seems fucked
    func SELECT(_ v: ((Int, Int) -> Int)) -> SelectSQLQuery {
        return StartSQLQuery().SELECT("-")
    }
    
//    func SELECTFROM<T: Table>(_ values: String, from table: T) -> TypedSQLQuery<T> {
//        return TypedSQLQuery(schema: table).SELECT(values)
//    }
//    
    func table<T: Table>(_ table: T) ->  TypedSQLQuery<T> {
        return TypedSQLQuery(schema: table)
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

//
//public extension Table {
////    func SELECT(_ string: String) -> TypedSelectSQLQuery<Self> {
////        return TypedSelectSQLQuery(for: self, raw: "SELECT \(string)")
////    }
////    
////    func SELECT(_ v: SQLSelectValue) -> TypedSelectSQLQuery<Self> {
////        return TypedSelectSQLQuery(for: self, raw: "SELECT \(v.rawValue)")
////    }
////    
////    func SELECT<X>(_ keypath:  KeyPath<T, Field<X>>) -> TypedSelectSQLQuery<Self> {
////        return TypedSelectSQLQuery(for: schema, raw: "SELECT" + " " + schema[keyPath: keypath].name)
////           // .FROM(self.schema)
////    }
////    
////    func SELECT<X, Y>(_ keypath1:  KeyPath<T, Field<X>>, _ keypath2:  KeyPath<T, Field<Y>>) -> TypedSelectSQLQuery<T> {
////        return TypedSelectSQLQuery(for: schema, raw: "SELECT" + " " + schema[keyPath: keypath1].name + ", " + schema[keyPath: keypath1].name)
////           // .FROM(self.schema)
////    }
//}


public extension TypedSQLQuery {
    
    func SELECT(_ string: String) -> TypedSelectSQLQuery<T> {
        return TypedSelectSQLQuery(for: schema, raw: "SELECT \(string)")
    }
    
    func SELECT(_ v: SQLSelectValue) -> TypedSelectSQLQuery<T> {
        return TypedSelectSQLQuery(for: schema, raw: "SELECT \(v.rawValue)")
    }
    
    func SELECT<X>(_ keypath:  KeyPath<T, Field<X>>) -> TypedSelectSQLQuery<T> {
        return TypedSelectSQLQuery(for: schema, raw: "SELECT" + " " + schema[keyPath: keypath].name)
           // .FROM(self.schema)
    }
    
    func SELECT<X, Y>(_ keypath1:  KeyPath<T, Field<X>>, _ keypath2:  KeyPath<T, Field<Y>>) -> TypedSelectSQLQuery<T> {
        return TypedSelectSQLQuery(for: schema, raw: "SELECT" + " " + schema[keyPath: keypath1].name + ", " + schema[keyPath: keypath1].name)
           // .FROM(self.schema)
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

public struct TypedSelectSQLQuery<T: Table> {
    
    let table: T
    public var raw: String
    

    init(for table: T, raw: String) {
        self.table = table
        self.raw = raw
    }
}

//
public struct SQL<T: Table> {
    let table: T
    public init(_ table: T) {
        self.table = table
    }
}
//
//
//public extension SQL {
//    func SELECT(_ string: String) -> TypedSelectSQLQuery<T> {
//        return TypedSelectSQLQuery(for: table, raw: "SELECT \(string)")
//    }
//    
//    func SELECT(_ v: SQLSelectValue) -> TypedSelectSQLQuery<T> {
//        return TypedSelectSQLQuery(for: table, raw: "SELECT \(v.rawValue)")
//    }
//    
//    func SELECT<X>(_ keypath:  KeyPath<T, Field<X>>) -> TypedSelectSQLQuery<T> {
//        return TypedSelectSQLQuery(for: table, raw: "SELECT" + " " + table[keyPath: keypath].name)
//           // .FROM(self.schema)
//    }
//    
//    func SELECT<X, Y>(_ keypath1:  KeyPath<T, Field<X>>, _ keypath2:  KeyPath<T, Field<Y>>) -> TypedSelectSQLQuery<T> {
//        return TypedSelectSQLQuery(for: table, raw: "SELECT" + " " + table[keyPath: keypath1].name + ", " + table[keyPath: keypath1].name)
//           // .FROM(self.schema)
//    }
//}


///
///
///
///
///

//public struct SQL {
    
public func SELECT<T>(_ string: String, FROM table: T) -> TypedFromSQLQuery<T> {
    return TypedSQLQuery(for: table).SELECT(string).FROM(table)
}
    
public func SELECT<T, X>(_ keypath:  KeyPath<T, Field<X>>, FROM table: T) -> TypedFromSQLQuery<T> {
    return TypedSQLQuery(for: table).SELECT(keypath).FROM(table)
}


public extension String {
    
    func SELECT<T>(_ v: SQLSelectValue, FROM table: T) -> TypedFromSQLQuery<T> {
        return TypedSQLQuery(for: table).SELECT(v).FROM(table)
    }
    
    func SELECT<T, X>(_ keypath:  KeyPath<T, Field<X>>, FROM table: T) -> TypedFromSQLQuery<T> {
        return TypedSQLQuery(for: table).SELECT(keypath).FROM(table)
    }
    
    func SELECT<X, Y, T>(_ keypath1:  KeyPath<T, Field<X>>, _ keypath2:  KeyPath<T, Field<Y>>, FROM table: T) -> TypedFromSQLQuery<T> {
        return TypedSelectSQLQuery(for: table, raw: "SELECT" + " " + table[keyPath: keypath1].name + ", " + table[keyPath: keypath1].name)
            .FROM(table)
    }
    
    func DELETE<T>(FROM table: T) -> TypedFromSQLQuery<T> {
        return TypedSQLQuery(for: table).DELETE().FROM(table)
    }
}
    
//}

//public extension SQL {
//    func SELECT(_ string: String) -> TypedSelectSQLQuery<T> {
//        return TypedSelectSQLQuery(for: table, raw: "SELECT \(string)")
//    }
//    
//    func SELECT(_ v: SQLSelectValue) -> TypedSelectSQLQuery<T> {
//        return TypedSelectSQLQuery(for: table, raw: "SELECT \(v.rawValue)")
//    }
//    
////    func SELECT<X>(_ keypath:  KeyPath<T, Field<X>>) -> TypedSelectSQLQuery<T> {
////        return TypedSelectSQLQuery(for: table, raw: "SELECT" + " " + table[keyPath: keypath].name)
////           // .FROM(self.schema)
////    }
//    
//    func SELECT<X, Y>(_ keypath1:  KeyPath<T, Field<X>>, _ keypath2:  KeyPath<T, Field<Y>>) -> TypedSelectSQLQuery<T> {
//        return TypedSelectSQLQuery(for: table, raw: "SELECT" + " " + table[keyPath: keypath1].name + ", " + table[keyPath: keypath1].name)
//           // .FROM(self.schema)
//    }
//}
