//
//  AnyField.swift
//
//
//  Created by DURAND SAINT OMER Sacha on 04/04/2024.
//

import Foundation


/// A named column whose values have type `FieldType`.
public protocol AnyField<FieldType> {
    /// The Swift type of the column's values.
    associatedtype FieldType
    /// The column's name in the database.
    var name: String { get }
}
