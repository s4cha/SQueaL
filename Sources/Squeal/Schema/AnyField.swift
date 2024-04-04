//
//  AnyField.swift
//
//
//  Created by DURAND SAINT OMER Sacha on 04/04/2024.
//

import Foundation

public protocol AnyField<FieldType> {
    associatedtype FieldType
    var name: String { get }
}
