//
//  SQLEquation.swift
//
//
//  Created by DURAND SAINT OMER Sacha on 04/04/2024.
//

import Foundation

public struct SQLEquation {
    let left: String
    let sign: String
    let right: Any
}


public func == (left: String, right: Any) -> SQLEquation {
    return SQLEquation(left: left, sign: "=", right: right)
}

public func == <T>(left: Field<T>, right: Any) -> SQLEquation {
    return SQLEquation(left: left.name, sign: "=", right: right)
}
