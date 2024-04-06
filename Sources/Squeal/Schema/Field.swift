//
//  Field.swift
//  
//
//  Created by DURAND SAINT OMER Sacha on 04/04/2024.
//

import Foundation


public struct Field<T>: AnyField {
    public typealias FieldType = T
    
    public init(name: String) {
        self.name = name
    }
    
    public let name: String
}
