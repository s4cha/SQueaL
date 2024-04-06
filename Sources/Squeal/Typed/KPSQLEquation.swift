//
//  KPSQLEquation.swift
//
//
//  Created by DURAND SAINT OMER Sacha on 04/04/2024.
//

import Foundation


public struct KPSQLEquation<T, Y> {
    let left: KeyPath<T, Field<Y>>
    let sign: String
    let right: Y
}

public func == <T,Y>(left: KeyPath<T, Field<Y>>, right: Y) -> KPSQLEquation<T, Y> {
    return KPSQLEquation(left: left, sign: "=", right: right)
}
