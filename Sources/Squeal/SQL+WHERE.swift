//
//  SQL+WHERE.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

extension SQLQuery {
    func WHERE(_ clause: String) -> SQLQuery {
        return BareSQLQuery(raw: raw + " WHERE \(clause)")
    }
    
    func WHERE(_ column: String, equals value: Any) -> SQLQuery {
        return BareSQLQuery(raw: raw + " WHERE \(column) = \(value)")
    }
}

extension FromSQLQuery {
    func WHERE(_ clause: String) -> SQLQuery {
        return BareSQLQuery(raw: raw + " WHERE \(clause)")
    }
    
//    func WHERE(_ column: String, equals value: Any) -> SQLQuery {
//        return BareSQLQuery(raw: raw + " WHERE \(column) = \(value)")
//    }
}


extension TypedSQLQuery {
    func WHERE<U>(_ kp: KeyPath<T, Field<U>>, equals value: U) -> TypedSQLQuery<T> {
        return TypedSQLQuery(schema: schema, raw: raw + " " + "WHERE" + " \(schema[keyPath: kp].name)" + " = " + "\(value)" )
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
