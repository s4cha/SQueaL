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




/// A column of table `T` whose values have type `FieldType`.
///
/// You refer to a column in one of two ways:
/// - As a key path, such as `\.name`. It resolves against the query's main table and
///   renders unqualified (`name`).
/// - As a value, such as `users.name`. It renders qualified with its table (`users.name`),
///   which is what you need for joined tables.
///
/// Because a column carries its value type, comparisons like `\.age >= 18` are
/// type-checked, and join conditions only compile between columns of the same type.
public struct TableColumn<T: Table, FieldType> : Sendable {

    /// Creates a column of `T` with the given database name.
    public init(name: String) {
        self.name = name
        self.tableName = T.schema
    }

    /// The column's name in the database.
    public let name: String
    /// The name of the column's table, used to qualify it as `table.column`.
    public let tableName: String
}

/// The property wrapper that declares a column on a ``Table``.
///
/// Inside a `Table`, it's available as `Column`:
///
/// ```swift
/// @Column<String>(name: "email_address") var email
/// ```
@propertyWrapper
public struct TableColumnProperty<T, Value>: Sendable where T: Table {
    var name: String
    /// The column the property exposes.
    public var wrappedValue: TableColumn<T, Value>

    /// Declares a column with the given database name.
    public init(name: String) {
        self.wrappedValue = TableColumn<T, Value>(name: name)
        self.name = name
    }
}


extension Table {
    /// Declares a column whose values have type `T`. See ``TableColumnProperty``.
    public typealias Column<T> = TableColumnProperty<Self, T>
}



