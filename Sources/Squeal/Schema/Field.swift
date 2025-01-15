//
//  Field.swift
//  
//
//  Created by DURAND SAINT OMER Sacha on 04/04/2024.
//

import Foundation


//public struct Field<T>: AnyField {
//    public typealias FieldType = T
//    
//    public init(name: String) {
//        self.name = name
//    }
//    
//    /// 2) Init from any RawRepresentable whose RawValue == String
//   public init<R: RawRepresentable>(_ name: R) where R.RawValue == String {
//       self.name = name.rawValue
//   }
//       
//    
//    public let name: String
//}

//public struct Field<T> {
//    public typealias FieldType = T
//    
//    public init(name: String) {
//        self.name = name
//    }
//    
//    /// 2) Init from any RawRepresentable whose RawValue == String
//   public init<R: RawRepresentable>(_ name: R) where R.RawValue == String {
//       self.name = name.rawValue
//   }
//       
//    
//    public let name: String
//}
//




public struct TableColumn<T: Table, FieldType> {
    
    public init(name: String) {
        self.name = name
        self.tableName = T.schema
    }
    
    public let name: String
    public let tableName: String
}

@propertyWrapper
public struct TableColumnProperty<T, Value> where T: Table {
    var name: String
    public var wrappedValue: TableColumn<T, Value>
    
    init(name: String) {
        self.wrappedValue = TableColumn<T, Value>(name: name)
        self.name = name
    }
}


extension Table {
    public typealias Column<T> = TableColumnProperty<Self, T>
}



